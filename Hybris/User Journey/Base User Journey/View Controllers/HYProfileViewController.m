//
// HYProfileViewController.m
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

#import "HYProfileViewController.h"
#import "HYLoginViewController.h"
#import "HYAddressListViewController.h"
#import "HYArrayViewController.h"
#import "HYChangePasswordViewController.h"
#import "HYChangeEmailViewController.h"
#import "HYProfileDetailViewController.h"

/// Define the cell ordering
typedef enum {
    HYOrderHistoryCell = 0,
    HYAddressBookCell = 1,
    HYPaymentDetailsCell = 2,
    HYUpdateProfileCell = 3,
    HYChangeEmailCell = 4,
    HYChangePasswordCell = 5
} HYLoggedInCellPosition;


@interface HYProfileViewController ()

@property (nonatomic, strong) NSDictionary *profile;
@property (nonatomic) BOOL viewAppeared;

- (void)updateHeaderView;

@end


@implementation HYProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _viewAppeared = NO;
    self.profileNameLabel.text = @"";
    self.profileNameLabel.font = UIFont_headerFooterFont;
    self.profileNameLabel.textColor = [UIColor whiteColor];
    self.profileEmailLabel.text = @"";
    self.profileEmailLabel.font = UIFont_smallBoldFont;
    self.profileEmailLabel.textColor = [UIColor whiteColor];
    self.notLoggedInLabel.textColor = [UIColor whiteColor];

    self.title = NSLocalizedString(@"Account", nil);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self updateHeaderView];
}


- (void)viewDidUnload {
    [self setProfileNameLabel:nil];
    [self setProfileEmailLabel:nil];
    [self setLogInOutButton:nil];
    [self setNotLoggedInLabel:nil];
    [super viewDidUnload];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([HYAppDelegate sharedDelegate].isLoggedIn) {
        return 2;
    }
    else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Common section
    if (section == 0) {
        return 0;
    }
    // Logged-in section
    else {
        return 6;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MenuIdentifier = @"Hybris Menu Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];

    switch (indexPath.row) {
        case HYOrderHistoryCell: {
            cell.textLabel.text = NSLocalizedString(@"Order History", "Title for the view that shows the order history.");
        }
            break;
        case HYAddressBookCell: {
            cell.textLabel.text = NSLocalizedString(@"Address Book", "Title for the view that shows the users address book.");
        }
            break;
        case HYPaymentDetailsCell: {
            cell.textLabel.text = NSLocalizedString(@"Payment Details", "Title for the view that shows the users payment details.");
        }
            break;
        case HYUpdateProfileCell: {
            cell.textLabel.text = NSLocalizedString(@"Update Profile", "Title for the view to update the users profile.");
        }
            break;
        case HYChangeEmailCell: {
            cell.textLabel.text = NSLocalizedString(@"Change Email", "Title for the view to change the users email.");
        }
            break;
        case HYChangePasswordCell: {
            cell.textLabel.text = NSLocalizedString(@"Change Password", "Title for the view to change the users password.");
        }            
        default: {
        }
        break;
    }

    return cell;
}


#pragma mark - Table view delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case HYUpdateProfileCell:
        {
            HYProfileDetailViewController *vc = [[HYProfileDetailViewController alloc] initWithTitle:NSLocalizedString(@"Update Profile", "Title for the view to update the users profile.") values:self.profile];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case HYChangePasswordCell:
        {
            HYChangePasswordViewController *vc = [[HYChangePasswordViewController alloc] initWithTitle:NSLocalizedString(@"Change Password", "Title for the view to change the users password.")];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case HYChangeEmailCell: {
            HYChangeEmailViewController *vc = [[HYChangeEmailViewController alloc] initWithTitle:NSLocalizedString(@"Change Email", "Title for the view to change the users email.")];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case HYAddressBookCell: {
            [self performSegueWithIdentifier:@"Show Address Segue" sender:self];
        }
        break;
        case HYPaymentDetailsCell: {
            [self performSegueWithIdentifier:@"Show Payment Segue" sender:self];
        }
        break;
        case HYOrderHistoryCell: {
            [self performSegueWithIdentifier:@"Show Order Segue" sender:self];
        }
        break;
        default: {
        }
        break;
    }
}



#pragma mark - Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Profile to Login Segue"]) {
        HYLoginViewController *vc = (HYLoginViewController *)((UINavigationController *)segue.destinationViewController).visibleViewController;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Show Address Segue"]) {
        HYAddressListViewController *vc = (HYAddressListViewController *)(UINavigationController *)segue.destinationViewController;
        vc.canSelectAddress = NO;
    }
    else if ([segue.identifier isEqualToString:@"Show Languages Segue"]) {
        HYArrayViewController *vc = (HYArrayViewController *)(UINavigationController *)segue.destinationViewController;
        [vc waitViewShow:YES];
        [[HYWebService shared] languagesWithCompletionBlock:^(NSArray *languages, NSError *error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    // Get the profile information
                    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *profileDictionary, NSError *error) {
                            if (error) {
                                [[HYAppDelegate sharedDelegate] alertWithError:error];
                            }
                            else {
                                vc.classType = NSStringFromClass ([NSDictionary class]);
                                vc.key = @"nativeName";
                                vc.details = languages;

                                // Find current language and select it
                                for (int i = 0; i < vc.details.count; i++) {
                                    if ([[[vc.details objectAtIndex:i] objectForKey:@"isocode"] isEqualToString:[[profileDictionary objectForKey:@"language"]
                                                objectForKey:@"isocode"]]) {
                                        vc.selectedItem = i;
                                        break;
                                    }
                                }
                            }
                        }];
                }
            }];
    }
    else if ([segue.identifier isEqualToString:@"Show Currencies Segue"]) {
        HYArrayViewController *vc = (HYArrayViewController *)(UINavigationController *)segue.destinationViewController;
        [vc waitViewShow:YES];
        [[HYWebService shared] currenciesWithCompletionBlock:^(NSArray *currencies, NSError *error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    // Get the profile information
                    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *profileDictionary, NSError *error) {
                            if (error) {
                                [[HYAppDelegate sharedDelegate] alertWithError:error];
                            }
                            else {
                                vc.classType = NSStringFromClass ([NSDictionary class]);
                                vc.key = @"name";
                                vc.details = currencies;

                                // Find current currency and select it
                                for (int i = 0; i < vc.details.count; i++) {
                                    if ([[[vc.details objectAtIndex:i] objectForKey:@"isocode"] isEqualToString:[[profileDictionary objectForKey:@"currency"]
                                                objectForKey:@"isocode"]]) {
                                        vc.selectedItem = i;
                                        break;
                                    }
                                }
                            }
                        }];
                }
            }];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}



#pragma mark - ModalViewControllerDelegate

- (void)requestDismissAnimated:(BOOL)animated sender:(id)sender {
    [self dismissModalViewControllerAnimated:animated];
}



#pragma mark - IB action methods

- (IBAction)login:(id)sender {
    if (![HYAppDelegate sharedDelegate].isLoggedIn) {
        [self performSegueWithIdentifier:@"Profile to Login Segue" sender:self];
    }
}


- (IBAction)logout:(id)sender {
    if ([HYAppDelegate sharedDelegate].isLoggedIn) {
        [[HYAppDelegate sharedDelegate] setIsLoggedIn:NO];
        [[HYAppDelegate sharedDelegate] setUsername:nil];

        [self updateHeaderView];
    }
}



#pragma mark - private methods

- (void)updateHeaderView {    
    self.notLoggedInLabel.text = NSLocalizedString(@"Not logged in", @"User not logged in message");
    
    if ([HYAppDelegate sharedDelegate].isLoggedIn) {
        UIBarButtonItem *logoutButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Logout", nil, [NSBundle mainBundle], @"Logout", @"Logout button")
                                         style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
        self.navigationItem.rightBarButtonItem = logoutButton;
        [self waitViewShow:YES];
        
        [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *dictionary, NSError *error) {
            [self waitViewShow:NO];
            
            if (error) {
                if ([[error.userInfo objectForKey:@"reason"] isEqualToString:@"Refresh Token Failed"]) {
                    [[HYAppDelegate sharedDelegate] setIsLoggedIn:NO];
                    self.profileNameLabel.text = @"";
                    self.profileEmailLabel.text = @"";
                    self.notLoggedInLabel.hidden = NO;
                    
                    UIBarButtonItem *loginButton =
                    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue (@"Login", nil, [NSBundle mainBundle], @"Login", @"Login button")
                                                     style:UIBarButtonItemStylePlain target:self action:@selector(login:)];
                    self.navigationItem.rightBarButtonItem = loginButton;
                    [self.tableView reloadData];
                } else {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
            }
            else {
                if ([HYAppDelegate sharedDelegate].isLoggedIn) {
                    self.profile = [NSDictionary dictionaryWithDictionary:dictionary];
                    self.profileEmailLabel.text = [_profile objectForKey:@"displayUid"];
                    self.profileNameLabel.text = [_profile objectForKey:@"name"];
                    self.notLoggedInLabel.hidden = YES;
                    [self.tableView reloadData];
                }
            }
        }];
    } else {
        self.profileNameLabel.text = @"";
        self.profileEmailLabel.text = @"";
        self.notLoggedInLabel.hidden = NO;
        
        UIBarButtonItem *loginButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue (@"Login", nil, [NSBundle mainBundle], @"Login", @"Login button")
                                         style:UIBarButtonItemStylePlain target:self action:@selector(login:)];
        self.navigationItem.rightBarButtonItem = loginButton;
        [self.tableView reloadData];
    }
}

@end
