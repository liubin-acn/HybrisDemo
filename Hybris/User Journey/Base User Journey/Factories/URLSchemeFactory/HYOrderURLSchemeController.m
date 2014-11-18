//
// HYOrderURLSchemeHandler.m
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

#import "HYOrderURLSchemeController.h"


@interface HYOrderURLSchemeController()

@property (nonatomic, strong) NSString *orderCode;
@property (nonatomic, strong) NSDictionary *orderDetails;
@property (nonatomic, readwrite) BOOL isError;
@property (nonatomic, readwrite) HYURLSchemeControllerError *error;

- (void)parseForSearchString:(NSString *)string withCompletionBlock:(NSVoidBlock)completionBlock;

@end


@implementation HYOrderURLSchemeController

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


- (BOOL)isLoginRequired {
    return YES;
}


- (UIViewController *)prepareResultViewController {    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil]
                            instantiateViewControllerWithIdentifier:@"HYOrderDetailViewController"];
    vc.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Your Order", nil), self.orderCode];
    [vc performSelector:@selector(setOrderDetails:) withObject:[[NSDictionary alloc] initWithDictionary:self.orderDetails]];

    return vc;
}


- (void)showResultViewController:(UIViewController *)vc {
    NSInteger tabbarIndex = [self tabIndexForViewController];
    
    if (tabbarIndex != -1) {
        UITabBarController *tabbarController = [[[HYAppDelegate sharedDelegate] visibleViewController] tabBarController];
        tabbarController.selectedViewController = [tabbarController.viewControllers objectAtIndex:tabbarIndex];
    }
    
    [[[[HYAppDelegate sharedDelegate] visibleViewController] navigationController] popToRootViewControllerAnimated:NO];
    [[[[HYAppDelegate sharedDelegate] visibleViewController] navigationController] pushViewController:vc animated:YES];
}


- (NSInteger)tabIndexForViewController {
    return 1;
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
            
            if ([firstMatch numberOfRanges] > 1) {
                self.orderCode = [string substringWithRange:[firstMatch rangeAtIndex:1]];
            }
        }
    }
    
    if (self.orderCode) {
        [[HYWebService shared] orderDetailsWithID:self.orderCode completionBlock:^(NSDictionary *dict, NSError *error) {
            if ([dict objectForKey:@"code"]) {
                self.isError = NO;
                self.orderDetails = dict;
            } else {
                self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"Barcode error", @"Title for barcode scan failure")
                                                                    andErrorMessage:NSLocalizedString(@"No order found for this QR code.",
                                                                                                      @"Barcode scan failure message because order not found")];            
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(); });
        }];
    }
}

@end
