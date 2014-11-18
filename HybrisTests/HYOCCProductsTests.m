//
// HYOCCProductsTests.m
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

#import "HYProduct+Factory.h"
#import "HybrisTests.h"


@interface HYOCCProductsTests : HybrisTests

@end


@implementation HYOCCProductsTests


#pragma mark - Product Tests

- (void)test010GetProducts {
    __block int done = 0;
    __block NSArray *objects;

    HYQuery *query = [HYQuery query];

    // 1. Set parameter pageSize
    query.pageSize = [NSNumber numberWithInt:20];

    // 2. Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 3. Ensure 20 products returned
    STAssertTrue (objects.count == 20, nil);

    // 4. set parameter currentPage
    query.currentPage = [NSNumber numberWithInt:1];

    // 5. Get more products
    __block NSArray *objectsPage2;
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            objectsPage2 = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:objects];
    [allObjects addObjectsFromArray:objectsPage2];

    // 6. Ensure 40 total products
    STAssertTrue (allObjects.count == 40, nil);

    // 5. Reset
    query = [HYQuery query];

    // 7. Set parameter pageSize
    query.pageSize = [NSNumber numberWithInt:50];

    // 8. Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 9. Ensure 50 products returned
    STAssertTrue (objects.count == 50, nil);

    // 10. Reset
    query = [HYQuery query];

    // 11. Set parameter query
    query.queryString = @"camera";

    // 12. Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test011GetProductsWithSort {
    __block int done = 0;
    __block NSArray *objects;

    HYQuery *query = [HYQuery query];

    // 1. Set parameters
    query.pageSize = [NSNumber numberWithInt:20];

    // 2. Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 3. Check sort options
    NSMutableArray *sortOptions = [[NSMutableArray alloc] init];

    for (id obj in query.items) {
        if ([obj isKindOfClass:[HYSort class]]) {
            [sortOptions addObject:obj];
        }
    }

    STAssertTrue (sortOptions.count > 0, nil);

    // 4. Set sort option
    query.selectedSort = [sortOptions lastObject];

    // 5. Get products again
    __block NSArray *sortedObjects;
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil (error, [error description]);
            sortedObjects = [results objectForKey:@"products"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test020GetProductByCode {
    __block int done = 0;
    __block NSArray *objects;

    // 2. Get product
    NSString *productCode = @"872912";
    [[HYWebService shared] productWithCode:productCode options:nil completionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = results;
            done = 1;
        }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Should return one product
    STAssertTrue (objects.count == 1, nil);
    STAssertTrue ([[objects objectAtIndex:0] isKindOfClass:[HYProduct class]], nil);
    HYProduct *product = (HYProduct *)[objects objectAtIndex:0];

    // Should have image data
    STAssertTrue (((NSArray *)product.galleryImageURLs).count > 0 || ((NSArray *)product.primaryImageURLs).count > 0, nil);

    // Code should match
    STAssertTrue ([productCode isEqualToString:product.productCode], nil);

    // 3. Get product with incorrect code
    productCode = @"345678903257893475934";
    [[HYWebService shared] productWithCode:productCode options:nil completionBlock:^(NSArray *results, NSError *error) {
            // Assume an error
            STAssertNotNil (error, [error description]);
            objects = results;
            done = 1;
        }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Should return no products
    STAssertTrue (objects.count == 0, nil);
}


- (void)test021GetProductByCodeWithOptions {
    __block int done = 0;
    __block NSArray *objects;

    // 2. get BASIC info
    NSString *productCode = @"23355";
    [[HYWebService shared] productWithCode:productCode options:[NSArray arrayWithObjects:HYProductOptionBasic, nil] completionBlock:^(NSArray *results,
            NSError *error) {
            STAssertNil (error, [error description]);
            objects = results;
            done = 1;
        }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Should return one product
    STAssertTrue (objects.count == 1, nil);
    STAssertTrue ([[objects objectAtIndex:0] isKindOfClass:[HYProduct class]], nil);
    HYProduct *product = (HYProduct *)[objects objectAtIndex:0];

    // Should have image data
    STAssertTrue (((NSArray *)product.galleryImageURLs).count > 0 || ((NSArray *)product.primaryImageURLs).count > 0, nil);

    // Code should match
    STAssertTrue ([productCode isEqualToString:product.productCode], nil);

    // Should not have review data yet
    STAssertFalse (product.reviews.count > 0, nil);

    // 3. get ALL info // NB REFERENCES not tested
    [[HYWebService shared] productWithCode:productCode options:[NSArray arrayWithObjects:HYProductOptionBasic, HYProductOptionCategories,
            HYProductOptionClassification, HYProductOptionDescription, HYProductOptionGallery, HYProductOptionPrice, HYProductOptionPromotions,
            HYProductOptionReview, HYProductOptionVariant,
            HYProductOptionStock, nil] completionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = results;
            done = 1;
        }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Should return one product
    STAssertTrue (objects.count == 1, nil);
    STAssertTrue ([[objects objectAtIndex:0] isKindOfClass:[HYProduct class]], nil);
    product = (HYProduct *)[objects objectAtIndex:0];

    // Code should match
    STAssertTrue ([productCode isEqualToString:product.productCode], nil);

    // Should have review data
    STAssertTrue (product.reviews.count > 0, nil);
    
    // Should have empty baseoption data variant for product from electronics catalog
    STAssertTrue (product.variantInfo.count == 0, nil);
}


- (void)testDidYouMean {
    __block int done = 0;

    HYQuery *query = [HYQuery query];

    query.pageSize = [NSNumber numberWithInt:20];
    query.queryString = @"camra"; //spelled wrong

    // Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNotNil ([results objectForKey:@"spellingSuggestion"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    query = [HYQuery query];
    query.pageSize = [NSNumber numberWithInt:20];
    query.queryString = @"camera"; //spelled correctly

    // Get products
    [[HYWebService shared] products:query completionBlock:^(NSDictionary *results, NSError *error) {
            STAssertNil ([results objectForKey:@"spellingSuggestion"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)testSpellingSuggestion {
    __block int done = 0;

    [[HYWebService shared] suggestionsForQuery:@"ca" completionBlock:^(NSArray *results) {
            STAssertTrue (results.count, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    [[HYWebService shared] suggestionsForQuery:@"d" completionBlock:^(NSArray *results) {
            STAssertTrue (results.count, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

@end
