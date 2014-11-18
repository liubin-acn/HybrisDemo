//
// HYCurrencyListViewController.m
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

#import "HYCurrencyListViewController.h"

@interface HYCurrencyListViewController ()

@end

@implementation HYCurrencyListViewController

- (void)itemWasSelected {
    // Get the profile information
    [self waitViewShow:YES];
    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *profileDictionary, NSError *error) {
            [self waitViewShow:NO];

            // Get the new currency
            NSString *updatedCurrency = [[self.details objectAtIndex:self.selectedItem] objectForKey:@"isocode"];

            // Update the profile
            [self waitViewShow:YES];
            [[HYWebService shared] updateCustomerProfileWithFirstName:[profileDictionary objectForKey:@"firstName"]
                lastName:[profileDictionary objectForKey:@"lastName"]
                titleCode:[profileDictionary objectForKey:@"titleCode"]
                language:[[profileDictionary objectForKey:@"language"] objectForKey:@"isocode"]
                currency:updatedCurrency
                completionBlock:^(NSDictionary *dictionary, NSError *error) {
                    [self waitViewShow:NO];

                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }

                    [self performBlock:^{
                            // Set the currency info from the profile
                            [[NSUserDefaults standardUserDefaults] setValue:updatedCurrency forKey:@"web_services_currency_preference"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            // Dismiss
                            [self.navigationController popViewControllerAnimated:YES];
                        } afterDelay:POP_VIEW_CONTROLLER_DELAY];
                }];
        }];
}

@end
