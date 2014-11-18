//
// Constants.m
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

NSString *const HYConnectionStartedNotification = @"HYConnectionStartedNotification";
NSString *const HYConnectionStoppedNotification = @"HYConnectionStoppedNotification";

NSString *const HYItemAddedToCart = @"HYItemAddedToCart";
NSString *const HYItemRemovedFromCart = @"HYItemRemovedFromCart";

NSString *const HYProductOptionBasic = @"BASIC";
NSString *const HYProductOptionDescription = @"DESCRIPTION";
NSString *const HYProductOptionGallery = @"GALLERY";
NSString *const HYProductOptionCategories = @"CATEGORIES";
NSString *const HYProductOptionPromotions = @"PROMOTIONS";
NSString *const HYProductOptionStock = @"STOCK";
NSString *const HYProductOptionReview = @"REVIEW";
NSString *const HYProductOptionClassification = @"CLASSIFICATION";
NSString *const HYProductOptionReferences = @"REFERENCES"; /// This causes an OCC error! (enum not defined)
NSString *const HYProductOptionPrice = @"PRICE";
NSString *const HYProductOptionVariant = @"VARIANT_FULL";

NSString *const HYAuthClientID = @"mobile_android";
NSString *const HYAuthClientSecret = @"secret";

NSString *const FBSessionStateChangedNotification = @"com.hybis.FBSessionStateChangedNotification";

NSString *const HYProductCellPlaceholderImage = @"ProductCellPlaceholder.png";

NSString *const HYSiteChangedNotification = @"HYSiteChangedNotification";

NSTimeInterval const HYConnectionTimeout = 30.0;
