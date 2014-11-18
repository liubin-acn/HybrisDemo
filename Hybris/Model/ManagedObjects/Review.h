//
// Review.h
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

@class HYProduct;

@interface Review:HYObject

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSString *principalName;
@property (nonatomic, strong) NSString *principalUID;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) HYProduct *product;

@end
