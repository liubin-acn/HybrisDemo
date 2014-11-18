//
// HYQuery+Factory.h
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

#import "HYItem+Factory.h"
#import "HYQuery.h"
#import "ManagedObjectProtocol.h"

@interface HYQuery (Factory)<HYObjectProtocol>


/**
 *  Create a new, default, empty query object.
 *  @param context the managed object context to use
 *  @return a HYQuery object
 */
+ (HYQuery *)query;
- (void)resetObject;

@end
