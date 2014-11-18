//
// HYOCCMiscTests.m
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


@interface HYOCCMiscTests : HybrisTests

@end


@implementation HYOCCMiscTests

#pragma mark - Misc methods

- (void)test280GetLanguages {
    __block int done = 0;

    //1. Get languages
    [[HYWebService shared] languagesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, nil);
            STAssertTrue (array.count, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test290GetCurrencies {
    __block int done = 0;

    [[HYWebService shared] currenciesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, nil);
            STAssertTrue (array.count, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test300GetCountries {
    __block int done = 0;

    [[HYWebService shared] countriesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue (array.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test310GetCardTypes {
    __block int done = 0;

    [[HYWebService shared] cardTypesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue (array.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test320GetTitles {
    __block int done = 0;

    [[HYWebService shared] titlesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue (array.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)testStoresWithString {
    __block int done = 0;

    [[HYWebService shared] storesWithQueryString:@"tokyo" withCurrentPage:0 completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertTrue (dict.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)testStoresWithLocation {
    __block int done = 0;

    CLLocation *location = [[CLLocation alloc] initWithLatitude:139.69 longitude:35.65];

    [[HYWebService shared] storesAtLocation:location withCurrentPage:0 radius:5000 completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertTrue (dict.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

@end
