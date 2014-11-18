//
// HYPickerViewController.h
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

@protocol HYPickerViewControllerDelegate
- (void)didSelectValue:(NSString *)value;
@end

@interface HYPickerViewController:HYTableViewController

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, weak) id<HYPickerViewControllerDelegate>delegate;

@end
