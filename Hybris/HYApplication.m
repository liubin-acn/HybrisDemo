//
// HYApplication.m
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

#import "HYApplication.h"
#import "HYURLSchemeControllerFactory.h"


@interface HYApplication ()

/// Private property used by the alert view
@property (nonatomic, strong) NSURL *url;

@end


@implementation HYApplication

@synthesize url = _url;

#define ExternalLinkAlertTag 99


/**
 *  Allows fine-grained handling of in-app URLs
 */
- (BOOL)openURL:(NSURL *)url {
    self.url = url;
    UIAlertView *alert = nil;

    NSString *productName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] lowercaseString];

    // Local
    if ([self.url.scheme isEqual:@"file"]) {
        return [super openURL:url];
    }

    // Custom (App Name)
    else if ([self.url.scheme isEqual:productName]) {
        HYURLSchemeController *urlController = [[HYURLSchemeControllerFactory factory] urlSchemeControllerForURL:self.url];
        
        // check if a login is required for this barcode (ignore all urls that require login while user is not logged in)
        if (![urlController isLoginRequired] || ([urlController isLoginRequired] &&![HYAppDelegate sharedDelegate].isLoggedIn)) {
            [urlController parseURLWithCompletionBlock:^{
                if (urlController && ![urlController isError]) {
                    // show the view for the scanned barcode
                    UIViewController *vc = [urlController prepareResultViewController];
                    [urlController showResultViewController:vc];
                }            
            }];
        }

        return [super openURL:url];
    }

    // Facebook
    else if ([self.url.scheme hasPrefix:@"fb"] || ([self.url.host isEqualToString:@"m.facebook.com"])) {
        return [super openURL:url];
    }

    // Web
    else if ([self.url.scheme isEqual:@"http"]) {
        alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"External Link", @"Alert title for opening an external link.")
            message:NSLocalizedString(@"You are leaving the app. Do you wish to continue?", @"External link message")
            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title for the cancel button.") otherButtonTitles:NSLocalizedString(@"Open", @"Button title to open external application"), nil];
    }
    // Phone
    else if ([self.url.scheme isEqual:@"tel"]) {
        alert = [[UIAlertView alloc]
            initWithTitle:[[url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringFromIndex:4]
            message:nil
            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title for the cancel button.") otherButtonTitles:NSLocalizedString(@"Call", @""), nil];
    }
    else if ([self.url.scheme isEqual:@"telprompt"]) {
        NSString *telNum = [[url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringFromIndex:10];
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", telNum]];
        alert = [[UIAlertView alloc]
            initWithTitle:[[url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringFromIndex:10]
            message:nil
            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title for the cancel button.") otherButtonTitles:NSLocalizedString(@"Call", @""), nil];
    }
    // Catch all, in this case defaults to Safari
    else {
        alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"External Link", @"Alert title for opening an external link.")
            message:NSLocalizedString(@"You are leaving the app. Do you wish to continue?", @"External link message")
            delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title for the cancel button.") otherButtonTitles:NSLocalizedString(@"Open", @"Button title to open external application"), nil];
    }

    alert.tag = ExternalLinkAlertTag;
    [alert show];

    return NO;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ExternalLinkAlertTag) {
        if (buttonIndex == 1 && [[UIApplication sharedApplication] canOpenURL:self.url]) {
            [self performBackgroundBlock:^{
                    [super openURL:self.url];
                    self.url = nil;
                }  afterDelay:0.3];
        }
    }
}


@end
