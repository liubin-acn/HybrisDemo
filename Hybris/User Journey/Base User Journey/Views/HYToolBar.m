//
// HYToolBar.m
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

#import "HYToolBar.h"

@implementation HYToolBar

- (void)setup {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.tintColor = UIColor_standardTint;
    }
}


- (void)awakeFromNib {
    [self setup];
}


- (id)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setup];
    }

    return self;
}


@end
