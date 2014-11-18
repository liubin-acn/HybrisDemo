//
// HYUserInformation.h
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

@interface HYUserInformation:NSObject


/**
 * Returns a user's previous search strings
 * @return NSArray an array of strings. Will be an emoty array if there are none.
 */
+ (NSArray *)previousSearches;


/**
 * Add a previous search string
 */
+ (void)addPreviousSearch:(NSString *)searchString;


/**
 * cClear all previous searches
 */
+ (void)clearPreviousSearches;

@end
