//
// HYUserInformation.m
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

#import "HYUserInformation.h"

@implementation HYUserInformation

static NSMutableOrderedSet *_previousSearches;

+ (NSArray *)previousSearches {
    // Lazy instantiation from user defaults
    if (!_previousSearches) {
        _previousSearches = [[NSMutableOrderedSet alloc] init];
        [_previousSearches addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"previous_searches"]];
    }

    return [_previousSearches array];
}


+ (void)addPreviousSearch:(NSString *)searchString {
    // Lazy instantiation from user defaults
    if (!_previousSearches) {
        _previousSearches = [[NSMutableOrderedSet alloc] init];
        [_previousSearches addObjectsFromArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"previous_searches"]];
    }

    // Trim if full
    if (_previousSearches.count > MAX_PREVIOUS_SEARCHES) {
        [_previousSearches removeObjectAtIndex:0];
    }

    // Add and save
    [_previousSearches addObject:searchString];
    [[NSUserDefaults standardUserDefaults] setObject:[_previousSearches array] forKey:@"previous_searches"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)clearPreviousSearches {
    if (_previousSearches) {
        [_previousSearches removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:_previousSearches forKey:@"previous_searches"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@end
