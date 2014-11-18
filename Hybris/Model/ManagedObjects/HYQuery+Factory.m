//
// HYQuery+Factory.m
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

@implementation HYQuery (Factory)

+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object {
}


+ (HYQuery *)query {
    HYQuery *query = [[HYQuery alloc] init];

    query.name = NSLocalizedString(@"Shop", nil);
    query.pageSize = [NSNumber numberWithInt:QUERY_PAGE_SIZE];
    query.currentPage = 0;
    query.queryString = @"";
    query.creationTime = [NSDate date];

    return query;
}


- (void)resetObject {
    self.currentPage = 0;
    self.totalPages = 0;
    self.totalResults = 0;
    NSMutableArray *keptItems = [[NSMutableArray alloc] init];

    for (HYItem *item in self.items) {
        if ([item isKindOfClass:[HYCategory class]]) { // || [item isKindOfClass:[HYFacet class]]) {
            [keptItems addObject:item];
        }
    }

    self.items = [NSMutableArray arrayWithArray:keptItems];
}


@end
