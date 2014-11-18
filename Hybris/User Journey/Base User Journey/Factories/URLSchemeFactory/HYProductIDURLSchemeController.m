//
// HYProductIDURLSchemeController.m
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

#import "HYProductIDURLSchemeController.h"


@interface HYProductIDURLSchemeController ()

- (NSString *)extractProductCodeFromString:(NSString *)string;

@end


@implementation HYProductIDURLSchemeController

#pragma mark - private methods

- (NSString *)extractProductCodeFromString:(NSString *)string {
    NSString *productCode;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regexPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (numberOfMatches > 0) {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if ([firstMatch numberOfRanges] > 0) {
            productCode = [string substringWithRange:[firstMatch rangeAtIndex:0]];
            productCode = [NSString stringWithFormat:@"%d", [productCode integerValue]];
            
            if ([self.symbology isEqualToString:@"UPC12"] || [self.symbology isEqualToString:@"EAN8"]) {
                if ([productCode length] > 0) {
                    productCode = [productCode substringToIndex:[productCode length] - 1];
                }
            }
        }
    }
    return productCode;
}

@end
