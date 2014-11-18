//
// HYCategory.m
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

@implementation HYCategory

- (id)init {
    self = [super init];

    self.childCategories = [NSMutableArray array];
    self.products = [NSMutableArray array];

    return self;
}


- (void)setParent:(HYItem *)parent {
    _parent = parent;

    if ([parent isKindOfClass:[HYCategory class]]) {
        [((HYCategory *)parent).childCategories addObject:self];
    }
}


@end
