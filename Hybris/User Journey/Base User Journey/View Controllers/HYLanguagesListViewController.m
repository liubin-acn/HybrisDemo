//
// HYLanguagesListViewController.m
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

#import "HYLanguagesListViewController.h"

@interface HYLanguagesListViewController ()

@end

@implementation HYLanguagesListViewController

- (void)itemWasSelected {
    // Get the profile information
    [self waitViewShow:YES];
    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *profileDictionary, NSError *error) {
            [self waitViewShow:NO];
            // Get the new language
            NSString *updatedLanguage = [[self.details objectAtIndex:self.selectedItem] objectForKey:@"isocode"];

            // Update the profile
            [self waitViewShow:YES];
            [[HYWebService shared] updateCustomerProfileWithFirstName:[profileDictionary objectForKey:@"firstName"]
                lastName:[profileDictionary objectForKey:@"lastName"]
                titleCode:[profileDictionary objectForKey:@"titleCode"]
                language:updatedLanguage
                currency:[[profileDictionary objectForKey:@"currency"] objectForKey:@"isocode"]
                completionBlock:^(NSDictionary *dictionary, NSError *error) {
                    [self waitViewShow:NO];

                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }

                    [self performBlock:^{
                            // Dismiss
                            [self.navigationController popViewControllerAnimated:YES];

                            // Set the locale info from the profile
                            [[NSUserDefaults standardUserDefaults] setValue:updatedLanguage forKey:@"web_services_language_preference"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        } afterDelay:POP_VIEW_CONTROLLER_DELAY];
                }];
        }];
}

@end
