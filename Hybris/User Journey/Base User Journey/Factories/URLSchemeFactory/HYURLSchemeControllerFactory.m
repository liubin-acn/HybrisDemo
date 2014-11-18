//
// HYURLSchemeControllerFactory.m
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

#import "HYURLSchemeControllerFactory.h"


@implementation HYURLSchemeControllerFactory

+ (HYURLSchemeControllerFactory *)factory {
    return [[[self class] alloc] init];
}


- (HYURLSchemeController *)urlSchemeControllerForSymbology:(NSString *)symbology withBarcode:(NSString *)barcode {
    NSArray *patternArray = [[HYAppDelegate sharedDelegate].configDictionary objectForKey:@"urlPattern"];
    
    if (barcode && patternArray) {
        for (NSDictionary *pattern in patternArray) {
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[pattern objectForKey:@"regexPatternBarcode"]
                                                                                   options:NSRegularExpressionCaseInsensitive error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:barcode options:0 range:NSMakeRange(0, [barcode length])];
            
            if (numberOfMatches > 0) {
                return [[NSClassFromString([pattern objectForKey:@"handlingClass"]) alloc] initWithBarcode:barcode andSymbology:symbology withRegexPattern:[pattern objectForKey:@"regexPatternBarcode"]];
            }
        }
    }
    
    return [[HYURLSchemeController alloc] init];
}


- (HYURLSchemeController *)urlSchemeControllerForURL:(NSURL *)url {
    NSArray *patternArray = [[HYAppDelegate sharedDelegate].configDictionary objectForKey:@"urlPattern"];
    
    if (url && patternArray) {
        NSString *appName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] lowercaseString];
        
        for (NSDictionary *pattern in patternArray) {
            NSError *error;
            NSString *searchPattern = [NSString stringWithFormat:@"^%@://%@", appName, [pattern objectForKey:@"regexPatternURL"]];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchPattern
                                                                                   options:NSRegularExpressionCaseInsensitive error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:[url absoluteString] options:0 range:NSMakeRange(0, [[url absoluteString] length])];
            
            if (numberOfMatches > 0) {
                return [[NSClassFromString([pattern objectForKey:@"handlingClass"]) alloc] initWithURL:url withRegexPattern:searchPattern];
            }
        }
    }
    
    return [[HYURLSchemeController alloc] init];
}

@end
