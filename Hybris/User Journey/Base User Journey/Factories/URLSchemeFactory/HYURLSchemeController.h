//
// HYURLSchemeController.h
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
#import "HYURLSchemeControllerError.h"


@interface HYURLSchemeController : NSObject

@property (nonatomic, strong) NSString *symbology;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *regexPattern;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, readonly) BOOL isError;
@property (nonatomic, readonly) HYURLSchemeControllerError *error;


- (id)initWithBarcode:(NSString *)barcode andSymbology:(NSString *)barcodeSymbology withRegexPattern:(NSString *)regexPattern;

- (id)initWithURL:(NSURL *)url withRegexPattern:(NSString *)regexPattern;

- (BOOL)isLoginRequired;

- (void)parseBarcodeWithCompletionBlock:(NSVoidBlock)completionBlock;

- (void)parseURLWithCompletionBlock:(NSVoidBlock)completionBlock;

- (UIViewController *)prepareResultViewController;

- (void)showResultViewController:(UIViewController *)vc;

- (NSInteger)tabIndexForViewController;

@end
