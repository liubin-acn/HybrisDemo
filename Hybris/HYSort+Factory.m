//
// HYSort+Factory.m
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

@implementation HYSort (Factory)

+ (HYSort *)objectWithInfo:(NSDictionary *)sortInfo {
    HYSort *sortItem = [[HYSort alloc] init];

    [sortItem setValuesForKeysWithDictionary:sortInfo];

    sortItem.internalName = [sortInfo valueForKey:@"code"];
    sortItem.internalClass = NSStringFromClass([HYSort class]);
    sortItem.creationTime = [NSDate date];
    sortItem.lastPopulated = [NSDate date];

    // Select in query?
    Boolean selected = [[sortInfo objectForKey:@"selected"] boolValue];

    if (selected) {
        sortItem.query.selectedSort = sortItem;
    }

    return sortItem;
}


@end
