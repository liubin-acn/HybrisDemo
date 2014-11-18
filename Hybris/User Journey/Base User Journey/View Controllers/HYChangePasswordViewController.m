//
// HYChangePasswordViewController.m
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

#import "HYChangePasswordViewController.h"


@implementation HYChangePasswordViewController

#pragma mark - Init

- (id)initWithTitle:(NSString *)title {
    self = [super initWithPlistNamed:@"ChangePassword"];

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

    if ([[array objectAtIndex:1] isEqual:[array objectAtIndex:2]]) {
        [self waitViewShow:YES];
        [[HYWebService shared] updateCustomerPasswordWithNewPassword:[array objectAtIndex:1] oldPassword:[array objectAtIndex:0] completionBlock:^(NSError *
                error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    UIAlertView *alert =
                        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:@"Password changed" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                    [alert show];
                }

                [self waitViewShow:NO];
            }];
    }
    else {
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString (@"Error", @"Error alert box title") message:@"Password mismatch" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alert show];
    }
}

@end
