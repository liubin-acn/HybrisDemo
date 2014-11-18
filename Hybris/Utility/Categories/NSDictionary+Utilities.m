//
// NSDictionary+Utilities.m
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

@implementation NSDictionary (Utilities)

- (id)valueForKey:(NSString *)key withDefault:(id)defaultValue {
    id value = [self valueForKey:key];

    return value ? value : defaultValue;
}


@end
