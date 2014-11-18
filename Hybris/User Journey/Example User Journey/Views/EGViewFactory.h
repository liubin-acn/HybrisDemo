//
// EGViewFactory.h
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

#import "ViewFactory.h"

@interface EGViewFactory:ViewFactory


/**
 *  Override point for a custom View Factory.
 *
 *  A dictionary of class-to-class should be returned, specifying what class to use for each Hybris class.
 *  For example, the key-value pair <HYLabel, EGLabel> means that an EGLabel will be created for any HYLabel
 *  used in the app.
 */
+ (NSDictionary *)prototypeDictionary;

@end
