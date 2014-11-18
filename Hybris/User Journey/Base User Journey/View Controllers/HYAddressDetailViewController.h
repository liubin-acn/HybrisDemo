//
// HYAddressDetailViewController.h
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

#import "FormViewControllerDelegate.h"
#import "HYFormViewController.h"

@interface HYAddressDetailViewController:HYFormViewController<FormViewControllerDelegate>
@property (nonatomic, weak) NSArray *titles;
@property (nonatomic, weak) NSArray *countries;

// add new address
- (id)initWithTitle:(NSString *)title;
// edit existing address. Pass in values to prefill form.
- (id)initWithTitle:(NSString *)myTitle values:(NSDictionary *)values;

@end
