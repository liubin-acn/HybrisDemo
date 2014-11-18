//
// HYURLSchemeController.m
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

#import "HYURLSchemeController.h"


@interface HYURLSchemeController()

@property (nonatomic, readwrite) BOOL isError;
@property (nonatomic, readwrite) HYURLSchemeControllerError *error;

@end


@implementation HYURLSchemeController

#pragma mark - Init

- (id)initWithBarcode:(NSString *)barcode andSymbology:(NSString *)barcodeSymbology withRegexPattern:(NSString *)regexPattern {
    if (self = [super init]) {
        self.barcode = barcode;
        self.symbology = barcodeSymbology;
        self.regexPattern = regexPattern;
    }
    
    return self;
}


- (id)initWithURL:(NSURL *)url withRegexPattern:(NSString *)regexPattern {
    if (self = [super init]) {
        self.url = url;
        self.regexPattern = regexPattern;
    }
    
    return self;
}


- (void)parseBarcodeWithCompletionBlock:(NSVoidBlock)completionBlock {
    self.isError = YES;
    self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"Barcode error", @"Title for barcode scan failure")
                                                        andErrorMessage:NSLocalizedString(@"There was an error scanning the\n barcode. Please try again.",
                                                                                          @"General barcode scan failure message")];
    dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(); });
}


- (void)parseURLWithCompletionBlock:(NSVoidBlock)completionBlock {
    self.isError = YES;
    self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"URL error", @"Title for handle URL failure")
                                                        andErrorMessage:NSLocalizedString(@"There was an error handling the\n URL.",
                                                                                          @"General URL handling failure message")];
    dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(); });
}


- (BOOL)isLoginRequired {
    return NO;
}


- (UIViewController *)prepareResultViewController {
    return nil;
}


- (void)showResultViewController:(UIViewController *)vc {    
    NSInteger tabbarIndex = [self tabIndexForViewController];
    
    if (tabbarIndex != -1) {
        UITabBarController *tabbarController = [[[HYAppDelegate sharedDelegate] visibleViewController] tabBarController];
        tabbarController.selectedViewController = [tabbarController.viewControllers objectAtIndex:tabbarIndex];
    }
    
    UIViewController *visibleViewController = [[HYAppDelegate sharedDelegate] visibleViewController];
    [visibleViewController.navigationController pushViewController:vc animated:YES];
}


- (NSInteger)tabIndexForViewController {
    return 0;
}

@end
