//
// HYCheckoutViewController.m
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

#import "HYCheckoutViewController.h"
#import "HYLoginViewController.h"
#import "HYAddressListViewController.h"
#import "HYBasicCell.h"
#import "Price.h"
#import "HYCartViewController.h"
#import "HYPaymentListViewController.h"
#import "HYCheckoutSectionHeader.h"
#import "HYCheckoutSummaryCell.h"
#import "HYCheckoutDetailsCell.h"
#import "HYCheckoutNormalCell.h"


@interface HYCheckoutViewController ()

@property (weak, nonatomic) IBOutlet UIView *termsAndConditionsView;
@property (weak, nonatomic) IBOutlet UIImageView *termsAcceptanceCheckMark;
@property (weak, nonatomic) IBOutlet UIView *checkMarkFrame;
@property (weak, nonatomic) IBOutlet HYLabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmationButton;
@property (nonatomic, strong) Cart *checkoutCart;
@property (assign) BOOL viewAppeared;
@property (assign) BOOL checkoutReady;
@property (nonatomic) BOOL loginFailed;

- (IBAction)confirmOrder:(id)sender;
- (void)setConfirmationButtonEnabled:(BOOL)enabled;

@end


@implementation HYCheckoutViewController

@synthesize delegate = _delegate;
@synthesize viewAppeared = _viewAppeared;
@synthesize checkoutReady = _checkoutReady;

static NSString *basicIdentifier = @"Hybris Basic Cell";
static NSString *detailsCellIdentifier = @"Hybris Checkout Details Cell";
static NSString *summarycellIdentifier = @"Hybris Summary Cell";
static NSString *normalCellIdentifier = @"Hybris Checkout Normal Cell";


#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Checkout", @"Title of the checkout view and the button to get to the checkout page.");
    _viewAppeared = NO;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
    
    self.checkOutMode = DeliveryAddress;
    
    // Set up the tap gesture for the T&Cs
    UITapGestureRecognizer *termsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(acceptTermsAndConditions)];
    termsGesture.numberOfTapsRequired = 1;
    [self.termsAndConditionsView addGestureRecognizer:termsGesture];
    
    self.termsAndConditionsLabel.text = NSLocalizedString(@"I have read and agree with the Terms & Conditions", nil);
    self.termsAndConditionsLabel.font = UIFont_detailFont;
    self.termsAndConditionsLabel.textColor = UIColor_inverseTextColor;
    self.checkMarkFrame.layer.cornerRadius = 4;

    // Confirmation button
    self.confirmationButton.title = NSLocalizedStringWithDefaultValue(@"Confirm Order", nil, [NSBundle mainBundle], @"Confirm Order", @"Title for the confirm order button in the checkout");
    
    // Remove table view border
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}


- (void) acceptTermsAndConditions {
    if (self.termsAcceptanceCheckMark.hidden) {
        self.termsAcceptanceCheckMark.hidden = NO;
    }
    else {
        self.termsAcceptanceCheckMark.hidden = YES;
    }
    
    [self refreshConfirmView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self refreshConfirmView];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![HYAppDelegate sharedDelegate].isLoggedIn && !_viewAppeared && !self.loginFailed) {
        [self performSegueWithIdentifier:@"showLoginSegue" sender:self];
        _viewAppeared = YES;
    }
}


- (void)viewDidUnload {
    [self setTermsAndConditionsView:nil];
    [self setTermsAcceptanceCheckMark:nil];
    [self setCheckMarkFrame:nil];
    [self setTermsAndConditionsLabel:nil];
    [self setConfirmationButton:nil];
    [super viewDidUnload];
}


- (void)refreshConfirmView {
//    [self waitViewShow:YES];
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *array, NSError *error) {
//            [self waitViewShow:NO];

            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                if (array.count) {
                    self.checkoutCart = [array objectAtIndex:0];
                    
                    // Check for complete cart. Doesn't scale but we have a fixed set of fields
                    
                    // Start state
                    self.checkOutMode = DeliveryAddress;
                    if (self.checkoutCart.deliveryAddress) {
                        // Delivery address done
                        self.checkOutMode = DeliveryMode;
                        if (self.checkoutCart.deliveryMode) {
                            // Delivery mode done
                            self.checkOutMode = PaymentDetails;
                            if (self.checkoutCart.paymentInfo) {
                                // Payement details done
                                self.checkOutMode = Complete;
                                if (!self.termsAcceptanceCheckMark.hidden) {
                                    // Ts&Cs done
                                    self.checkoutReady = YES;
                                    [self setConfirmationButtonEnabled:YES];
                                }
                                else {
                                    [self setConfirmationButtonEnabled:NO];
                                }
                            }
                        else {
                            [self setConfirmationButtonEnabled:NO];
                        }
                    }
                    else {
                        [self setConfirmationButtonEnabled:NO];
                    }
                }
                else {
                    [self setConfirmationButtonEnabled:NO];
                }
                [self.tableView reloadData];
            }
        self.confirmationButton.enabled = self.checkoutReady;
    }
     }];
}


- (void)setConfirmationButtonEnabled:(BOOL)enabled {
    if (enabled) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.confirmationButton setTintColor:UIColor_highlightTint];
            [self.confirmationButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor],  UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];
        }
    }
    else {
        self.checkoutReady = NO;
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.confirmationButton setTintColor:UIColor_standardTint];
            [self.confirmationButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        }
    }
}


- (NSArray *)addressArray {
    if (self.checkoutCart.deliveryAddress.count) {
        NSMutableArray *retArray = [[NSMutableArray alloc] init];

        //Checks to ensure no null values are sent
        [retArray addObject:[NSArray arrayWithObjects:[self.checkoutCart.deliveryAddress objectForKey:@"title"], [self.checkoutCart.deliveryAddress objectForKey:@"firstName"],
                             [self.checkoutCart.deliveryAddress objectForKey:@"lastName"], nil]];
        
        if([self.checkoutCart.deliveryAddress objectForKey:@"line1"] != nil) {
            [retArray addObject:[self.checkoutCart.deliveryAddress objectForKey:@"line1"]];
        }
        
        if ([self.checkoutCart.deliveryAddress objectForKey:@"line2"]  != nil) {
            [retArray addObject:[self.checkoutCart.deliveryAddress objectForKey:@"line2"]];

        }
        if ([self.checkoutCart.deliveryAddress objectForKey:@"town"]  != nil) {
            [retArray addObject:[self.checkoutCart.deliveryAddress objectForKey:@"town"]];

        }
        if ([self.checkoutCart.deliveryAddress objectForKey:@"postalCode"]  != nil) {
            [retArray addObject:[self.checkoutCart.deliveryAddress objectForKey:@"postalCode"]];
        }
        if ([[self.checkoutCart.deliveryAddress objectForKey:@"country"] objectForKey:@"name"]  != nil) {
            [retArray addObject:[[self.checkoutCart.deliveryAddress objectForKey:@"country"] objectForKey:@"name"]];
        }
        return retArray;
    }
    else {
        return [NSArray arrayWithObject:NSLocalizedString(@"Delivery Address", nil)];
    }
}


- (NSArray *)basketSummaryArray {
    if (self.checkoutCart.totalUnitCount) {
        NSString *itemString;
        
        if ([self.checkoutCart.totalUnitCount intValue] > 1) {
            itemString = @"Items";
        }
        else {
            itemString = @"Item";
        }
        
        return [NSArray arrayWithObjects:
                [NSString stringWithFormat:@"%@ %@", self.checkoutCart.totalUnitCount ,itemString],
                self.checkoutCart.totalDiscounts.formattedValue,
                self.checkoutCart.totalTax.formattedValue,
                self.checkoutCart.totalPrice.formattedValue,
                nil];
    }
    else {
        return [NSArray arrayWithObject:NSLocalizedString(@"Empty Cart", nil)];
    }
    
}


- (NSArray *)deliveryModeArray {
    if (self.checkoutCart.deliveryMode.count) {
        return [NSArray arrayWithObjects:
            [self.checkoutCart.deliveryMode objectForKey:@"name"],
            [self.checkoutCart.deliveryMode objectForKey:@"description"],
            [[self.checkoutCart.deliveryMode objectForKey:@"deliveryCost"] objectForKey:@"formattedValue"],
            nil];
    }
    else {
        return [NSArray arrayWithObject:NSLocalizedString(@"Delivery Method", nil)];
    }
}


- (NSArray *)paymentArray {
    if (self.checkoutCart.paymentInfo.count) {
        return [NSArray arrayWithObjects:
            [self.checkoutCart.paymentInfo valueForKeyPath:@"accountHolderName"],
            [self.checkoutCart.paymentInfo valueForKeyPath:@"cardNumber"],
            [self.checkoutCart.paymentInfo valueForKeyPath:@"cardType.name"],
            nil];
    }
    else {
        return [NSArray arrayWithObject:NSLocalizedString(@"Payment Method", @"Name of the section where the user can chose the payment method.")];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"1. Delivery address", nil);
    }
    else if (section == 1) {
        return NSLocalizedString(@"2. Delivery method", nil);
    }
    else if (section == 2) {
        return NSLocalizedString(@"3. Payment details", nil);
    }
    else if (section == 3) {
        return NSLocalizedString(@"Summary", nil);
    }
    else {
        return @"";
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    HYCheckoutSectionHeader *header = [[HYCheckoutSectionHeader alloc] initWithTitle:[self tableView:tableView titleForHeaderInSection:section]];

    if (section == 0 && self.checkoutCart.deliveryAddress.count && header.label.text.length) {
        header.tickImage.hidden = NO;
    }

    if (section == 1 && self.checkoutCart.deliveryMode.count && header.label.text.length) {
        header.tickImage.hidden = NO;   
    }
    
    if (section == 2 && self.checkoutCart.paymentInfo.count && header.label.text.length) {
        header.tickImage.hidden = NO;
    }
    
    return  header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;

    switch (indexPath.section) {
        case 0: {
            height = [HYBasicCell heightForCellWithContents:[self addressArray]];
        }
        break;
        case 1: {
            height = [HYBasicCell heightForCellWithContents:[self deliveryModeArray]];
        }
        break;
        case 2: {
            height = [HYBasicCell heightForCellWithContents:[self paymentArray]];
        }
        break;
        case 3: {
            height = 83;
        }
        break;
        case 4: {
            height = 44;
        }
        break;
        default: {
            height = 0.0;
        }
        break;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYCheckoutDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:detailsCellIdentifier];
    HYBasicCell *basicCell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
    HYCheckoutNormalCell *normalCell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];

    id finalCell;
    switch (indexPath.section) {
        case 0: {

            [cell decorateCellLabelWithContentsAndBoldTitle:[self addressArray]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;

            if (self.checkOutMode >= indexPath.section) {
                cell.userInteractionEnabled = YES;
                cell.backgroundColor = [UIColor whiteColor];
                
            }
            else {
                cell.userInteractionEnabled = NO;
                [cell.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
            }
            
            finalCell = cell;

            break;
        }
        case 1: {
            [normalCell decorateCellLabelWithContents:[self deliveryModeArray]];
            normalCell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (self.checkOutMode >= indexPath.section) {
                normalCell.userInteractionEnabled = YES;
                normalCell.backgroundColor = [UIColor whiteColor];
                
            }
            else {
                normalCell.userInteractionEnabled = NO;
                [normalCell.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
            }

            finalCell = normalCell;
            break;
        }
        case 2: {
            [normalCell decorateCellLabelWithContents:[self paymentArray]];
            normalCell.selectionStyle = UITableViewCellSelectionStyleGray;

            if (self.checkOutMode >= indexPath.section) {
                normalCell.userInteractionEnabled = YES;
                normalCell.backgroundColor = [UIColor whiteColor];
                
            }
            else {
                normalCell.userInteractionEnabled = NO;
                [normalCell.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
            }
            
            finalCell = normalCell;
            break;
        }
        case 3: {
            HYCheckoutSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:summarycellIdentifier];
            
            if (cell == nil) {
                cell = [[HYCheckoutSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:summarycellIdentifier];
            }
            [cell decorateCellLabelWithContents:[self basketSummaryArray]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            finalCell = cell;
            break;
        }
        case 4: {

            [basicCell decorateCellLabelWithContents:NSLocalizedString(@"Your Basket", @"Title of the customers basket view.")];
            basicCell.selectionStyle = UITableViewCellSelectionStyleGray;
//            basicCell.accessoryView =
//            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
            basicCell.backgroundColor = [UIColor whiteColor];

            [basicCell.contentView.layer setCornerRadius:7];
            [basicCell.contentView.layer setBorderWidth:1.0f];
            [basicCell.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
            
            finalCell = basicCell;
            break;
        }
        default: {
        }
        break;
    }
    return finalCell;
}



#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0: {
            [self performSegueWithIdentifier:@"Show Address Segue" sender:self];
        }
        break;
        case 1: {
            [self performSegueWithIdentifier:@"Show Delivery Segue" sender:self];
        }
        break;
        case 2: {
            [self performSegueWithIdentifier:@"Show Payment Segue" sender:self];
        }
        break;
        case 3: 
        break;
        case 4:{
            [self performSegueWithIdentifier:@"Show Cart Segue" sender:self];
        }
        break;
        default: {
        }
        break;
    }
}



#pragma mark - Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLoginSegue"]) {
        HYLoginViewController *vc = (HYLoginViewController *)((UINavigationController *)segue.destinationViewController).visibleViewController;
        vc.delegate = self;
    }

    if ([segue.identifier isEqualToString:@"Show Address Segue"]) {
        HYAddressListViewController *vc = (HYAddressListViewController *)(UINavigationController *)segue.destinationViewController;
        vc.canSelectAddress = YES;
        [self setShowPlainBackButton:YES];
    }

    if ([segue.identifier isEqualToString:@"Show Payment Segue"]) {
        HYPaymentListViewController *vc = (HYPaymentListViewController *)(UINavigationController *)segue.destinationViewController;
        vc.canSelectPayment = YES;
        [self setShowPlainBackButton:YES];
    }
    else if ([segue.identifier isEqualToString:@"Show Cart Segue"]) {
        HYCartViewController *vc = (HYCartViewController *)(UINavigationController *)segue.destinationViewController;
        vc.navigationItem.rightBarButtonItem = nil;
        [vc makeReadOnly];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}



#pragma mark - ModalViewControllerDelegate

- (void)requestDismissAnimated:(BOOL)animated sender:(id)sender {
    [self dismissModalViewControllerAnimated:NO];

    if (![HYAppDelegate sharedDelegate].isLoggedIn) {
        self.loginFailed = YES;
        [self dismiss:self];
    }
}



#pragma mark - IB action methods

- (IBAction)dismiss:(id)sender {
    _viewAppeared = NO;
    [self.delegate requestDismissAnimated:YES sender:self];
}


- (IBAction)confirmOrder:(id)sender {
    if (self.checkoutReady) {
        [self waitViewShow:YES];
        [[HYWebService shared] placeOrderForCartWithCompletionBlock:^(NSDictionary *dictionary, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    [self.delegate modalViewDismissedWithInfo:dictionary animated:NO sender:self];
                }
            }];
    }
    else {
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"Accept our terms and conditons." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
            otherButtonTitles:nil];
        [alert show];
    }
}

@end
