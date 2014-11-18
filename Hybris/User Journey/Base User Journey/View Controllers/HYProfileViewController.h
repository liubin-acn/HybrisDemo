//
// HYProfileViewController.h
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

#import "HYTableViewController.h"
#import "ModalViewControllerDelegate.h"

@interface HYProfileViewController:HYTableViewController<ModalViewControllerDelegate>

@property (weak) id<ModalViewControllerDelegate>delegate;
- (IBAction)logout:(id)sender;
@property (weak, nonatomic) IBOutlet HYLabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet HYLabel *profileEmailLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logInOutButton;
@property (weak, nonatomic) IBOutlet HYLabel *notLoggedInLabel;

@end
