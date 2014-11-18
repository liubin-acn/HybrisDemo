//
// HYBlockAdditions.h
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

#ifndef Hybris_HYBlockAdditions_h
#define Hybris_HYBlockAdditions_h

/**
 * Block Typedefs
 **/

typedef void (^NSNotificationBlock)(NSNotification *notification);
typedef void (^NSArrayBlock)(NSArray *results);
typedef void (^NSErrorBlock)(NSError *error);
typedef void (^NSBoolBlock)(BOOL success);
typedef void (^NSIntegerBlock)(NSInteger result);
typedef void (^NSDataBlock)(NSData *data);
typedef void (^NSVoidBlock)(void);
typedef void (^NSBoolArrayBlock)(BOOL success, NSArray *objects);
typedef void (^NSBoolDictionaryBlock)(BOOL success, NSDictionary *dictionary);

typedef void (^NSArrayNSErrorBlock)(NSArray *array, NSError *error);
typedef void (^NSDictionaryNSErrorBlock)(NSDictionary *dictionary, NSError *error);
typedef void (^NSDataNSErrorBlock)(NSData *data, NSError *error);
#endif
