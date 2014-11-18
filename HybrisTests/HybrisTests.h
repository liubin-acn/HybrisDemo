//
// HybrisTests.h
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

#import <SenTestingKit/SenTestingKit.h>
#import "HYWebService.h"
#import "Logging.h"


static NSString *kLogin = @"test-account@redant.com";
static NSString *kPassword = @"password";


@interface HybrisTests : SenTestCase

// Helper methods
- (void)logInAndWait;
- (void)logOutAndWait;

@end
