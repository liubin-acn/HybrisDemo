#import "HYScrollingTileBarTile.h"
#import "HYScrollingTileBar.h"

@implementation HYScrollingTileBarTile

- (void)setup {
    self.backgroundView.backgroundColor = UIColor_backgroundColor;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (void)setDelegate:(ScrollingTileBar<ScrollingTileBarTileDelegate> *)aDelegate {
    _delegate = aDelegate;
    [self addTarget:self action:@selector(touchUpInside:)forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchDown:)forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUp:)forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}


- (void)touchDown:(id)sender {
    self.selected = YES;
}


- (void)touchUp:(id)sender {
    // Hide the touched background
    self.selected = NO;
}


- (void)touchUpInside:(id)sender {
    [self.delegate didSelectTile:self];
}


- (void)setSelected:(BOOL)newSelected {
    [self setSelected:newSelected animated:NO];
}


- (void)setSelected:(BOOL)newSelected animated:(BOOL)animated {
    [super setSelected:newSelected];

    if (self.selected) {
        // Show the touched background
        [self.backgroundView removeFromSuperview];
        [self insertSubview:self.selectedBackgroundView atIndex:0];
    }
    else{
        [self.selectedBackgroundView removeFromSuperview];
        [self insertSubview:self.backgroundView atIndex:0];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.numberOfTapsRequired == 1) {
        [self.delegate didTapWithTile:self];
    }
}


@end
