//
// HYLoginViewController.h
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

#import "HYViewController.h"
#import "ModalViewControllerDelegate.h"

@class HYTextField;

@interface HYLoginViewController:HYViewController<UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak) id<ModalViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HYTextField *emailAddressField;
@property (weak, nonatomic) IBOutlet HYTextField *passwordField;
@property (weak, nonatomic) IBOutlet HYButton *forgottenPasswordButton;
@property (weak, nonatomic) IBOutlet HYLabel *returningCustomerLabel;
@property (weak, nonatomic) IBOutlet HYButton *createNewCustomerButton;
@property (weak, nonatomic) IBOutlet HYButton *loginButton;

- (IBAction)dismiss:(id)sender;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)signIn:(id)sender;
- (IBAction)registerNewUser:(id)sender;

@end
