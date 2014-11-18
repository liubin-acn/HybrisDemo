#import "HYScrollingTileBar.h"

@interface HYScrollingTileBar ()
@property (nonatomic) BOOL animating;
@end

@implementation HYScrollingTileBar

- (void)awakeFromNib {
    [super awakeFromNib];

    // set sensible defaults
    self.initialDelay = 10;
    self.resumeDelay = 5;
    self.animationDuration = 1;
    self.perBannerDuration = 3;
    self.pageIndicator.layer.cornerRadius = 10;
    self.pageIndicator.activeColor = UIColor_standardTint;
    self.pageIndicator.inactiveColor = UIColor_cellBackgroundColor;
    self.activityIndicator.hidden = YES;
}


- (void)startAutoScrollWithInitialDelay:(NSUInteger)initialDelay animationDuration:(NSUInteger)animationDuration perBannerDuration:(NSUInteger)
   perBannerDuration {
    self.initialDelay = initialDelay;
    self.animationDuration = animationDuration;
    self.perBannerDuration = perBannerDuration;
    self.lastMovedDate = [NSDate date];
    self.lastAnimationDuration = _initialDelay;
    [self performSelector:@selector(autoScrollToNext)withObject:nil afterDelay:self.initialDelay];
}


- (void)reloadDataWithAnimation:(BOOL)animated {
    [super reloadDataWithAnimation:animated];

    if (tiles.count != 0) {
        [self.activityIndicator stopAnimating];
    }

    self.pageIndicator.hidden = tiles.count <= 1;

    if (tiles.count > 0) {
        self.pageIndicator.numberOfPages = tiles.count;
        self.pageIndicator.currentPage = 0;
        self.pageIndicator.hidesForSinglePage = NO;
        // dynamically readjust pageindictator
        CGRect piFrame = self.pageIndicator.frame;
        piFrame.size = [self.pageIndicator sizeForNumberOfPages:tiles.count];
        piFrame.size.height = 20;
        piFrame.size.width = piFrame.size.width+20; // add curved padding
        piFrame.origin.x = (self.frame.size.width - piFrame.size.width)/2; // centre

        self.pageIndicator.frame = piFrame;
    }
}


- (NSUInteger)indexForFirstVisibleTile {
    if (tiles.count > 0) {
        // find a tile
        HYScrollingTileBarTile *newTile = [tiles objectAtIndex:0];
        CGFloat tileWidth = newTile.frame.size.width+1;

        CGFloat centerPos = CGRectGetMidX(self.scrollView.bounds);

        NSUInteger firstVisibleTileIndex = floor(centerPos / tileWidth);

        return firstVisibleTileIndex;
    }
    else{
        return 0;
    }
}


#pragma mark -
#pragma mark ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [super scrollViewDidScroll:aScrollView];
    self.pageIndicator.currentPage = [self indexForFirstVisibleTile];
    self.lastMovedDate = [NSDate date];
}


- (void)scrollToTile:(NSUInteger)index withAnimation:(BOOL)animated {
    if (!self.animating) {
        if (tiles.count > 0) {
            HYScrollingTileBarTile *newTile = [tiles objectAtIndex:0];
            CGFloat tileWidth = newTile.frame.size.width+self.padding;

            if (animated) {
                self.animating = YES;
                [UIView animateWithDuration:_animationDuration animations:^{
                        self.scrollView.contentOffset = CGPointMake ((index * tileWidth), 0);
                    }
                    completion:^(BOOL finished) {
                        self.animating = NO;
                    }];
            }
            else {
                self.scrollView.contentOffset = CGPointMake ((index * tileWidth), 0);
            }
        }
    }
}

- (void)autoScrollToNext {
    NSUInteger tileCount = [self.datasource numberOfTilesInScrollingTileBar:self];

    if (tileCount > 0) {
        // capture last moved before doing animation
        NSTimeInterval timeSinceLastMoved = ABS([self.lastMovedDate timeIntervalSinceNow]);

        // IF THE USER HAS TOUCHED VIEW SINCE LAST MOVE WAIT FOR INITAL DELAY AGAIN
        if ((self.lastAnimationDuration - timeSinceLastMoved) > 0.5) {
            // if moved by user then have initial delay again
            self.lastAnimationDuration = self.resumeDelay+self.animationDuration;
            [self performSelector:@selector(autoScrollToNext)withObject:nil afterDelay:self.lastAnimationDuration];
        }
        else if (tiles.count > 0) {
            // USER HAS NOT MOVED THE VIEW SO AUTO SCROLL

            // First pass loads the tiles and sizes
            HYScrollingTileBarTile *newTile = [tiles objectAtIndex:0];
            CGFloat tileWidth = newTile.frame.size.width+self.padding;

            // work out offset
            CGFloat lastOffset = ((int)self.scrollView.contentOffset.x % (int)tileWidth);

            // work out last start
            CGFloat lastStart = ((int)self.scrollView.contentOffset.x) - lastOffset;

            CGFloat end = ((tileCount-1) * (tileWidth));

            if (lastStart < end) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDuration:self.animationDuration];
                [UIView setAnimationDelay:UIViewAnimationCurveEaseInOut];

                self.scrollView.contentOffset = CGPointMake(tileWidth+ lastStart, 0);
                [UIView commitAnimations];
                // If offset.x + width = contentWidth we don't need the right bar
                [self showRightMoreMarker:((tileWidth+ lastStart) < end) animated:YES];
            }
            else{
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDuration:self.animationDuration];
                [UIView setAnimationDelay:UIViewAnimationCurveEaseInOut];

                self.scrollView.contentOffset = CGPointMake(0, 0);
                [UIView commitAnimations];

                [self scrollViewDidScroll:self.scrollView];
            }

            self.lastAnimationDuration = self.perBannerDuration+self.animationDuration;
            [self performSelector:@selector(autoScrollToNext)withObject:nil afterDelay:self.lastAnimationDuration];
        }
    }
}


- (void)scrollForward {
    NSUInteger tileCount = [self.datasource numberOfTilesInScrollingTileBar:self];

    if (tileCount > 0) {
        // USER HAS NOT MOVED THE VIEW SO AUTO SCROLL

        // First pass loads the tiles and sizes
        HYScrollingTileBarTile *newTile = [tiles objectAtIndex:0];
        CGFloat tileWidth = newTile.frame.size.width+self.padding;

        // work out offset
        CGFloat lastOffset = ((int)self.scrollView.contentOffset.x % (int)tileWidth);

        // work out last start
        CGFloat lastStart = ((int)self.scrollView.contentOffset.x) - lastOffset;

        CGFloat end = ((tileCount-1) * (tileWidth));

        if (lastStart < end) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:self.animationDuration];
            [UIView setAnimationDelay:UIViewAnimationCurveEaseInOut];

            self.scrollView.contentOffset = CGPointMake(tileWidth+ lastStart, 0);
            [UIView commitAnimations];
            // If offset.x + width = contentWidth we don't need the right bar
            [self showRightMoreMarker:((tileWidth+ lastStart) < end) animated:YES];
        }
        else{
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:self.animationDuration];
            [UIView setAnimationDelay:UIViewAnimationCurveEaseInOut];

            self.scrollView.contentOffset = CGPointMake(0, 0);
            [UIView commitAnimations];

            [self scrollViewDidScroll:self.scrollView];
        }
    }
}


@end
