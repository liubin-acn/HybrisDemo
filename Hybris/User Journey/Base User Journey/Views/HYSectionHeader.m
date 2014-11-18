//
// HYSectionHeader.m
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

@implementation HYSectionHeader

@synthesize label = _label;

- (id)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 33.0)];
        _label.textAlignment = UITextAlignmentLeft;
        _label.text = title;
        _label.font = UIFont_defaultFont;
        _label.textColor = UIColor_textColor;
        _label.backgroundColor = UIColor_standardTint;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.baselineAdjustment = UIBaselineAdjustmentNone;
        [self addSubview:_label];
    }

    return self;
}


@end
