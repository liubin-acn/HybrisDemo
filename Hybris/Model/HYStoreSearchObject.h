//
// HYStoreSearchObject.h
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

typedef enum {
    ShopSearchNotStarted,
    ShopSearchSearching,
    ShopSearchSearchTermAmbiguous,
    ShopSearchComplete,
    ShopSearchFailed
} ShopSearchState;

@interface HYStoreSearchObject:NSObject

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) int distance;
@property (nonatomic) int totalResults;
@property (nonatomic) ShopSearchState searchState;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong)  NSString * storeName;
@property (nonatomic, strong)  NSString * storeAddressShort;
@property (nonatomic, strong)  NSString * storeAddressFull;
@property (nonatomic, strong)  NSString * storeDistance;
@property (nonatomic, strong)  NSArray * numberOfStores;
@property (nonatomic, strong)  NSString * phoneNumber;
@property (nonatomic, strong)  NSMutableArray *openingHours;
@property (nonatomic, strong)  NSMutableArray *features;
@property (nonatomic, strong)  NSURL *productImageUrl;


@end
