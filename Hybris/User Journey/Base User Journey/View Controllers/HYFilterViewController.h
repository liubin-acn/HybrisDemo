//
// HYFilterViewController.h
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

@class HYQuery;

@interface HYFilterViewController:HYTableViewController

@property (weak) id<ModalViewControllerDelegate>delegate;
@property (nonatomic, strong) HYQuery *query;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearAllFiltersButton;

- (IBAction)dismiss:(id)sender;
- (IBAction)clearAllFilters:(id)sender;

@end
