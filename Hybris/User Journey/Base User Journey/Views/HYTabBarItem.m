//
// HYTabBarItem.m
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

#import "HYTabBarItem.h"

@implementation HYTabBarItem

- (void)setBadgeValue:(NSString *)badgeValue {
    if ([badgeValue intValue] == 0) {
        [super setBadgeValue:nil];
    }
    else {
        [super setBadgeValue:badgeValue];
    }
}


@end
