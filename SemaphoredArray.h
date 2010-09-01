// A simple sempahored array for passing an object between threads.
// What it does is dispatch semaphore wait on the thread until a
// object has been added and the semaphore been signalled.

// A port of ruby Queue class.


@interface SemaphoredArray : NSObject
{
	dispatch_semaphore_t _array_semaphore;
	NSMutableArray * _que;
	NSMutableArray * _waiting;
}

-(void) push:(id) obj;
-(id)  pop;
-(id) initWithSemaphore:(dispatch_semaphore_t) sema;
@end