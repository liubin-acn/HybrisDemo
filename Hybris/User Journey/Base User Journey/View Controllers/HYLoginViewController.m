//
// HYLoginViewController.m
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

#import "HYLoginViewController.h"

#import "HYRegisterUserViewController.h"


@interface HYLoginViewController ()

@end


@implementation HYLoginViewController

@synthesize tableView = _tableView;
@synthesize emailAddressField = _emailAddressField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;
@synthesize createNewCustomerButton = createNewCustomerButton;
@synthesize delegate;


#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Sign in", @"Title for login view");
    self.returningCustomerLabel.text = NSLocalizedStringWithDefaultValue(@"Returning Customer", nil, [NSBundle mainBundle], @"Returning Customer", @"Returning Customer label");
    self.returningCustomerLabel.font = UIFont_titleFont;
    
    self.emailAddressField.placeholder = NSLocalizedString(@"Email address", @"Placeholder for email login field");
    self.passwordField.placeholder = NSLocalizedString(@"Password", @"Placeholder for password login field");
    
    [self.forgottenPasswordButton setTitle:NSLocalizedString(@"Forgotten your password?", @"Button text for forgotten password") forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"Login", @"Login button") forState:UIControlStateNormal];
    [self.createNewCustomerButton setTitle:NSLocalizedString(@"New customer", @"Button text for new customer") forState:UIControlStateNormal];
        
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Cancel", @"Title for the cancel button.");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([HYAppDelegate sharedDelegate].isLoggedIn) {
        self.emailAddressField.text = [HYAppDelegate sharedDelegate].username;
        //should try and renew access_token or logout the user
    }

    [self.forgottenPasswordButton makeLinkStyle];
    self.forgottenPasswordButton.titleLabel.font = UIFont_smallLinkFont;

    [self.emailAddressField becomeFirstResponder];
}


- (void)viewDidUnload {
    [self setEmailAddressField:nil];
    [self setPasswordField:nil];
    [self setForgottenPasswordButton:nil];
    [self setReturningCustomerLabel:nil];
    [super viewDidUnload];
}



#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}



#pragma mark - Actions

- (IBAction)dismiss:(id)sender {
    [self.delegate requestDismissAnimated:YES sender:self];
}


- (IBAction)forgotPassword:(id)sender {
    if (self.emailAddressField.text.length) {
        [[HYWebService shared] forgotPasswordWithLogin:self.emailAddressField.text completionBlock:^(NSError *error) {
            if (error) {
                [self displayForgottenPasswordAlertWithMessage:NSLocalizedStringWithDefaultValue(@"Email address not found", nil, [NSBundle mainBundle], @"Email address not found", @"Message for when a password request fails because email address is not found")];
            }
            else {
                [self displayForgottenPasswordAlertWithMessage:NSLocalizedStringWithDefaultValue(@"Password reset email sent", nil, [NSBundle mainBundle], @"Password reset email sent", @"Message for when a password reset email has been sent")];
            }
        }];
    }
    else {
        [self displayForgottenPasswordAlertWithMessage:NSLocalizedStringWithDefaultValue(@"Please enter an email address", nil, [NSBundle mainBundle], @"Please enter an email address", @"Message for when a password reset failed due to no email")];
    }
    
}


- (void)displayForgottenPasswordAlertWithMessage:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Forgot Password", nil, [NSBundle mainBundle], @"Forgot your password", @"Forgot password alert title")
                                                    message:message
                                                   delegate:[[UIApplication sharedApplication] delegate] cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK button"), nil];
    [alert show];
    
}


- (IBAction)signIn:(id)sender {
    [[HYWebService shared] loginWithUsername:self.emailAddressField.text password:self.passwordField.text completionBlock:^(NSError *error) {
            if (error) {
                [[HYAppDelegate sharedDelegate] setIsLoggedIn:NO];
                [[HYAppDelegate sharedDelegate] setUsername:nil];
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                // Get the profile information
                [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *profileDictionary, NSError *error) {
                        // Set the locale info from the profile
                        [[NSUserDefaults standardUserDefaults] setValue:[[profileDictionary objectForKey:@"language"] objectForKey:@"isocode"] forKey:
                            @"web_services_language_preference"];
                        [[NSUserDefaults standardUserDefaults] setValue:[[profileDictionary objectForKey:@"currency"] objectForKey:@"isocode"] forKey:
                            @"web_services_currency_preference"];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        [[HYAppDelegate sharedDelegate] setUsername:self.emailAddressField.text];
                        [[HYAppDelegate sharedDelegate] setIsLoggedIn:YES];
                        [self performBlock:^{
                                [self.delegate requestDismissAnimated:YES sender:self];
                            } afterDelay:0.3];
                    }];
            }
        }];
}


- (IBAction)registerNewUser:(id)sender {
    HYRegisterUserViewController *vc = [[HYRegisterUserViewController alloc] initWithTitle:NSLocalizedString(@"Register", @"Register view title")];

    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Scroll delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}



#pragma mark - Helper methods

- (void)dismissKeyboard {
    [self.emailAddressField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}



#pragma mark - TextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailAddressField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == _passwordField) {
        [self signIn:self];
    }

    return YES;
}

@end
