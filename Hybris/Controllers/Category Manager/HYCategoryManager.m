//
// HYCategoryManager.m
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

#import "HYCategoryManager.h"

static HYCategory *rootCategory;

@interface HYCategoryManager ()


/**
 *  Process the category data into HYCategory objects
 *  @param data The category data
 *  @param parent A root category
 *  @param context A managed object context
 */
+ (void)processArray:(NSArray *)data parent:(HYCategory *)parent;
@end

@implementation HYCategoryManager

#pragma mark - Public Methods
+ (void)reloadCategoriesFromPlist:(NSURL *)plistPath {
    NSArray *data = [PListSerialisation dataFromPlistAtPath:plistPath];

    logInfo(@"Presetting categories from PList.");
    rootCategory = [HYCategory objectWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
            @"Root Category", @"name"
            , nil]
        ];
    [HYCategoryManager processArray:data parent:rootCategory];
}


#pragma mark - Private Methods
+ (void)processArray:(NSArray *)data parent:(HYCategory *)parent {

    for (NSArray *array in data) {
        HYCategory *category;
        NSMutableDictionary *objectInfo = [[NSMutableDictionary alloc] init];

        [objectInfo setObject:[array objectAtIndex:1] forKey:@"name"];
        [objectInfo setObject:[array objectAtIndex:0] forKey:@"searchTag"];

        if (parent) {
            [objectInfo setObject:parent forKey:@"parent"];
        }

        category = [HYCategory objectWithInfo:objectInfo];

        if (array.count == 3) {
            [HYCategoryManager processArray:[array objectAtIndex:2] parent:category];
        }
    }
}


+ (HYCategory *)rootCategory {
    return rootCategory;
}


@end
