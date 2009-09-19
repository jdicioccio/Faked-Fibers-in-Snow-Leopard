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
	
  Fiber * fibonacciFiber = [[Fiber alloc] initWithBlock:^id (id obj){    
    int f1 = 0; int f2 = 1; int f1_old;
    while(1){
      [Fiber yieldWithArgument:[NSNumber numberWithInteger:f1]];
		  f1_old = f1;
      f1 = f2;
      f2 = f1_old + f2;
      }
  }];

  for (int i = 1;i < 10; i++){
    NSLog(@"%@", [fibonacciFiber resume]);
  }
}

@end