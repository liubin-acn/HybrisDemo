//
// HYURLSchemeControllerFactory.h
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
#import "HYURLSchemeController.h"


@interface HYURLSchemeControllerFactory : NSObject

+ (HYURLSchemeControllerFactory *)factory;

- (HYURLSchemeController *)urlSchemeControllerForSymbology:(NSString *)symbology withBarcode:(NSString *)barcode;

- (HYURLSchemeController *)urlSchemeControllerForURL:(NSURL *)url;

@end
