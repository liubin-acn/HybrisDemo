//
// HYStoreURLSchemeController.m
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

#import "HYStoreURLSchemeController.h"
#import "HYStoreSearchViewController.h"


@interface HYStoreURLSchemeController()

@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) NSInteger radius;
@property (nonatomic, readwrite) BOOL isError;
@property (nonatomic, readwrite) HYURLSchemeControllerError *error;

- (void)parseForSearchString:(NSString *)string withCompletionBlock:(NSVoidBlock)completionBlock;

@end


@implementation HYStoreURLSchemeController

- (void)parseBarcodeWithCompletionBlock:(NSVoidBlock)completionBlock {
    [self parseForSearchString:self.barcode withCompletionBlock:^(void) {
        completionBlock ();
    }];
}


- (void)parseURLWithCompletionBlock:(NSVoidBlock)completionBlock {
    [self parseForSearchString:[self.url absoluteString] withCompletionBlock:^(void) {
        if (!self.error) {
            self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"URL error", @"Title for handle URL failure")
                                                                andErrorMessage:NSLocalizedString(@"There was an error handling the\n URL.",
                                                                                                  @"General URL handling failure message")];
        }
        completionBlock ();
    }];
}


- (UIViewController *)prepareResultViewController {
    UIViewController *vc;
    NSInteger tabbarIndex = [self tabIndexForViewController];  
    
    if (tabbarIndex != -1) {
        UITabBarController *tabbarController = [[[HYAppDelegate sharedDelegate] visibleViewController] tabBarController];
        vc = [[tabbarController.viewControllers objectAtIndex:tabbarIndex] topViewController];
        [[vc navigationController] popToRootViewControllerAnimated:NO];
        vc = [[tabbarController.viewControllers objectAtIndex:tabbarIndex] topViewController];
    }
    
    if (vc) {
        if (self.latitude && self.longitude) {
            [(HYStoreSearchViewController *)vc setLatitude:self.latitude];
            [(HYStoreSearchViewController *)vc setLongitude:self.longitude];
            [(HYStoreSearchViewController *)vc setRadius:self.radius];
        } else {
            [(HYStoreSearchViewController *)vc setLatitude:0];
            [(HYStoreSearchViewController *)vc setLongitude:0];
            [(HYStoreSearchViewController *)vc setRadius:self.radius];
        }
    }
    
    return vc;
}


- (void)showResultViewController:(UIViewController *)vc {
    NSInteger tabbarIndex = [self tabIndexForViewController];
    
    if (tabbarIndex != -1) {
        UITabBarController *tabbarController = [[[HYAppDelegate sharedDelegate] visibleViewController] tabBarController];
        tabbarController.selectedViewController = [tabbarController.viewControllers objectAtIndex:tabbarIndex];
    }
}


- (NSInteger)tabIndexForViewController {
    return 3;
}



#pragma mark - private methods

- (void)parseForSearchString:(NSString *)string withCompletionBlock:(NSVoidBlock)completionBlock {
    self.isError = YES;
    
    if (self.regexPattern) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regexPattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if (numberOfMatches > 0) {
            NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
            
            if ([firstMatch numberOfRanges] == 2) {
                // with radius only
                self.radius = [[string substringWithRange:[firstMatch rangeAtIndex:1]] integerValue];
                self.isError = NO;
                
            } else if ([firstMatch numberOfRanges] == 6) {
                // with latitude, longitude and radius
                self.longitude = [[string substringWithRange:[firstMatch rangeAtIndex:1]] doubleValue];
                self.latitude = [[string substringWithRange:[firstMatch rangeAtIndex:3]] doubleValue];
                self.radius = [[string substringWithRange:[firstMatch rangeAtIndex:5]] integerValue];
                self.isError = NO;
            }
        }
    }
    
    if (self.isError) {
        self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"Barcode error", @"Title for barcode scan failure")
                                                            andErrorMessage:NSLocalizedString(@"There was an error scanning the\n barcode. Please try again.",
                                                                                              @"General barcode scan failure message")];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(); });
}

@end
