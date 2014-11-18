//
// HYWebService.h
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

#import "ManagedObjectProtocol.h"
#import "HYOCCProtocol.h"

@protocol HYObjectProtocol;

@interface HYWebService:NSObject<HYOCCProtocol>

/// Singleton access to this class
+ (HYWebService *)shared;

/// The data fetch progress
@property (nonatomic) float progress;

/**
 *  Fetch further items for the query.
 */
- (void)fetchFurtherItems:(HYQuery *)query withCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;

/**
 *  Predictive search
 */
- (void)suggestionsForQuery:(NSString *)query completionBlock:(NSArrayBlock)completionBlock;


@end
