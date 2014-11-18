//
// HYSharableObject.m
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

@interface HYSharableObject ()
@end

@implementation HYSharableObject

- (id)init {
    return [super init];
}


- (id)initWithString:(NSString *)string {
    self = [self init];

    if (self) {
        self.text = string;
    }

    return self;
}


- (id)initWithDictionary:(NSMutableDictionary *)dict {
    self = [self init];

    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }

    return self;
}


@end
