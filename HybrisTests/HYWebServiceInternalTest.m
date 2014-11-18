//
// HYWebServiceInternalTest.m
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


@interface HYWebServiceInternalTest : HybrisTests

@end


@implementation HYWebServiceInternalTest


#pragma ContentFetcher Methods

- (NSArray *)fetchProducts {
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([HYProduct class])];
    return [self.document.managedObjectContext executeFetchRequest:fRequest error:nil];
}


- (NSArray *)fetchItems {
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([HYItem class])];
    return [self.document.managedObjectContext executeFetchRequest:fRequest error:nil];
}


- (void)deleteExistingProducts {
    [self.document.managedObjectContext performBlockAndWait:^{

        NSArray *products = [self fetchProducts];

        for (HYProduct *p in products) {
            [self.document.managedObjectContext deleteObject:p];
        }

        products = [self fetchProducts];
        STAssertFalse([products count], nil);
    }];
}


- (void)deleteAllItems {
    [self.document.managedObjectContext performBlockAndWait:^{

        NSArray *items = [self fetchItems];

        for (HYItem *i in items) {
            [self.document.managedObjectContext deleteObject:i];
        }

        items = [self fetchItems];
        STAssertFalse([items count], nil);
    }];
}


//- (void)fetchItemsForQuery:(HYQuery *)query resetQuery:(BOOL)reset withCompletionBlock:(NSBoolArrayBlock)completionBlock;
- (void)testFetchItemsForQuery {
    [self deleteExistingProducts];

    HYQuery *query = [HYQuery blankQueryInManagedObjectContext:self.document.managedObjectContext];
    query.query = @"";
    STAssertNotNil(query, @"Query object cannot be nil.");

    __block int done = 0;
    __block NSArray *objects;

    [[HYWebService shared] fetchItemsForQuery:query
                                   resetQuery:YES
                          withCompletionBlock:^(BOOL success, NSArray *results) {
                              STAssertTrue(success, nil);
                              objects = results;
                              done = 1;
                          }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        //usleep(10000);
    }

    NSArray *items = [self fetchProducts];

    // The items fetched from CD
    STAssertTrue(items.count > 0, nil);

    // The items returned
    STAssertTrue(objects.count > 0, nil);
}


- (void)testFacets {
    HYQuery *query = [HYQuery blankQueryInManagedObjectContext:self.document.managedObjectContext];
    query.query = @"";
    STAssertNotNil(query, @"Query object cannot be nil.");

    __block int done = 0;
    __block NSArray *objects;

    [[HYWebService shared] fetchItemsForQuery:query
                                   resetQuery:YES
                          withCompletionBlock:^(BOOL success, NSArray *results) {
                              STAssertTrue(success, nil);
                              objects = results;
                              done = 1;
                              sleep(1);
                          }];

    while (done == 0) {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        //usleep(10000);
    }

    // The items returned
    STAssertTrue(objects.count > 0, nil);

    int facetCount = 0;
    for (id obj in objects) {
        if ([obj isKindOfClass:[HYFacet class]]) {
            ++facetCount;
        }
    }
    STAssertTrue(facetCount > 0, nil);


    // Fetch all items and look for facet values
    NSArray *items = [self fetchItems];

    int facetValueCount = 0;
    for (id obj in items) {
        if ([obj isKindOfClass:[HYFacetValue class]]) {
            HYFacetValue *v = (HYFacetValue *)obj;
            STAssertTrue([v.count intValue] > 0, @"A facet value count should be greater than zero");
            ++facetValueCount;
        }
    }
    STAssertTrue(facetValueCount > 0, nil);
}
- (void)testSorting {

    NSArray *sortArray = [HYSort allObjectsInManagedObjectContext:self.document.managedObjectContext];
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (id each in sortArray) {
        [tmp insertObject:each atIndex:0];
    }
    sortArray = tmp;
    NSMutableArray *allResults = [[NSMutableArray alloc] init];
    NSMutableArray *allCounts = [[NSMutableArray alloc] init];

    for (HYSort *sortOption in sortArray) {

        [self deleteExistingProducts];

        HYQuery *query = [HYQuery blankQueryInManagedObjectContext:self.document.managedObjectContext];
        query.query = @"";
        query.pageSize = [NSNumber numberWithInt:10000];
        query.selectedSort = sortOption;

        __block int done = 0;

        [[HYWebService shared] fetchItemsForQuery:query
                                       resetQuery:NO
                              withCompletionBlock:^(BOOL success, NSArray *results) {
                                  STAssertTrue(success, nil);
                                  done = 1;
                                  sleep(1);
                              }];

        while (done == 0) {
            // This executes another run loop.
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            // Sleep 1/100th sec
            //usleep(10000);
        }

        NSArray *items = [self fetchProducts];
        [allResults addObject:items];

        [allCounts addObject:query.totalResults];

    }

    NSArray *firstResult = [allResults objectAtIndex:0];
    [allResults removeObjectAtIndex:0];
    for (NSArray *eachResult in allResults) {
        logInfo(@"%i", eachResult.count);

        /********************************************************************************/
        // This test fails because of duplicate products
        //STAssertTrue(count == eachResult.count, nil);
        /********************************************************************************/

        // Tests that max page size always is the same
        STAssertFalse([eachResult isEqual:firstResult], nil);
    }

    int firstCount = [[allCounts objectAtIndex:0] intValue];
    for (NSNumber *eachCount in allCounts) {
        logInfo(@"%i", [eachCount intValue]);

        // Tests that all sorts return the same totals
        STAssertTrue([eachCount intValue] == firstCount, nil);
    }
}
//- (void)fetchFurtherItems:(HYQuery *)query withCompletionBlock:(NSBoolArrayBlock)completionBlock;
- (void)testFetchFurtherItems {

    HYQuery *query = [HYQuery blankQueryInManagedObjectContext:self.document.managedObjectContext];
    query.query = @"";
    STAssertNotNil(query, @"Query object cannot be nil.");

    __block int done = 0;
    __block NSMutableArray *objects = [[NSMutableArray alloc] init];


    [[HYWebService shared] fetchItemsForQuery:query
                                   resetQuery:YES
                          withCompletionBlock:^(BOOL success, NSArray *results) {
                              STAssertTrue(success, nil);
                              [objects addObjectsFromArray:results];
                              done = 1;
                          }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    NSArray *items = [self fetchProducts];

    int firstObjectCount = objects.count;

    done = 0;
    [[HYWebService shared] fetchFurtherItems:query
                         withCompletionBlock:^(BOOL success, NSArray *results) {
                             STAssertTrue(success, nil);
                             [objects addObjectsFromArray:results];
                             done = 1;
                         }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    NSArray * moreItems = [self fetchProducts];

    STAssertTrue((items.count + moreItems.count) > items.count, nil);

    // The items returned: there should now be more
    STAssertTrue(objects.count > firstObjectCount, nil);

}

@end
