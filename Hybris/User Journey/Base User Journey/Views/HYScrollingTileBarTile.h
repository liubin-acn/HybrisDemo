@class HYScrollingTileBarTile;
@protocol ScrollingTileBarTileDelegate

- (void)didSelectTile:(HYScrollingTileBarTile *)aTile;
- (void)didTapWithTile:(HYScrollingTileBarTile *)aTile;

@end

@class ScrollingTileBar;
@interface HYScrollingTileBarTile:UIControl<UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *selectedBackgroundView;
@property (nonatomic, weak) ScrollingTileBar<ScrollingTileBarTileDelegate> *delegate;

- (void)setSelected:(BOOL) newSelected animated:(BOOL)animated;

- (IBAction)handleTap:(UITapGestureRecognizer *)sender;

@end
