//
// HYRegisterUserViewController.m
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

#import "HYRegisterUserViewController.h"

@interface HYRegisterUserViewController ()

@end


@implementation HYRegisterUserViewController


#pragma mark - Init

- (id)initWithTitle:(NSString *)title {
    if (self = [super initWithPlistNamed:@"UserRegistration"]) {
        self.title = title;
        self.delegate = self;
    }

    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self waitViewShow:YES];
    [[HYWebService shared] titlesWithCompletionBlock:^(NSArray *array, NSError *error) {
            [self waitViewShow:NO];

            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                [array writeToPlistFile:@"titles"];
                NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:array.count];

                for (NSDictionary *dict in array) {
                    [titles addObject:[dict objectForKey:@"name"]];
                }

                self.titles = titles;
            }
        }];
}


- (NSArray *)titles {
    return [[self.entries objectAtIndex:0] objectForKey:@"values"];
}


- (void)setTitles:(NSArray *)titles {
    [[self.entries objectAtIndex:0] setObject:titles forKey:@"values"];
    [self.tableView reloadData];
}


#pragma mark - FormView Controller Delegate methods
- (void)submitWithArray:(NSArray *)array {
    logDebug(@"%@", array);

    if (![[array objectAtIndex:4] isEqual:[array objectAtIndex:5]]) {
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert box title") message:NSLocalizedString(@"Password mismatch", @"Error message for mismatching password") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alert show];
        return;
    }

    self.navigationItem.rightBarButtonItem.enabled = NO;

    NSArray *titles = [NSArray readFromPlistFile:@"titles"];
    NSString *titleCode = nil;

    for (NSDictionary *dict in titles) {
        if ([[dict objectForKey:@"name"] isEqualToString:[array objectAtIndex:0]]) {
            titleCode = [dict objectForKey:@"code"];
            break;
        }
    }

    [self waitViewShow:YES];
    [[HYWebService shared] registerCustomerWithFirstName:[array objectAtIndex:1] lastName:[array objectAtIndex:2] titleCode:titleCode login:[array
            objectAtIndex:3] password:[array objectAtIndex:4] completionBlock:^(NSError *error) {
            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else {
                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:NSLocalizedString(@"User registration successful", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];

                [[HYAppDelegate sharedDelegate] setIsLoggedIn:YES];
                [[HYAppDelegate sharedDelegate] setUsername:[array objectAtIndex:3]];
                [self.navigationController popViewControllerAnimated:YES];
            }

            [self waitViewShow:NO];
        }];
}

@end
