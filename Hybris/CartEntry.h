//
// CartEntry.h
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

@class Cart, HYProduct, Price;


@interface CartEntry:NSObject

@property (nonatomic, retain) Price *basePrice;
@property (nonatomic, retain) NSNumber *entryNumber;
@property (nonatomic, retain) HYProduct *product;
@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) Price *totalPrice;
@property (nonatomic, retain) NSNumber *updateable;

@end
