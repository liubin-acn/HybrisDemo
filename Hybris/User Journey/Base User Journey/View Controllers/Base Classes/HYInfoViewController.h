//
// HYInfoViewController.h
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

@interface HYInfoViewController:UIViewController

@property (nonatomic, strong) NSArray *allFields;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *allTypes;
@property (nonatomic, strong) UIScrollView *scrollView;

- (id)initWithTitle:(NSString *)myTitle fields:(NSArray *)fields values:(NSArray *)values types:(NSArray *)types;


/**
 * Return the view for a row
 */
- (UIView *)contentRowWithTitle:(NSString *)title content:(NSString *)content index:(NSUInteger) contentIndex yPosition:(NSUInteger)rowStart;

@end
