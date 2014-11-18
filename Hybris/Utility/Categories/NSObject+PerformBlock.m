//
//  NSObject+PerformBlock.m
//

@implementation NSObject (PerformBlock)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    int64_t delta = (int64_t)(1.0e9 * delay);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}


- (void)performBlock:(void (^)(void))block {
    int64_t delta = (int64_t)(1.0e9 * 0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}


- (void)performBackgroundBlock:(void (^)(void))block {
    int64_t delta = (int64_t)(1.0e9 * 0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}


- (void)performBackgroundBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    int64_t delta = (int64_t)(1.0e9 * delay);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}


@end
