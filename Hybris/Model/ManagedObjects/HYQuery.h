//
// HYQuery.h
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

#import <Foundation/Foundation.h>
#import "HYItem.h"


@class HYCategory, HYFacetValue, HYItem, HYSort;


@interface HYQuery : HYItem

@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *pageSize;
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) NSNumber *totalPages;
@property (nonatomic, strong) NSNumber *totalResults;
@property (nonatomic, strong) HYCategory *selectedCategory;
@property (nonatomic, strong) NSMutableSet *selectedFacetValues;
@property (nonatomic, strong) HYSort *selectedSort;

@property (nonatomic, strong) NSMutableArray *items;

@end
