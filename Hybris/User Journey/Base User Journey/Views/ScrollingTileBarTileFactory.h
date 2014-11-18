#import <Foundation/Foundation.h>
#import "HYScrollingTileBarTile.h"

@interface ScrollingTileBarTileFactory:NSObject

@property (nonatomic, weak) IBOutlet HYScrollingTileBarTile *tile;

+ (HYScrollingTileBarTile *)initScrollingTileBarTileWithNib:(NSString *)nibName;

@end
