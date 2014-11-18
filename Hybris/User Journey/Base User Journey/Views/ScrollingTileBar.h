#import <Foundation/Foundation.h>
#import "HYScrollingTileBarTile.h"
#import "MWPhotoBrowser.h"

@class ScrollingTileBar;

@protocol ScrollingTileBarDatasource

- (NSUInteger)numberOfTilesInScrollingTileBar:(ScrollingTileBar *)aScrollingTileBar;

- (HYScrollingTileBarTile *)scrollingTileBar:(ScrollingTileBar *)aScrollingTileBar tileForTileAtIndex:(NSUInteger)tileIndex;

- (void)scrollingTileBar:(ScrollingTileBar *)aScrollingTileBar didSelectTileAtIndex:(NSUInteger)tileIndex;

@end

@protocol ScrollingTileBarDelegate

- (void)scrollingTileBarDidScroll:(ScrollingTileBar *)aScrollingTileBar;

- (void)didTapTileWithIndex:(NSInteger)tileIndex;

@end

@interface ScrollingTileBar:UIView<UIScrollViewDelegate, ScrollingTileBarTileDelegate>{
    NSMutableArray *tiles;
}

@property (nonatomic) float initialOffset; //NIB CUSTOMIZABLE
@property (nonatomic) BOOL centerFirstTile; //NIB CUSTOMIZABLE
@property (nonatomic) float padding; //NIB CUSTOMIZABLE
@property (nonatomic, retain) IBOutlet UIView *leftMoreView;
@property (nonatomic, retain) IBOutlet UIView *rightMoreView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) NSObject<ScrollingTileBarDatasource> *datasource;
@property (nonatomic, assign) IBOutlet id<ScrollingTileBarDelegate>delegate;

- (void)reloadData;
- (void)reloadDataWithAnimation:(BOOL)animated;
- (void)scrollToStart:(BOOL)animated;
- (void)showRightMoreMarker:(BOOL) show animated:(BOOL)animated;
- (void)showLeftMoreMarker:(BOOL) show animated:(BOOL)animated;

@end
