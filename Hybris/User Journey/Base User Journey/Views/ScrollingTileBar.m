#import "ScrollingTileBar.h"

@implementation ScrollingTileBar

- (void)awakeFromNib {
    if (!_scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self insertSubview:self.scrollView atIndex:0];
        self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
    }

    self.padding = 1;
    self.scrollView.delegate = self;
    tiles = [[NSMutableArray alloc] initWithCapacity:0];
    [self reloadData];
}


- (void)reloadData {
    [self reloadDataWithAnimation:NO];
}


- (void)reloadDataWithAnimation:(BOOL)animated {
    // Remove all tiles in the scroll view
    for (UIView *aSubview in self.scrollView.subviews) {
        [aSubview removeFromSuperview];
    }

    // Remove all cached tiles
    [tiles removeAllObjects];

    //TODO: Load these as needed
    CGFloat xPosition = 0;
    NSUInteger tileCount = [self.datasource numberOfTilesInScrollingTileBar:self];
    float firstTileWidth = 0;

    self.scrollView.scrollEnabled = (tileCount > 1);

    // First pass loads the tiles and sizes
    HYScrollingTileBarTile *newTile = nil;

    for (int i = 0; i < tileCount; i++) {
        newTile = [self.datasource scrollingTileBar:self tileForTileAtIndex:i];
        [tiles addObject:newTile];

        CGFloat tileWidth = newTile.frame.size.width;

        if (i == 1) {
            firstTileWidth = tileWidth;
        }

        newTile.frame = CGRectMake(newTile.frame.origin.x, 0, tileWidth, self.scrollView.bounds.size.height);

        xPosition += tileWidth + self.padding;
    }

    if (self.centerFirstTile) {
        self.initialOffset = (self.frame.size.width - firstTileWidth)/2;
    }

    // Set the content size accordingly
    // Added additional padding to the content size for the right hand side
    self.scrollView.contentSize = CGSizeMake(xPosition + self.initialOffset + self.initialOffset, self.scrollView.bounds.size.height);

    // Second pass animates tile addition now sizing is known
    xPosition = self.initialOffset;

    for (int i = 0; i < tileCount; i++) {
        newTile = [tiles objectAtIndex:i];

        CGSize tileTargetSize = newTile.frame.size;

        CGRect aFrame = CGRectMake(xPosition, 0, tileTargetSize.width, tileTargetSize.height);

        newTile.frame = aFrame;
        newTile.alpha = 0.0;

        [self.scrollView addSubview:newTile];

        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:1.5];
            [UIView setAnimationDelegate:nil];
        }

        newTile.frame = aFrame;
        newTile.alpha = 1.0;

        if (animated) {
            [UIView commitAnimations];
        }

        xPosition += tileTargetSize.width + self.padding;
        newTile.delegate = self;
    }

    // Scroll to the left
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    // Set up the more markers
    [self showLeftMoreMarker:NO animated:NO];
    [self showRightMoreMarker:(xPosition > self.scrollView.frame.size.width) animated:NO];

    // Notify the delegate we moved, if appropriate
    if ([(NSObject *)self.delegate conformsToProtocol:@protocol(ScrollingTileBarDelegate)]) {
        [self.delegate scrollingTileBarDidScroll:self];
    }
}


- (void)scrollToStart:(BOOL)animated {
    [self.scrollView scrollRectToVisible:self.frame animated:animated];
}


#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    // If offset.x > 0, we need the left bar
    [self showLeftMoreMarker:(self.scrollView.contentOffset.x > 0) animated:YES];

    // If offset.x + width = contentWidth we don't need the right bar
    [self showRightMoreMarker:((self.scrollView.contentOffset.x + self.scrollView.frame.size.width) < self.scrollView.contentSize.width) animated:YES];
}


#pragma mark -
#pragma mark Side Marker Animation
- (void)showLeftMoreMarker:(BOOL)show animated:(BOOL)animated {
    if ((show) && (self.leftMoreView.alpha == 1.0)) {
        return;
    }

    if ((!show) && (self.leftMoreView.alpha == 0.0)) {
        return;
    }

    if (show) {
        if (animated) {
            [ScrollingTileBar beginAnimations:nil context:nil];
            [ScrollingTileBar setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [ScrollingTileBar setAnimationDuration:0.3];
            [ScrollingTileBar setAnimationDelegate:nil];
        }

        //self.leftMoreView.frame = CGRectMake(0, 0, self.leftMoreView.frame.size.width, self.leftMoreView.frame.size.height);
        self.leftMoreView.alpha = 1.0;

        if (animated) {
            [ScrollingTileBar commitAnimations];
            [ScrollingTileBar setAnimationDuration:0.2];
        }
    }
    else{
        if (animated) {
            [ScrollingTileBar beginAnimations:nil context:nil];
            [ScrollingTileBar setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [ScrollingTileBar setAnimationDuration:0.3];
            [ScrollingTileBar setAnimationDelegate:nil];
        }

        //self.leftMoreView.frame = CGRectMake(-self.leftMoreView.frame.size.width, 0, self.leftMoreView.frame.size.width, self.leftMoreView.frame.size.height);
        self.leftMoreView.alpha = 0.0;

        if (animated) {
            [ScrollingTileBar commitAnimations];
            [ScrollingTileBar setAnimationDuration:0.2];
        }
    }
}


- (void)showRightMoreMarker:(BOOL)show animated:(BOOL)animated {
    if ((show) && (self.rightMoreView.alpha == 1.0)) {
        return;
    }

    if ((!show) && (self.rightMoreView.alpha == 0.0)) {
        return;
    }

    if (show) {
        if (animated) {
            [ScrollingTileBar beginAnimations:nil context:nil];
            [ScrollingTileBar setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [ScrollingTileBar setAnimationDuration:0.3];
            [ScrollingTileBar setAnimationDelegate:nil];
        }

        //self.rightMoreView.frame = CGRectMake(self.frame.size.width - self.rightMoreView.frame.size.width, 0, self.leftMoreView.frame.size.width,
        // self.leftMoreView.frame.size.height);
        self.rightMoreView.alpha = 1.0;

        if (animated) {
            [ScrollingTileBar commitAnimations];
        }
    }
    else {
        if (animated) {
            [ScrollingTileBar beginAnimations:nil context:nil];
            [ScrollingTileBar setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [ScrollingTileBar setAnimationDuration:0.3];
            [ScrollingTileBar setAnimationDelegate:nil];
        }

        //self.rightMoreView.frame = CGRectMake(self.frame.size.width + self.leftMoreView.frame.size.width, 0, self.leftMoreView.frame.size.width,
        // self.leftMoreView.frame.size.height);
        self.rightMoreView.alpha = 0.0;

        if (animated) {
            [ScrollingTileBar commitAnimations];
        }
    }
}


#pragma mark -
#pragma mark ScrollingTileBarTileDelegate
- (void)didSelectTile:(HYScrollingTileBarTile *)aTile {
    NSUInteger tileIndex = [tiles indexOfObject:aTile];

    [self.datasource scrollingTileBar:self didSelectTileAtIndex:tileIndex];
}


- (void)didTapWithTile:(HYScrollingTileBarTile *)aTile {
    NSUInteger tileIndex = [tiles indexOfObject:aTile];

    [self.delegate didTapTileWithIndex:tileIndex];
}


@end
