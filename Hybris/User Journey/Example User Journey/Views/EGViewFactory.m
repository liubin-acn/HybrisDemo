//
// EGViewFactory.m
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

#import "EGViewFactory.h"
#import "EGButton.h"
#import "EGLabel.h"

@implementation EGViewFactory

PureSingleton(EGViewFactory);

+ (NSDictionary *)prototypeDictionary {
    return [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
            [EGLabel class],
            [EGButton class],
            nil]
        forKeys:[NSArray arrayWithObjects:
            [HYLabel class],
            [HYButton class],
            nil]];
}


@end
