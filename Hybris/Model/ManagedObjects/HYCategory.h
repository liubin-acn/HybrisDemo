//
// HYCategory.h
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

@class HYQuery;

@interface HYCategory:HYItem

@property (nonatomic, strong) NSString *searchTag;
//@property (nonatomic, strong) NSMutableSet *selectedInQuery;

@property (nonatomic, strong) HYItem *parent;
@property (nonatomic, strong) NSMutableArray *childCategories;
@property (nonatomic, strong) NSMutableArray *products;

@end
