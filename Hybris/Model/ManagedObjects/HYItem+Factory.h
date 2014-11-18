//
// HYItem+Factory.h
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

#import "HYItem.h"
#import "ManagedObjectProtocol.h"


// This is the most generic version of an item that can be viewed

@interface HYItem (Factory)<HYObjectProtocol>

// To be overridden
+ (void)decorateCell:(UITableViewCell *)cell withObject:(HYObject *)object;
+ (id)objectWithInfo:(NSDictionary *)info;
- (NSPredicate *)basePredicate;

@end
