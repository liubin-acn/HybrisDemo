//
//  NSObject+PerformBlock.h
//

#import <Foundation/Foundation.h>

/**
 * Block helper methods
 * Dispatch blocks via GCD
 **/
@interface NSObject (PerformBlock)

- (void)performBlock:(void(^) (void)) block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void(^) (void))block;
- (void)performBackgroundBlock:(void(^) (void))block;
- (void)performBackgroundBlock:(void(^) (void)) block afterDelay:(NSTimeInterval)delay;

@end
