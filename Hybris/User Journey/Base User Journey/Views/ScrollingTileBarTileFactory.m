#import "ScrollingTileBarTileFactory.h"

@implementation ScrollingTileBarTileFactory

PureSingleton(ScrollingTileBarTileFactory)
+ (HYScrollingTileBarTile *)initScrollingTileBarTileWithNib:(NSString *)nibName {
    ScrollingTileBarTileFactory *factory = [ScrollingTileBarTileFactory shared];

    [[NSBundle mainBundle] loadNibNamed:nibName owner:factory options:nil];

    if (!factory.tile) {
        NSString *errorString = [NSString stringWithFormat:@"Factory failed to initialise a cell from NIB %@", nibName];
        NSAssert((factory.tile != nil), errorString);
    }

    HYScrollingTileBarTile *returnTile = factory.tile;
    return returnTile;
}


@end
