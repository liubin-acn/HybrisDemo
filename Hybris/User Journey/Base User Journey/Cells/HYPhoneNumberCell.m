//
// HYPhoneNumberCell.m
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


#import "HYPhoneNumberCell.h"


@implementation HYPhoneNumberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.button.backgroundColor = [UIColor clearColor];    
    self.button.titleLabel.textColor = UIColor_textColor;
    CGRectSetWidth(self.button.titleLabel.frame, self.button.frame.size.width);
   
}


@end
