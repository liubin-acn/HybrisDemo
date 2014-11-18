//
// Cart.h
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

@class CartEntry, Price;

@interface Cart:NSObject

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSDictionary *productDiscounts;
@property (nonatomic, retain) Price *totalPrice;
@property (nonatomic, retain) NSNumber *net;
@property (nonatomic, retain) Price *totalDiscounts;
@property (nonatomic, retain) NSArray *appliedProductPromotions;
@property (nonatomic, retain) NSArray *potentialProductPromotions;
@property (nonatomic, retain) Price *totalTax;
@property (nonatomic, retain) NSNumber *totalUnitCount;
@property (nonatomic, retain) Price *orderDiscounts;
@property (nonatomic, retain) NSArray *potentialOrderPromotions;
@property (nonatomic, retain) NSNumber *totalItems;
@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, retain) NSArray *appliedOrderPromotions;
@property (nonatomic, retain) Price *subTotal;
@property (nonatomic, retain) NSDictionary *deliveryAddress;
@property (nonatomic, retain) NSDictionary *deliveryCost;
@property (nonatomic, retain) NSDictionary *deliveryMode;
@property (nonatomic, retain) NSDictionary *paymentInfo;

+ (Cart *)cartWithInfo:(NSDictionary *)infoDictionary;

@end

