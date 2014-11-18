//
// HYBasicAttributedCell.h
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
#import "TTTAttributedLabel.h"
#import "HYTableViewCell.h"


@interface HYBasicAttributedCell : HYTableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *label;
@property (strong, nonatomic, readonly) UIView *separatorLine;
@property (strong, nonatomic, readonly) UIView *highlightedSeparatorLine;

- (void)decorateCellLabelWithContents:(id)contents;
+ (CGFloat)heightForCellWithContents:(id)contents;
- (void)setup;

@end
