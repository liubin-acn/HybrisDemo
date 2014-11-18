//
// HYMiscTests.m
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

#import "HybrisTests.h"


@interface HYMiscTests : HybrisTests

@end


@implementation HYMiscTests

- (void)testAppDelegate {
    HYAppDelegate *applicationDelegate = (HYAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    STAssertNotNil(applicationDelegate, @"UIApplication failed to find the AppDelegate");
}

@end
