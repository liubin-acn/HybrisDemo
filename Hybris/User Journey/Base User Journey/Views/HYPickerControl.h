//
// HYPickerControl.h
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

@interface HYPickerControl:UIView<UIPickerViewDelegate, UIPickerViewDataSource>

+ (void)showPickerWithValues:(NSArray *)values labels:(NSArray *)labels index:(NSInteger) index completionBlock:(NSIntegerBlock)completionBlock;

/// Returns an array of strings from a set of numbers
+ (NSMutableArray *)arrayFromQuantity:(NSInteger) quantity withZero:(BOOL)includeZero;

@end
