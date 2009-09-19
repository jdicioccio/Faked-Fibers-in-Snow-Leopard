#import "SemaphoredArray.h"
#import "dispatch/dispatch.h"
#import <objc/runtime.h>

@implementation SemaphoredArray



- (id)initWithSemaphore:(dispatch_semaphore_t) sema;
{
  if((self = [super init]))
  {
    _que = [NSMutableArray array];
    _array_semaphore = sema;
  }
  return self;
}

-(void)push:(id) obj;
{
  [_que addObject:obj];

  int i = dispatch_semaphore_signal( _array_semaphore);

  if (i){

  }

};


-(id)pop;
{
   
  id return_val = nil;
  while(1){
	if ([_que count] == 0){
 
		dispatch_semaphore_wait( _array_semaphore, DISPATCH_TIME_FOREVER);
 
  } else {
 
     return_val = [_que objectAtIndex:0];
	  [_que removeObjectAtIndex:0];
	  return return_val;
  }
  }
}

@end

