//
// Constants.h
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


#ifndef Hybris_Constants_h
#define Hybris_Constants_h

/// Refresh interval for cached data
#define STANDARD_REFRESH_INTERVAL 3600

/// Query result size
#define QUERY_PAGE_SIZE 20

/// Saved search count
#define MAX_PREVIOUS_SEARCHES 10

/// Search suggestion delay
#define SEARCH_SUGGESTION_DELAY 1.0

/// Show featured products in shop front
#define PRODUCTS_IN_SHOP_FRONT NO

/// Show featured products in category views
#define PRODUCTS_IN_CATEGORY_VIEW YES

/// Notification tokens to let an observer know about network activity
FOUNDATION_EXPORT NSString *const HYConnectionStartedNotification;
FOUNDATION_EXPORT NSString *const HYConnectionStoppedNotification;

/// Notification tokens to let an observer know about cart changes
FOUNDATION_EXPORT NSString *const HYItemAddedToCart;
FOUNDATION_EXPORT NSString *const HYItemRemovedFromCart;
//Hybris test by bin
FOUNDATION_EXPORT NSString *const HYItemUpdateFromCart;

/// Product detail options, to control how much information is returned
FOUNDATION_EXPORT NSString *const HYProductOptionBasic;
FOUNDATION_EXPORT NSString *const HYProductOptionDescription;
FOUNDATION_EXPORT NSString *const HYProductOptionGallery;
FOUNDATION_EXPORT NSString *const HYProductOptionCategories;
FOUNDATION_EXPORT NSString *const HYProductOptionPromotions;
FOUNDATION_EXPORT NSString *const HYProductOptionStock;
FOUNDATION_EXPORT NSString *const HYProductOptionReview;
FOUNDATION_EXPORT NSString *const HYProductOptionClassification;
FOUNDATION_EXPORT NSString *const HYProductOptionReferences; /// Do not use
FOUNDATION_EXPORT NSString *const HYProductOptionPrice;
FOUNDATION_EXPORT NSString *const HYProductOptionVariant;

/// Authenticaian Strings
FOUNDATION_EXPORT NSString *const HYAuthClientID;
FOUNDATION_EXPORT NSString *const HYAuthClientSecret;

/// Facebook
FOUNDATION_EXPORT NSString *const FBSessionStateChangedNotification;

/// Image
FOUNDATION_EXPORT NSString *const HYProductCellPlaceholderImage;

/// Site changed
FOUNDATION_EXPORT NSString *const HYSiteChangedNotification;

// Connection timeout
FOUNDATION_EXPORT NSTimeInterval const HYConnectionTimeout;

/// Sizes
#define DEVICE_WIDTH 320.0
#define STANDARD_MARGIN 5.0
#define HEADER_HEIGHT 46.0
#define FOOTER_HEIGHT 40.0
#define INFINITE_SCROLL_AREA_HEIGHT 40.0
#define CONSTRAINED_WIDTH_GROUPED 280.00
#define CONSTRAINED_WIDTH 300.00
#define CONSTRAINED_HEIGHT 9999.0

// Animation definition
#define POP_VIEW_CONTROLLER_DELAY 0.2

// Location settings
#define LOCATION_ACCURACY kCLLocationAccuracyHundredMeters
#define LOCATION_TIMEOUT 5.0

#endif
