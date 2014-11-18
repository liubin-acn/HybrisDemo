//
// HYScrollingTileBar.h
// ATGMobile

#import "ScrollingTileBar.h"
#import "ZZPageControl.h"

@interface HYScrollingTileBar:ScrollingTileBar

@property (nonatomic, readwrite) NSUInteger resumeDelay;
@property (nonatomic, readwrite) NSUInteger initialDelay;
@property (nonatomic, readwrite) NSUInteger animationDuration;
@property (nonatomic, readwrite) NSUInteger perBannerDuration;
@property (nonatomic, readwrite) NSUInteger lastAnimationDuration;
@property (nonatomic, retain)    IBOutlet ZZPageControl *pageIndicator;
@property (nonatomic, retain)    NSDate *lastMovedDate;
@property (nonatomic, retain)    IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)startAutoScrollWithInitialDelay:(NSUInteger) _initialDelay animationDuration:(NSUInteger) _animationDuration perBannerDuration:(NSUInteger)
   _perBannerDuration;
- (void)autoScrollToNext;
- (NSUInteger)indexForFirstVisibleTile;
- (void)scrollToTile:(NSUInteger) index withAnimation:(BOOL)animated;
- (void)scrollForward;

@end
