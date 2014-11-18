//
// HYLinkURLSchemeController.m
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

#import "HYLinkURLSchemeController.h"
#import "HYProduct.h"


@interface HYLinkURLSchemeController()

@property (nonatomic, strong) NSString *productCode;
@property (nonatomic, strong) HYProduct *product;
@property (nonatomic, readwrite) BOOL isError;
@property (nonatomic, readwrite) HYURLSchemeControllerError *error;

- (void)parseForSearchString:(NSString *)string withCompletionBlock:(NSVoidBlock)completionBlock;

@end


@implementation HYLinkURLSchemeController

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
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil]
                            instantiateViewControllerWithIdentifier:@"HYProductDetailViewController"];
    [vc performSelector:@selector(setProduct:) withObject:self.product];
    
    return vc;
}


- (NSInteger)tabIndexForViewController {
    return 0;
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
                self.productCode = [string substringWithRange:[firstMatch rangeAtIndex:1]];
                self.isError = NO;
            }
        }
    }
    
    if (self.productCode) {
        NSArray *options = [NSArray arrayWithObjects:HYProductOptionBasic, HYProductOptionCategories, HYProductOptionClassification, HYProductOptionDescription,
                            HYProductOptionGallery, HYProductOptionPrice, HYProductOptionPromotions, HYProductOptionReview, HYProductOptionStock,
                            HYProductOptionVariant,
                            nil];
        [[HYWebService shared] productWithCode:self.productCode options:options completionBlock:^(NSArray *results, NSError *error) {
            if ([results objectAtIndex:0]) {
                self.isError = NO;
                self.product = [results objectAtIndex:0];
            } else {
                self.error = [[HYURLSchemeControllerError alloc] initWithErrorTitle:NSLocalizedString(@"Barcode error", @"Title for barcode scan failure")
                                                                    andErrorMessage:NSLocalizedString(@"There was an error scanning the\n barcode. Please try again.",
                                                                                                      @"General barcode scan failure message")];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(); });
        }];
    }
}

@end
