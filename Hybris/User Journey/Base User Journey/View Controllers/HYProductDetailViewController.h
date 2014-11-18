//
// HYProductDetailViewController.h
// [y] hybris Platform
//
// Copyright (c) 2000-2013 hybris AG
// All rights reserved.
//
// This software is the confidential and proprietary information of hybris
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with hybris.
//

#import <UIKit/UIKit.h>
#import "ManagedObjectProtocol.h"
#import "HYShopTableViewController.h"
#import "ScrollingTileBar.h"
#import "HYScrollingTileBarTile.h"

@class HYProduct;
@class HYLabel;
@class HYTextView;

@interface HYProductDetailViewController:HYShopTableViewController<UIScrollViewDelegate, ScrollingTileBarDatasource, ScrollingTileBarDelegate,
    MWPhotoBrowserDelegate>{
}

// The tableview
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HYProduct *product;
@property (nonatomic, strong) UIImageView *thumbnail;

- (IBAction)onAddToCart:(id)sender;

- (void)refresh;

- (IBAction)onTweet:(id)sender;
- (IBAction)onFacebookPost:(id)sender;
- (IBAction)onMail:(id)sender;

@end
