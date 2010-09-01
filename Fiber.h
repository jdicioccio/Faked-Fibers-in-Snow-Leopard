//
//  Fiber.h
//  Fibers
//
//  Created by rebo on 17/09/2009.
//  Copyright 2009 rebo. All rights reserved.
//
//  Port of ruby Poor Man's Fibers, by Aman Gupta

#import "typedefs.h"

@class SemaphoredArray;
@interface Fiber : NSObject {
	dispatch_queue_t _fiberQueue;
	SemaphoredArray * _yieldSemaphoreArray;
	SemaphoredArray * _resumeSemaphoreArray;
	BOOL _isBlockCompleted;
	BOOL _isQueueSuspended;
	BOOL _willBeCancelled;
}

//property thread
+(id) yield;
-(id) initWithBlock:(FiberBlk_t) block;
-(id) resume;
-(id) yield:(id)obj;
-(id) resumeWithArgument:(id) obj;
-(id) resumeWithArgument:(id) obj error:(NSError **)error;
+(id) yieldWithArgument:(id)obj;
-(void) cancel;
+(BOOL) willBeCancelled;
@property (assign) BOOL isBlockCompleted;
@property (assign) BOOL isQueueSuspended;
@property (assign) BOOL willBeCancelled;
@end
