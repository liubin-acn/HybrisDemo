//
// HYTextField.m
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

@implementation HYTextField

- (void)setup {
    self.textColor = UIColor_textColor;
}


- (void)awakeFromNib {
    [self setup];
}


- (HYTextField *)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


@end
