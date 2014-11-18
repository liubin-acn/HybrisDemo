//
// HYArrayViewController.h
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

@interface HYArrayViewController:HYTableViewController

@property (nonatomic, strong) NSArray *details;
@property (nonatomic, strong) NSString *classType;
@property (nonatomic, strong) NSString *key;
@property (nonatomic) BOOL canSelect;
@property (nonatomic) NSInteger selectedItem;

// Reimplement in subclass
- (void)itemWasSelected;

@end
