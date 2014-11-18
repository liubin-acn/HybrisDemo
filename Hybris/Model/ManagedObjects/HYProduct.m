//
// HYProduct.m
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

@implementation HYProduct

- (id)init {
    self = [super init];

    self.classifications = [NSMutableArray array];
    self.galleryImageURLs = [NSMutableArray array];
    self.potentialPromotions = [NSMutableArray array];
    self.primaryImageURLs = [NSMutableDictionary dictionary];
    self.cartEntries = [NSMutableSet set];
    self.reviews = [NSMutableArray array];
    self.variantInfo = [NSMutableDictionary dictionary];
    self.selectedVariantInfo = [NSMutableDictionary dictionary];
    return self;
}


@end
