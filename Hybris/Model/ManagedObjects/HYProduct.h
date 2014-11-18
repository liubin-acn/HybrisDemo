//
// HYProduct.h
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
#import "HYItem.h"

@class Review;

@interface HYProduct:HYItem

@property (nonatomic, strong) NSNumber *averageRating;
@property (nonatomic, strong) NSMutableArray *classifications; // array of dict
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *displayPrice;
@property (nonatomic, strong) NSMutableArray *galleryImageURLs; // array of dict of urlStrings
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSMutableArray *potentialPromotions;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *priceType;
@property (nonatomic, strong) NSMutableDictionary *primaryImageURLs; // dict of urlStrings
@property (nonatomic, strong) NSMutableDictionary *variantInfo; // dict of associated products
@property (nonatomic, strong) NSMutableDictionary *selectedVariantInfo; // dict of variant info for selected product
@property (nonatomic, strong) NSString *productCode;
@property (nonatomic, strong) NSString *deliveryInformation;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSNumber *stockLevel;
@property (nonatomic, strong) NSString *stockLevelStatus;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) BOOL purchasable;
@property (nonatomic, strong) NSMutableSet *cartEntries;
@property (nonatomic, strong) NSMutableArray *reviews;

@end
