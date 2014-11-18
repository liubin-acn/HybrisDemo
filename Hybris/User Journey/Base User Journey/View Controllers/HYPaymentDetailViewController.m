//
// HYPaymentDetailViewController.m
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

#import "HYPaymentDetailViewController.h"
#import "HYFormTextEntryCell.h"

@interface HYPaymentDetailViewController ()

@property (nonatomic) BOOL inEditingMode;
@property (nonatomic, strong) NSString *paymentID;

@end


@implementation HYPaymentDetailViewController

#pragma mark - Init

- (id)initWithTitle:(NSString *)title {
    self = [super initWithPlistNamed:@"PaymentDetails"];

    if (self) {
        self.title = title;
        self.inEditingMode = NO;
        self.delegate = self;
    }

    return self;
}


- (id)initWithTitle:(NSString *)title values:(NSDictionary *)values {
    self = [super initWithPlistNamed:@"PaymentDetails"];

    if (self) {
        self.title = title;
        self.inEditingMode = YES;
        self.paymentID = [values objectForKey:@"id"];

        for (NSDictionary *entry in self.entries) {
            [entry setValue:[values valueForKeyPath:[entry objectForKey:@"property"]] forKey:@"value"];
        }

        self.delegate = self;
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
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

                        if (!error) {
                            [array writeToPlistFile:@"countries"];

                            NSMutableArray *countries = [[NSMutableArray alloc] initWithCapacity:array.count];

                            for (NSDictionary *dict in array) {
                                [countries addObject:[dict objectForKey:@"name"]];
                            }

                            [self waitViewShow:YES];
                            
                            [[HYWebService shared] cardTypesWithCompletionBlock:^(NSArray *array, NSError *error) {
                                    [self waitViewShow:NO];

                                    if (error) {
                                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                                    }
                                    else {
                                        [array writeToPlistFile:@"cards"];
                                        NSMutableArray *cards = [[NSMutableArray alloc] initWithCapacity:array.count];

                                        for (NSDictionary *dict in array) {
                                            [cards addObject:[dict objectForKey:@"name"]];
                                        }

                                        self.titles = titles;
                                        self.countries = countries;
                                        self.cardTypes = cards;
                                    }
                                }];
                        }
                    }];
            }
        }];
}


- (NSArray *)titles {
    return [[self.entries objectAtIndex:7] objectForKey:@"values"];
}


- (void)setTitles:(NSArray *)titles {
    [[self.entries objectAtIndex:7] setObject:titles forKey:@"values"];
    [self.tableView reloadData];
}


- (NSArray *)countries {
    return [[self.entries objectAtIndex:14] objectForKey:@"values"];
}


- (void)setCountries:(NSArray *)countries {
    [[self.entries objectAtIndex:14] setObject:countries forKey:@"values"];
    [self.tableView reloadData];
}


- (NSArray *)cardTypes {
    return [[self.entries objectAtIndex:0] objectForKey:@"values"];
}


- (void)setCardTypes:(NSArray *)cardTypes {
    [[self.entries objectAtIndex:0] setObject:cardTypes forKey:@"values"];
    [self.tableView reloadData];
}



#pragma mark - Table methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
//    NSDictionary *cellData = [self.entries objectAtIndex:indexPath.row];
    
//    if ([cell isKindOfClass:[HYFormTextEntryCell class]] && [[cellData objectForKey:@"property"] isEqualToString:@"cardNumber"]) {
//        ((HYFormTextEntryCell *)cell).titleLabel.textColor = UIColor_warningTextColor;
//    }
    
    return cell;
}



#pragma mark - FormView Controller Delegate methods

- (void)submitWithArray:(NSArray *)array {
    logDebug(@"%@", array);
    NSArray *titles = [NSArray readFromPlistFile:@"titles"];
    NSString *titleCode = nil;

    for (NSDictionary *dict in titles) {
        if ([[dict objectForKey:@"name"] isEqualToString:[array objectAtIndex:7]]) {
            titleCode = [dict objectForKey:@"code"];
            break;
        }
    }

    NSArray *countries = [NSArray readFromPlistFile:@"countries"];
    NSString *countryCode = nil;

    for (NSDictionary *dict in countries) {
        if ([[dict objectForKey:@"name"] isEqual:[array objectAtIndex:14]]) {
            countryCode = [dict objectForKey:@"isocode"];
            break;
        }
    }

    NSArray *cards = [NSArray readFromPlistFile:@"cards"];
    NSString *cardCode = nil;

    for (NSDictionary *dict in cards) {
        if ([[dict objectForKey:@"name"] isEqual:[array objectAtIndex:0]]) {
            cardCode = [dict objectForKey:@"code"];
            break;
        }
    }

    [self waitViewShow:YES];

    if (self.inEditingMode) {
        [[HYWebService shared] updateCustomerPaymentInfoWithAccountHolderName:[array objectAtIndex:2]
            cardNumber:[array objectAtIndex:1]
            cardType:cardCode
            expiryMonth:[array objectAtIndex:3]
            expiryYear:[array objectAtIndex:4]
            saved:[[array objectAtIndex:5] boolValue]
            defaultPaymentInfo:[[array objectAtIndex:6] boolValue]
            paymentInfoID:self.paymentID
            completionBlock:^(NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    [self waitViewShow:YES];
                    [[HYWebService shared] updateCustomerPaymentInfoBillingAddresssWithFirstName:[array objectAtIndex:8]
                        lastName:[array objectAtIndex:9]
                        titleCode:titleCode
                        addressLine1:[array objectAtIndex:10]
                        addressLine2:[array objectAtIndex:11]
                        town:[array objectAtIndex:13]
                        postCode:[array objectAtIndex:12]
                        countryISOCode:countryCode
                        defaultPaymentInfo:[[array objectAtIndex:6] boolValue]
                        paymentInfoID:self.paymentID
                        completionBlock:^(NSError *error) {
                            [self waitViewShow:NO];

                            if (error) {
                                [[HYAppDelegate sharedDelegate] alertWithError:error];
                            }
                            else {
                                UIAlertView *alert =
                                    [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:@"Payment details edited" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
                                    otherButtonTitles
                                    :nil];
                                [alert show];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                }
            }];
    }
    else {
        [[HYWebService shared] createCustomerPaymentInfoWithAccountHolderName:[array objectAtIndex:2]
            cardNumber:[array objectAtIndex:1]
            cardType:cardCode
            expiryMonth:[array objectAtIndex:3]
            expiryYear:[array objectAtIndex:4]
            saved:[[array objectAtIndex:5] boolValue]
            defaultPaymentInfo:[[array objectAtIndex:6] boolValue]
            billingAddressTitleCode:titleCode
            firstName:[array objectAtIndex:8]
            lastName:[array objectAtIndex:9]
            addressLine1:[array objectAtIndex:10]
            addressLine2:[array objectAtIndex:11]
            postCode:[array objectAtIndex:12]
            town:[array objectAtIndex:13]
            countryISOCode:countryCode
            completionBlock:^(NSDictionary *dictionary, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    UIAlertView *alert =
                        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Success alert box title") message:@"Payment details added" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles
                        :nil];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
    }
}

@end
