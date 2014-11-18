//
// ManagedObjectProtocol.h
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


/**
 *  A Protocol to extend manaaged objects to make them compatible with the various
 *  controllers in the Hybris framework.
 */

#import <Foundation/Foundation.h>

@protocol HYObjectProtocol<NSObject>


/**
 *  The common name of the object.
 *
 *  Can be nil, for example if the item has not been populated
 */
//@property (nonatomic, strong) NSString *name;

/// The last time this item was populated (its children fetched). Can be nil.
//@property (nonatomic, strong) NSDate *lastPopulated;

/// The stated policy of this object for populating. Can be nil.
//@property (nonatomic, strong) NSNumber *populatePolicy;

/// The predicate to fetch to show the children view of this object
- (NSPredicate *)basePredicate;

@end
