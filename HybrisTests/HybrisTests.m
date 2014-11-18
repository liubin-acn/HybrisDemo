//
// HybrisTests.m
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


@implementation HybrisTests

- (void)setUp {
    [super setUp];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //[userDefaults setValue:@"https://mapi.hybris.com:9002" forKey:@"web_services_base_url_preference"];
    //Hybris test by bin
    [userDefaults setValue:@"https://mobiledev.hybris.com:9002" forKey:@"web_services_base_url_preference"];
//    [userDefaults setValue:@"http://electronics.local:9001" forKey:@"web_services_base_url_preference"];
    //[userDefaults setValue:@"https://earlybird.hybris.com:9002" forKey:@"web_services_base_url_preference"];
    [userDefaults setValue:@"en" forKey:@"web_services_language_preference"];
    [userDefaults setValue:@"USD" forKey:@"web_services_currency_preference"];
    [userDefaults setValue:@"electronics/" forKey:@"web_services_site_url_suffix_preference"];
    
    [userDefaults synchronize];
}


- (void)tearDown {
    [super tearDown];
}



#pragma mark - Helper Methods

// Synchronous log in with test user
- (void)logInAndWait {
    __block int done = 0;
    
    // 1. Register
    [[HYWebService shared] registerCustomerWithFirstName:@"Red" lastName:@"Ant" titleCode:@"mr" login:kLogin password:kPassword completionBlock:^(NSError *
                                                                                                                                                  error) {
        // Allow this to fail if the user exists
        done = 1;
    }];
    
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    done = 0;
    
    // 2. Log in
    [[HYWebService shared] loginWithUsername:kLogin password:kPassword completionBlock:^(NSError *error) {
        STAssertNil (error, [error description]);
        done = 1;
    }];
    
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    done = 0;
}


// Synchronous log out
- (void)logOutAndWait {
    __block int done = 0;
    
    // 1. Log out
    [[HYWebService shared] logoutWithCompletionBlock:^(NSError *error) {
        STAssertNil (error, [error description]);
        done = 1;
    }];
    
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
