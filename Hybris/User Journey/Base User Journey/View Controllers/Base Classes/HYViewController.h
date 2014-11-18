//
// HYViewController.h
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
#import "IASKAppSettingsViewController.h"


/**
 *  Styled subclass of UITableViewController.
 *
 *  Use this for complex table views by adding UITableViewDelegate and UITableViewDataSource
 *  protocols.
 *
 *  Responds to two-finger horizontal swipe gesture for settings.
 */
@interface HYViewController:UIViewController<IASKSettingsDelegate>


/**
 *  Perform any additional setup for the view controller, after being created
 *  programatically or from a nib/storyboard.
 */
- (void)setup;

/**
 *  Set plain back button
 */
- (void)setShowPlainBackButton:(BOOL)show;

/**
 * Reachability callback
 */
- (void)reachabilityChanged:(Reachability *)reachability;

@end
