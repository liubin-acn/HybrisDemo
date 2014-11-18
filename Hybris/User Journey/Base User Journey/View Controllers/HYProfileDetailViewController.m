//
// HYProfileDetailViewController.m
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

#import "HYProfileDetailViewController.h"


@implementation HYProfileDetailViewController

- (id)initWithTitle:(NSString *)myTitle values:(NSDictionary *)values {
    if (self = [super initWithPlistNamed:@"Profile"]) {
        self.title = myTitle;

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
                NSMutableArray *title = [[NSMutableArray alloc] initWithCapacity:array.count];

                for (NSDictionary *dict in array) {
                    [title addObject:[dict objectForKey:@"name"]];
                }

                [self waitViewShow:YES];
                [[HYWebService shared] languagesWithCompletionBlock:^(NSArray *array, NSError *error) {
                        [self waitViewShow:NO];

                        if (error) {
                            [[HYAppDelegate sharedDelegate] alertWithError:error];
                        }
                        else {
                            [array writeToPlistFile:@"languages"];
                            NSMutableArray *language = [[NSMutableArray alloc] initWithCapacity:array.count];

                            for (NSDictionary *dict in array) {
                                [language addObject:[dict objectForKey:@"name"]];
                            }

                            [self waitViewShow:YES];
                            [[HYWebService shared] currenciesWithCompletionBlock:^(NSArray *array, NSError *error) {
                                    [self waitViewShow:NO];

                                    if (error) {
                                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                                    }
                                    else {
                                        [array writeToPlistFile:@"currencies"];
                                        NSMutableArray *currency = [[NSMutableArray alloc] initWithCapacity:array.count];

                                        for (NSDictionary *dict in array) {
                                            [currency addObject:[dict objectForKey:@"name"]];
                                        }

                                        self.currencies = currency;
                                        self.languages = language;
                                        self.titles = title;
                                    }
                                }];
                        }
                    }];
            }
    }];
    
    // set the right title (instead of the title code)
    NSString *titleName = nil;
    NSString *titleCode = [[self.entries objectAtIndex:0] objectForKey:@"value"];
    NSArray *titles = [NSArray readFromPlistFile:@"titles"];
    
    for (NSDictionary *dict in titles) {
        if ([[dict objectForKey:@"code"] isEqualToString:titleCode]) {
            titleName = [dict objectForKey:@"name"];
            break;
        }
    }
    
    if (titleName) {
        for (NSDictionary *entry in self.entries) {
            if ([[entry objectForKey:@"property"] isEqualToString:@"titleCode"]) {
                [entry setValue:titleName forKey:@"value"];
                break;
            }
        }
    }
}


- (NSArray *)titles {
    return [[self.entries objectAtIndex:0] objectForKey:@"values"];
}


- (void)setTitles:(NSArray *)titles {
    [[self.entries objectAtIndex:0] setObject:titles forKey:@"values"];
    [self.tableView reloadData];
}


- (NSArray *)currencies {
    return [[self.entries objectAtIndex:3] objectForKey:@"values"];
}


- (void)setCurrencies:(NSArray *)currencies {
    [[self.entries objectAtIndex:3] setObject:currencies forKey:@"values"];
    [self.tableView reloadData];
}


- (NSArray *)languages {
    return [[self.entries objectAtIndex:4] objectForKey:@"values"];
}


- (void)setLanguages:(NSArray *)languages {
    [[self.entries objectAtIndex:4] setObject:languages forKey:@"values"];
    [self.tableView reloadData];
}



#pragma mark - FormView Controller Delegate methods

- (void)submitWithArray:(NSArray *)array {
    NSArray *titles = [NSArray readFromPlistFile:@"titles"];
    NSString *titleCode = nil;

    for (NSDictionary *dict in titles) {
        if ([[dict objectForKey:@"name"] isEqualToString:[array objectAtIndex:0]]) {
            titleCode = [dict objectForKey:@"code"];
            break;
        }
    }

    NSArray *currency = [NSArray readFromPlistFile:@"currencies"];
    NSString *currencyCode = nil;

    for (NSDictionary *dict in currency) {
        if ([[dict objectForKey:@"name"] isEqual:[array objectAtIndex:3]]) {
            currencyCode = [dict objectForKey:@"isocode"];
            break;
        }
    }

    NSArray *language = [NSArray readFromPlistFile:@"languages"];
    NSString *languageCode = nil;

    for (NSDictionary *dict in language) {
        if ([[dict objectForKey:@"name"] isEqual:[array objectAtIndex:4]]) {
            languageCode = [dict objectForKey:@"isocode"];
            break;
        }
    }

    [self waitViewShow:YES];
    [[HYWebService shared] updateCustomerProfileWithFirstName:[array objectAtIndex:1] lastName:[array objectAtIndex:2] titleCode:titleCode language:
        languageCode currency:currencyCode completionBlock:^(NSDictionary *dictionary, NSError *error) {
            [self waitViewShow:NO];

            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                UIAlertView *alert =
                    [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:@"Profile Updated" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];
                logDebug (@"%@", dictionary);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
}

@end
