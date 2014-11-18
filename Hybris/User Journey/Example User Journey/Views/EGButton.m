//
// EGButton.m
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

#import "EGButton.h"

@implementation EGButton

- (EGButton *)init {
    self = [super init];

    if (self) {
        // Custom styling can go here: e.g.
        self.titleLabel.textColor = [UIColor greenColor];
        self.titleLabel.backgroundColor = [UIColor grayColor];
        self.backgroundColor = [UIColor grayColor];
    }

    return self;
}


@end
