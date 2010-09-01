//
//  FibersAppDelegate.m
//  Fibers
//
//  Created by rebo on 17/09/2009.
//  Copyright 2009 rebo. All rights reserved.
//

#import "FibersAppDelegate.h"
#import "Fiber.h"
@implementation FibersAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	// define a  fiber that generates the next number in the fibonacci sequence
	// each time resume is called
	
	while(true) {
		Fiber * fibonacciFiber = [[Fiber alloc] initWithBlock:^id (id obj){    
			int f1 = 0; int f2 = 1; int f1_old;
			while( !([Fiber willBeCancelled]) ){  // Need to provide a way to escape from the while loop and complete the block
				[Fiber yieldWithArgument:[NSNumber numberWithInteger:f1]];
				f1_old = f1;
				f1 = f2;
				f2 = f1_old + f2;
			}
			NSLog(@"Returning...");
			return nil;
		}];
		
		
		for (int i = 1;i < 10; i++){
			NSLog(@"%@", [fibonacciFiber resume]);
		}
		// cancel a fiber, must be called if block has not been completed
		// or queue has not been started.  Otherwise fiber GC won't happen.
		[fibonacciFiber cancel];
		[fibonacciFiber release];
		sleep(1);
    }
}

@end