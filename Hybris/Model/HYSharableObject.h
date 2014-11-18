//
// HYSharableObject.h
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

@interface HYSharableObject:NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageLink;
@property (nonatomic, strong) NSString *price;

- (id)initWithString:(NSString *)string;
- (id)initWithDictionary:(NSMutableDictionary *)dict;

@end
