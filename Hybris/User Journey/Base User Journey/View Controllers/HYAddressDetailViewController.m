//
// HYAddressDetailViewController.m
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

#import "HYAddressDetailViewController.h"


@interface HYAddressDetailViewController ()

@property (nonatomic) BOOL inEditingMode;
@property (nonatomic, strong) NSString *addressID;

@end


@implementation HYAddressDetailViewController

#pragma mark - Init

- (id)initWithTitle:(NSString *)myTitle {
    if (self = [super initWithPlistNamed:@"Address"]) {
        self.title = myTitle;
        self.inEditingMode = NO;
        self.delegate = self;
    }

    return self;
}


- (id)initWithTitle:(NSString *)myTitle values:(NSDictionary *)values {
    if (self = [super initWithPlistNamed:@"Address"]) {
        self.title = myTitle;
        self.inEditingMode = YES;
        self.addressID = [values objectForKey:@"id"];

        for (NSDictionary *entry in self.entries) {
            [entry setValue:[values valueForKeyPath:[entry objectForKey:@"property"]] forKey:@"value"];
        }

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

                [self waitViewShow:YES];
                [[HYWebService shared] countriesWithCompletionBlock:^(NSArray *array, NSError *error) {
                        [self waitViewShow:NO];

                        if (error) {
                            [[HYAppDelegate sharedDelegate] alertWithError:error];
                        }
                        else {
                            [array writeToPlistFile:@"countries"];

                            NSMutableArray *countries = [[NSMutableArray alloc] initWithCapacity:array.count];

                            for (NSDictionary *dict in array) {
                                if ([dict objectForKey:@"name"]) {
                                    [countries addObject:[dict objectForKey:@"name"]];
                                }
                                else {
                                    logError (@"Required JSON data missing");
                                }
                            }

                            self.titles = titles;
                            self.countries = countries;
                        }
                    }];
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


- (NSArray *)countries {
    return [[self.entries objectAtIndex:0] objectForKey:@"values"];
}


- (void)setCountries:(NSArray *)countries {
    [[self.entries objectAtIndex:7] setObject:countries forKey:@"values"];
    [self.tableView reloadData];
}


#pragma mark - FormView Controller Delegate methods
- (void)submitWithArray:(NSArray *)array {
    logDebug(@"%@", array);

    [self waitViewShow:YES];

    NSArray *titles = [NSArray readFromPlistFile:@"titles"];
    NSString *titleCode = nil;

    for (NSDictionary *dict in titles) {
        if ([[dict objectForKey:@"name"] isEqualToString:[array objectAtIndex:0]]) {
            titleCode = [dict objectForKey:@"code"];
            break;
        }
    }

    NSArray *countries = [NSArray readFromPlistFile:@"countries"];
    NSString *countryCode = nil;

    for (NSDictionary *dict in countries) {
        if ([[dict objectForKey:@"name"] isEqual:[array objectAtIndex:7]]) {
            countryCode = [dict objectForKey:@"isocode"];
            break;
        }
    }

    if (self.inEditingMode) {
        [[HYWebService shared] updateCustomerAddressWithFirstName:[array objectAtIndex:1]
            lastName:[array objectAtIndex:2]
            titleCode:titleCode
            addressLine1:[array objectAtIndex:3]
            addressLine2:[array objectAtIndex:4]
            town:[array objectAtIndex:5]
            postCode:[array objectAtIndex:6]
            countryISOCode:countryCode
            addressID:self.addressID
            completionBlock:^(NSDictionary *dictionary, NSError *error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    UIAlertView *alert =
                        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:NSLocalizedString(@"Address Updated", @"Address updated alert message") delegate:nil cancelButtonTitle:NSLocalizedString (@"OK", @"OK button") otherButtonTitles:nil];
                    [alert show];
                    logDebug (@"%@", dictionary);
                    [self.navigationController popViewControllerAnimated:YES];
                }

                [self waitViewShow:NO];
            }];
    }
    else {
        [[HYWebService shared] createCustomerAddressWithFirstName:[array objectAtIndex:1]
            lastName:[array objectAtIndex:2]
            titleCode:titleCode
            addressLine1:[array objectAtIndex:3]
            addressLine2:[array objectAtIndex:4]
            town:[array objectAtIndex:5]
            postCode:[array objectAtIndex:6]
            countryISOCode:countryCode
            completionBlock:^(NSDictionary *dictionary, NSError *error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    UIAlertView *alert =
                        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:NSLocalizedString(@"Address Added", @"Address added alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                    [alert show];
                    logDebug (@"%@", dictionary);
                    [self.navigationController popViewControllerAnimated:YES];
                }

                [self waitViewShow:NO];
            }];
    }
}

@end
