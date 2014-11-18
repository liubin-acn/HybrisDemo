//
// HYCategoryManager.h
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


/**
 *  Class methods to manage fixed category creation
 */

@interface HYCategoryManager:NSObject


/**
 *  Populate the store with fixed categories from a PList file. This method refreshes all the previously loaded categories in the store.
 *  @param plistPath The URL path to the PList file to reloaded the fixed categories(Facets).
 *  @param context The managed object context.
 */
+ (void)reloadCategoriesFromPlist:(NSURL *)plistPath;

+ (HYCategory *)rootCategory;

@end
