//
// ViewFactory.h
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
#import "HYButton.h"
#import "HYLabel.h"
#import "HYProgressView.h"
#import "HYSearchBar.h"
#import "HYSectionHeader.h"
#import "HYFooterView.h"
#import "HYSearchResultsHeaderView.h"
#import "HYTextField.h"
#import "HYStarRatingView.h"

@interface ViewFactory:NSObject


/**
 *  Override point for a custom View Factory.
 *
 *  A dictionary of class-to-class keys and value should be returned, specifying what class to use for each Hybris class.
 *  For example, the key-value pair <HYLabel, EGLabel> means that an EGLabel will be created for any HYLabel
 *  used in the app.
 */
+ (NSDictionary *)prototypeDictionary;

/// Singleton accessor
+ (ViewFactory *)shared;

/// Returns a view factory with a prototype dictionary : pass nil for the default
+ (ViewFactory *)viewFactoryWithPrototypes:(NSDictionary *)prototypeDictionary;

#pragma mark - Factory Methods

- (id)make:(Class)className;
- (id)make:(Class) className withFrame:(CGRect)frame;

@end
