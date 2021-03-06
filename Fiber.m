//
//  Fiber.m
//  Fibers
//
//  Created by rebo on 17/09/2009.
//  Copyright 2009 rebo. All rights reserved.
//
//  License is public domain
//
//  Port of ruby Poor Man's Fibers, by Aman Gupta
//
//

#import "Fiber.h"
#import "dispatch/dispatch.h"
#import "typedefs.h"
#import "SemaphoredArray.h"
#import <objc/runtime.h>

@implementation Fiber
@synthesize isBlockCompleted =_isBlockCompleted;
@synthesize isQueueSuspended = _isQueueSuspended;
@synthesize willBeCancelled = _willBeCancelled;

-(id) initWithBlock:(FiberBlk_t) block
{
	if (!(self = [super init])){ return nil;}
	
	
	// Create a dispatch queue for the fiber
	_fiberQueue = dispatch_queue_create("fiber.queue.com", NULL);

	// set context of fiberQueue to the fiber instance, so we can 
	// refer to the fiber from within the queue
	
	dispatch_set_context( _fiberQueue  , self);
	
	// create semaphoreArrays to handle argument object passing and 
	// thread sleeping
	
	dispatch_semaphore_t resume_semaphore = dispatch_semaphore_create(0);
	dispatch_semaphore_t yield_semaphore = dispatch_semaphore_create(0);
	
	_yieldSemaphoreArray  = [[SemaphoredArray alloc] initWithSemaphore:yield_semaphore];
	_resumeSemaphoreArray = [[SemaphoredArray alloc] initWithSemaphore:resume_semaphore];
	
	dispatch_release(yield_semaphore);
	dispatch_release(resume_semaphore);
	
	// to save on resources we start the queue in suspended mode, until
	// the fiber gets its first resume message
	
	dispatch_suspend(_fiberQueue);
	self.isQueueSuspended = YES;
	
	self.isBlockCompleted = NO;
	
	dispatch_async(_fiberQueue, ^{ if (!(self.willBeCancelled)){
		[_yieldSemaphoreArray push:block( [_resumeSemaphoreArray pop])]; 
		self.isBlockCompleted  = YES;
    }
	});    
	return self;
}

-(id) yield:(id)obj
{
	// This is normally called from [Fiber yield]
	// We first push the argument to our yield semaphored array
	// which also increments our yield semaphore.
	
	// If our resume was waiting for this object it is now returned
	[_yieldSemaphoreArray push:obj];
    
	//  We now do a pop which blocks until our resume call pushes to
	// the resume semaphore
	return [_resumeSemaphoreArray pop];
}

-(id) resume
{
	return [self resumeWithArgument:[NSNull null] error:NULL];
}
-(id) resumeWithArgument:(id) obj error:(NSError **)error
{
	
	if (self.isQueueSuspended){
		dispatch_resume(_fiberQueue);
		self.isQueueSuspended = NO;
	}
	
	if ( self.isBlockCompleted ){ 
		// block is finished so set error and return
		
		if (error == NULL){
			*error  = [NSError errorWithDomain:@"ResumeError" code:1 userInfo:nil];
			return nil;
		} 
	}
	
	// First thing we do is push the object to the resume array
	// And increments the resume semaphore.
	
	// Previously we had asked for the resume object and waited on the semephore 
	// the resume semaphore increment releases the thread running the block.
	[_resumeSemaphoreArray push:obj];
	
	// The block can now progress and will until it reaches a [Fiber yield] call
	
	
	// before we return the resume call, we ask for the object back from the yield queue
	// This blocks until Fiber yield is called and enables us to finish the pop
	// and return
	return [_yieldSemaphoreArray pop];
}


-(id) resumeWithArgument:(id) obj
{
	return [self resumeWithArgument:obj error: NULL];
}

+(id) yield
{
	// convienience call for yieldWithArgument:
	return [self yieldWithArgument:[NSNull null]];
	
}

+(Fiber *) current
{
	dispatch_queue_t que = dispatch_get_current_queue();
	Fiber * fiber = dispatch_get_context( que );
	
	return fiber;
}

+(id) yieldWithArgument:(id)obj
{
	// this is a class method called within a fibers block
	// we need a way of getting the fiber from the block
	// this is done by getting the queue context which in this case
	// is the fiber
	Fiber * fiber = [Fiber current];
	return [fiber yield:obj];
}

+(BOOL) willBeCancelled
{
	// returns the willBeCancelled property of the current fiber
	// This is used to escape from an infinite loop inside
	// a Block passed to the fiber.
	Fiber * fiber =  [Fiber current];
	// NSLog(@"Will be cancelled: %d", fiber.willBeCancelled);
	return fiber.willBeCancelled;  
}

-(void) cancel
{
	// As a GCD serial queue keeps the fiber alive, until the queue has been resumed a
	// and scheduled blocks expired we need to manually cancel a fiber.
	self.willBeCancelled = YES;
	if (self.isQueueSuspended){
		self.willBeCancelled = YES;
		dispatch_resume(_fiberQueue);
	}
	
	// if the qeueue is not suspended and block not completed
	// we need to resume the block to give it a chance to quit
	// after setting willBeCancelled;
	
	if (!(self.isBlockCompleted)){
		[self resume];
	}
}

-(void) dealloc
{ 
	dispatch_release(_fiberQueue);
	
	[_yieldSemaphoreArray release];
	[_resumeSemaphoreArray release];
	[super dealloc];
	NSLog(@"Fiber dealloc");
}

@end
