//
// HYCheckoutSectionHeader.m
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

#import "HYCheckoutSectionHeader.h"

@implementation HYCheckoutSectionHeader

- (id)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.label = [[HYLabel alloc] initWithFrame:CGRectMake(14.0, 5.0, 310.0, 22.0)];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.text = title;
        self.label.font = [UIFont fontWithName : @ "Helvetica-Bold" size : 16.0f];
        self.label.textColor = UIColor_textColor;
        self.label.adjustsFontSizeToFitWidth = YES;
        self.label.baselineAdjustment = UIBaselineAdjustmentNone;
        self.label.backgroundColor = [UIColor clearColor];
        self.tickImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark@2x.png"]];
        self.tickImage.frame = CGRectMake(290, 10, 16, 16);
        self.tickImage.hidden = YES;
        [self addSubview:self.tickImage];
        [self addSubview:self.label];
    }
    
    return self;
}

@end
