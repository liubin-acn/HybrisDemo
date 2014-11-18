//
// HYFormViewController.h
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
#import "HYPickerViewController.h"
#import "FormViewControllerDelegate.h"

@interface HYFormViewController:HYTableViewController<UITextFieldDelegate, HYPickerViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic, readonly) BOOL valid;
@property (nonatomic, weak) id<FormViewControllerDelegate>delegate;

- (id)initWithPlistNamed:(NSString *)plist;

@end
