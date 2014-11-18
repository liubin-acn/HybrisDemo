//
// HYButton.m
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

@implementation HYButton

- (void)setup {
    //self.backgroundColor = UIColor_highlightTint;

    [self setTitleColor:UIColor_buttonTextColor forState:UIControlStateNormal];
    [self setTitleColor:UIColor_brandTextColor forState:UIControlStateSelected];
    [self setTitleColor:UIColor_brandTextColor forState:UIControlStateHighlighted];
    [self setTitleColor:UIColor_disabledColor forState:UIControlStateDisabled];

    // Causes a crash on iOS 5.1
//    self.titleLabel.font = UIFont_buttonFont;

    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIColor_dividerBorderColor.CGColor;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (HYButton *)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)makeLinkStyle {
    [self setTitleColor:UIColor_buttonTextColor forState:UIControlStateNormal];
    [self setTitleColor:UIColor_brandTextColor forState:UIControlStateSelected];
    [self setTitleColor:UIColor_brandTextColor forState:UIControlStateHighlighted];
    [self setTitleColor:UIColor_disabledColor forState:UIControlStateDisabled];

    self.layer.cornerRadius = 0.0f;
    self.layer.borderWidth = 0.0f;

    self.titleLabel.font = UIFont_linkFont;
    self.backgroundColor = [UIColor clearColor];
}


@end
