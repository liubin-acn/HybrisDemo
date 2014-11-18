//
// HYChangeEmailViewController.m
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

#import "HYChangeEmailViewController.h"


@implementation HYChangeEmailViewController

#pragma mark - Init

- (id)initWithTitle:(NSString *)title {
    self = [super initWithPlistNamed:@"ChangeLogin"];
    
    if (self) {
        self.title = title;
        self.delegate = self;
    }
    
    return self;
}



#pragma mark - FormView Controller Delegate method

- (void)submitWithArray:(NSArray *)array {
    logDebug(@"%@", array);
    
    for (NSString *s in array) {
        if ([s isEmpty]) {
            return;
        }
    }
    
    [self waitViewShow:YES];
    [[HYWebService shared] updateCustomerLoginWithNewLogin:[array objectAtIndex:0] password:[array objectAtIndex:1] completionBlock:^(NSError *
                                                                                                                                      error) {
        if (error) {
            [[HYAppDelegate sharedDelegate] alertWithError:error];
        }
        else {
            [[HYAppDelegate sharedDelegate] setUsername:[array objectAtIndex:0]];
            
            // login again
            [[HYWebService shared] loginWithUsername:[array objectAtIndex:0] password:[array objectAtIndex:1] completionBlock:^(NSError * error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:NSLocalizedString(@"Login changed", @"Login changed alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                    
                    [alert show];
                }
            }];
            
        }
        
        [self waitViewShow:NO];
    }];
}

@end