//
// HYProductNameCell.m
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


#import "HYProductNameCell.h"


@implementation HYProductNameCell

@synthesize label;


- (void)awakeFromNib {
    [super awakeFromNib];

    // Reset all fields to remove examples from storyboard
    self.label.text = @"";
    self.label.font = UIFont_defaultFont;
    self.label.textColor = UIColor_textColor;
}

@end
