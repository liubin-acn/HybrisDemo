//
// HYItem.h
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

@class HYItem, HYQuery;

@interface HYItem:HYObject

@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) NSString *internalClass;
@property (nonatomic, strong) NSDate *lastPopulated;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *populatePolicy;
@property (nonatomic) NSInteger sortRank;

//@property (nonatomic, strong) NSMutableSet *children;
//@property (nonatomic, strong) HYItem *parent;
//@property (nonatomic, strong) NSMutableSet *parents;

@property (nonatomic, strong) HYQuery *query;

@end
