//
// HYCartViewController.m
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

#import "HYCartViewController.h"
#import "CartEntry.h"

#import "Price.h"
#import "HYCheckoutViewController.h"
#import "HYCartCell.h"
#import "HYProductPromotionCell.h"
#import "HYBasicCell.h"
#import "HYOrderDetailViewController.h"

#import "BeaconsService.h"
#import "BeaconsConfigurer.h"

@interface HYCartViewController () <UIAlertViewDelegate, BeaconConfigureDelegate>

@property (nonatomic, strong) Cart *cartObj;
@property (nonatomic) BOOL readonly;

@property (strong, nonatomic) BeaconsConfigurer *beaconsConfigure;
@property (strong, nonatomic) NSDictionary *beaconsConfigureData;

@property (nonatomic) BOOL hasShow;

- (CGFloat)heightForCellForPromotionsAtIndexPath:(NSIndexPath *)indexPath;

@end


@implementation HYCartViewController

static NSString *basicIdentifier = @"Hybris Basic Cell";

/// Define the section ordering
typedef enum {
    HYCartSectionDeliveryMode = 0,
    HYCartSectionProducts = 1,
    HYCartSectionPotentialPromotions = 2,
    HYCartSectionAppliedPromotions = 3,
} HYCartSectionPosition;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.totalUnitCountLabel.text = @"";
    self.totalUnitCountLabel.font = UIFont_titleFont;
    self.totalUnitCountLabel.textColor = UIColor_textColor;
    self.totalPriceLabel.text = @"";
    self.totalPriceLabel.font = UIFont_titleFont;
    self.totalPriceLabel.textColor = UIColor_lightBlueTextTint;
    
    self.title = NSLocalizedString(@"Your Basket", @"Title of the customers basket view.");
    
    // Get the cart
    [self loadCartDetails];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Edit", @"Title for the edit button.");
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Checkout", @"Title of the checkout view and the button to get to the checkout page.");
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incrementCartBadge)
                                                 name:HYItemAddedToCart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(decrementCartBadge)
                                                 name:HYItemRemovedFromCart object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
    
    self.beaconsConfigure = [[BeaconsConfigurer alloc] initWithDelegate:self];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BeaconConfiguration" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.beaconsConfigureData = dic[@"Beacons"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadCartDetails];
}


- (void)viewWillDisappear:(BOOL)animated {
    if (self.tableView.editing) {
        [self setEditing:NO animated:NO];
    }
    
    [super viewWillDisappear:animated];
    [[BeaconsService sharedBeaconsService] stopRangingBeacons];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}


- (void)makeReadOnly {
    self.readonly = YES;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)incrementCartBadge {
    if (!_cartObj) {
        [self loadCartDetails];
        self.navigationController.tabBarItem.badgeValue = @"1";
    }
    else {
        self.cartObj.totalUnitCount = [NSNumber numberWithInt:[self.cartObj.totalUnitCount intValue] + 1];
        self.navigationController.tabBarItem.badgeValue = [self.cartObj.totalUnitCount stringValue];
    }
}


- (void)decrementCartBadge {
    self.cartObj.totalUnitCount = [NSNumber numberWithInt:[self.cartObj.totalUnitCount intValue] - 1];
    self.navigationController.tabBarItem.badgeValue = [self.cartObj.totalUnitCount stringValue];
}


- (void)valueChanged:(id)sender {
    HYButton *picker = (HYButton *)sender;
    CartEntry *cartEntry = [self.cartObj.entries objectAtIndex:picker.tag];
    
    [[HYWebService shared] productWithCode:cartEntry.product.productCode options:[NSArray arrayWithObject:HYProductOptionStock] completionBlock:^(NSArray *
                                                                                                                                                  array, NSError *error) {
        HYProduct *product = [array objectAtIndex:0];
        
        // Create the number of items to pass to the picker
        NSInteger rows = [product.stockLevel integerValue];
        NSMutableArray *values = [HYPickerControl arrayFromQuantity:rows withZero:YES];
        
        //If there is a value selected, use it as the beginning index of the picker
        NSInteger index = [cartEntry.quantity integerValue];
        
        NSInteger cartEntryIndex = [cartEntry.entryNumber integerValue];
        
        [HYPickerControl showPickerWithValues:values labels:nil index:index completionBlock:^(NSInteger result) {
            if (result == 0) {
                [[HYWebService shared] deleteProductInCartAtEntry:cartEntryIndex completionBlock:^(NSDictionary *dictionary, NSError *error) {
                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }
                    else {
                        NSMutableArray *editedArray = [NSMutableArray arrayWithArray:self.cartObj.entries];
                        [editedArray removeObjectAtIndex:cartEntryIndex];
                        self.cartObj.entries = [NSArray arrayWithArray:editedArray];
                        [self loadCartDetails];
                        [self.tableView reloadData];
                    }
                }];
            }
            else {
                [[HYWebService shared] updateProductInCartAtEntry:picker.tag quantity:result completionBlock:^(NSDictionary *dictionary, NSError *
                                                                                                               error) {
                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }
                    else {
                        logDebug (@"%@", dictionary);
                        [self loadCartDetails];
                    }
                }];
            }
        }];
    }];
}



#pragma mark - Cart methods

- (void)loadCartDetails {
    [self waitViewShow:YES];
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *array, NSError *error) {
        [self waitViewShow:NO];
        
        if (!error) {
            _cartObj = [array objectAtIndex:0];
            
            self.navigationController.tabBarItem.badgeValue = [self.cartObj.totalUnitCount stringValue];
            
            if (_cartObj.entries.count > 0) {
                
                __weak typeof(self) weak_self = self;

                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"A77A1B68-49A7-4DBF-914C-760D07FBB87B"];
                
                [[BeaconsService sharedBeaconsService] startRangingBeaconsWithUUID:uuid identifier:@"com.accenture.beacons" rangingBeaconsHandler:^(NSArray *aBeacons, NSError *error) {
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        });
                    } else {
                        static dispatch_queue_t queue_t;
                        if (!queue_t) {
                            queue_t = dispatch_queue_create("com.accenture.beacon", NULL);
                        }
                        
                        if (!weak_self.hasShow) {
                            dispatch_async(queue_t, ^{
                                NSPredicate *predicate = [NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
                                    ESTBeacon *beacon = (ESTBeacon *)evaluatedObject;
                                    if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate) {
                                        return YES;
                                    }
                                    return NO;
                                }];
                                
                                // filter near beacons
                                NSArray *nearBeacons = [aBeacons filteredArrayUsingPredicate:predicate];
                                NSMutableArray *codes = [NSMutableArray array];
                                
                                for (ESTBeacon *beacon in nearBeacons) {
                                    [codes addObjectsFromArray:[weak_self.beaconsConfigure dataForBeacon:beacon]];
                                }
                                
                                if (codes.count > 0) {
                                    NSMutableString *names = [NSMutableString string];
                                    
                                    for (NSString *code in codes) {
                                        NSPredicate *predicate = [NSPredicate predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
                                            CartEntry *entry = (CartEntry *)evaluatedObject;
                                            if ([entry.product.productCode isEqualToString:code]) {
                                                return YES;
                                            }
                                            return NO;
                                        }];
                                        
                                        NSArray *entrys = [_cartObj.entries filteredArrayUsingPredicate:predicate];
                                        
                                        if (entrys.count > 0) {
                                            for (CartEntry *entry in entrys) {
                                                [names appendFormat:@"%@\n", entry.product.name];
                                            }
                                        }
                                    }
                                    
                                    if (names.length > 0) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You will find" message:names delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            alert.delegate = self;
                                            
                                            [alert show];
                                            [weak_self setHasShow:YES];
                                        });
                                    }
                                }
                            });
                        }
                    }
                }];
            }
            
            [self refreshToolbar];
            [self.tableView reloadData];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self performSelector:@selector(updateShowState) withObject:nil afterDelay:15.f];
}

- (void)updateShowState {
    [self setHasShow:NO];
}

- (void)refreshToolbar {
    self.totalPriceLabel.text = _cartObj.totalPrice.formattedValue;
    
    NSString *labelString = [NSString stringWithFormat:NSLocalizedString(@"%1$i item", @"Total cart items in singular"), [_cartObj.totalUnitCount integerValue]];
    
    if ([_cartObj.totalUnitCount integerValue] > 1) {
        labelString = [NSString stringWithFormat:NSLocalizedString(@"%1$i items", @"Total cart items in plural"), [_cartObj.totalUnitCount integerValue]];
    }
    
    self.totalUnitCountLabel.text = labelString;
    self.navigationController.tabBarItem.badgeValue = [_cartObj.totalUnitCount stringValue];
    
    if ([_cartObj.totalUnitCount integerValue] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.navigationItem.rightBarButtonItem setTintColor:UIColor_highlightTint];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor],  UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];
        }
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.navigationItem.rightBarButtonItem setTintColor:UIColor_standardTint];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - BeaconConfigureDelegate

- (id)beaconsConfigure:(BeaconsConfigurer *)beaconsConfigure dataForBeacon:(ESTBeacon *)beacon {
    NSInteger major = [beacon.major integerValue];
    NSInteger minor = [beacon.minor integerValue];
    NSString *key = [NSString stringWithFormat:@"%i", major * 65535 + minor];
    
    return self.beaconsConfigureData[key];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HYCartSectionDeliveryMode :
            return 1;
            
            break;
        case HYCartSectionProducts: {
            return _cartObj.entries.count;
        }
            break;
        case HYCartSectionPotentialPromotions: {
            if ((self.cartObj.potentialProductPromotions && self.cartObj.potentialProductPromotions.count)) {
                return _cartObj.potentialProductPromotions.count;
            }
            else {
                return 0;
            }
        }
            break;
        case HYCartSectionAppliedPromotions: {
            if ((self.cartObj.appliedProductPromotions && self.cartObj.appliedProductPromotions.count)) {
                return _cartObj.appliedProductPromotions.count;
            }
            else {
                return 0;
            }
        }
            break;
        default: {
            return 0;
        }
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case HYCartSectionDeliveryMode: {
            if (_cartObj.deliveryMode.count) {
                return [HYBasicCell heightForCellWithContents:[NSArray arrayWithObjects:
                                                               [_cartObj.deliveryMode objectForKey:@"name"],
                                                               [_cartObj.deliveryMode objectForKey:@"description"],
                                                               [[_cartObj.deliveryMode objectForKey:@"deliveryCost"] objectForKey:@"formattedValue"],
                                                               nil]];
            }
            else {
                return 0;
            }
        }
            break;
        case HYCartSectionProducts: {
            return 160.0;
        }
            break;
        case HYCartSectionPotentialPromotions: {
            if (self.cartObj.potentialProductPromotions && ((NSArray *)self.cartObj.potentialProductPromotions).count) {
                return [self heightForCellForPromotionsAtIndexPath:indexPath];
            }
            else {
                return 0.0;
            }
        }
            break;
        case HYCartSectionAppliedPromotions: {
            if (self.cartObj.appliedProductPromotions && ((NSArray *)self.cartObj.appliedProductPromotions).count) {
                return [self heightForCellForPromotionsAtIndexPath:indexPath];
            }
            else {
                return 0.0;
            }
        }
            break;
        default: {
            return 0;
        }
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cartIdentifier = @"Hybris Cart Cell";
    static NSString *promotionCellIdentifier = @"Product Promotion Cell";
    
    id finalCell;
    
    switch (indexPath.section) {
        case HYCartSectionDeliveryMode: {
            HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
            
            if (cell == nil) {
                cell = [[HYBasicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicIdentifier];
            }
            
            if (_cartObj.deliveryMode.count && _cartObj.entries.count > 0) {
                [cell decorateCellLabelWithContents:[NSArray arrayWithObjects:
                                                                     [_cartObj.deliveryMode objectForKey:@"name"],
                                                                     [_cartObj.deliveryMode objectForKey:@"description"],
                                                                     [[_cartObj.deliveryMode objectForKey:@"deliveryCost"] objectForKey:@"formattedValue"],
                                                                     nil]];
                [cell sizeToFit];
            } else if (_cartObj.entries.count == 0) {
                [cell decorateCellLabelWithContents:[NSArray arrayWithObjects: @"", nil]];
                [cell sizeToFit];            
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            finalCell = cell;
        }
            break;
        case HYCartSectionProducts: {
            HYCartCell *cell = [tableView dequeueReusableCellWithIdentifier:cartIdentifier];
            
            if (cell == nil) {
                cell = [[HYCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cartIdentifier];
            }
            
            [Cart decorateCell:cell withObject:_cartObj forCartEntry:indexPath.row];
            cell.changeQuantityButton.tag = indexPath.row;
            [cell.changeQuantityButton addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.readonly) {
                cell.changeQuantityButton.hidden = YES;
            }
            [cell sizeToFit];
            
            CGFloat width = cell.productTitleLabel.frame.size.width;
            [cell.productTitleLabel sizeToFit];
            CGRectSetWidth(cell.productTitleLabel.frame, width);
            
            finalCell = cell;
            
            break;
        }
        case HYCartSectionPotentialPromotions:
        case HYCartSectionAppliedPromotions: {
            HYProductPromotionCell *cell = [tableView dequeueReusableCellWithIdentifier:promotionCellIdentifier];
            
            if (cell == nil) {
                cell = [[HYProductPromotionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:promotionCellIdentifier];
            }
            
            cell.promotionView.textColor = UIColor_brandTextColor;
            cell.promotionView.textAlignment = NSTextAlignmentLeft;
            
            NSArray *promotionsArray = nil;
            
            if (self.cartObj.potentialProductPromotions) {
                promotionsArray = self.cartObj.potentialProductPromotions;
            } else if (self.cartObj.appliedProductPromotions) {
                promotionsArray = self.cartObj.appliedProductPromotions;
            }
            
            if (promotionsArray && promotionsArray.count) {                
                [HYProduct decoratePromotionsView:cell.promotionView forPromotionArray:[NSArray arrayWithObject:[promotionsArray objectAtIndex:indexPath.row]]];
                             
                CGSize stringSize = [cell.promotionView.text sizeWithFont:cell.promotionView.font
                                                        constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH - (STANDARD_MARGIN * 4), CONSTRAINED_HEIGHT)
                                                            lineBreakMode:NSLineBreakByWordWrapping];
                
                CGRectSetHeight(cell.frame, stringSize.height + STANDARD_MARGIN * 2.0);
                
                [cell.promotionView setFrame:CGRectMake(STANDARD_MARGIN * 2,
                                                        STANDARD_MARGIN,
                                                        CONSTRAINED_WIDTH,
                                                        stringSize.height + STANDARD_MARGIN * 2.0)];
                
                cell.promotionView.textInsets = UIEdgeInsetsMake(0.0, STANDARD_MARGIN * 2, 0.0, STANDARD_MARGIN * 2); //CONSTRAINED_HEIGHT
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            finalCell = cell;
            break;
        }
        default: {
        }
            break;
    }
    
    return finalCell;
}



#pragma Tableview Edit functions

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == HYCartSectionProducts ? YES : NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove row from data source
        if (self.cartObj.entries.count >= indexPath.row) {
            [[HYWebService shared] deleteProductInCartAtEntry:indexPath.row completionBlock:^(NSDictionary *dictionary, NSError *error) {
                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    NSMutableArray *editedArray = [NSMutableArray arrayWithArray:self.cartObj.entries];
                    [editedArray removeObjectAtIndex:indexPath.row];
                    self.cartObj.entries = [NSArray arrayWithArray:editedArray];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self loadCartDetails];
                    [self.tableView reloadData];
                    
                    [[HYWebService shared] deleteCartDeliveryModesWithCompletionBlock:^(NSDictionary *dictionary, NSError *error) {
                        if (error) {
                            [[HYAppDelegate sharedDelegate] alertWithError:error];
                        }
                        else {
                            [self loadCartDetails];
                            [self.tableView reloadData];
                        }
                    }];
                }
            }];
        }
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTotalUnitCountLabel:nil];
    [self setTotalPriceLabel:nil];
    [super viewDidUnload];
}



#pragma mark - Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCheckoutSegue"]) {
        HYCheckoutViewController *vc = (HYCheckoutViewController *)((UINavigationController *)segue.destinationViewController).visibleViewController;
        vc.delegate = self;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}



#pragma mark - ModalViewControllerDelegate

- (void)requestDismissAnimated:(BOOL)animated sender:(id)sender {
    [self dismissModalViewControllerAnimated:animated];
}


- (void)modalViewDismissedWithInfo:(NSDictionary *)info animated:(BOOL)animated sender:(id)sender {
    [self waitViewShow:YES];
    [self dismissViewControllerAnimated:animated completion:^{
        HYOrderDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HYOrderDetailViewController"];
        HYNavigationViewController *nController = [[HYNavigationViewController alloc] initWithRootViewController:vc];
        vc.orderDetails = [NSDictionary dictionaryWithDictionary:info];
        vc.delegate = self;
        vc.navigationItem.rightBarButtonItem = UIBarButtonDone (@selector(requestDismissAnimated:sender:));
        [self presentModalViewController:nController animated:YES];
        [self waitViewShow:NO];
    }];
}



#pragma mark - private methods

- (CGFloat)heightForCellForPromotionsAtIndexPath:(NSIndexPath *)indexPath {
    TTTAttributedLabel *promotionView = [[TTTAttributedLabel alloc] init];
    promotionView.font = UIFont_promotionFont;

    if (self.cartObj.potentialProductPromotions && ((NSArray *)self.cartObj.potentialProductPromotions).count) {
        [HYProduct decoratePromotionsView:promotionView forPromotionArray:[NSArray arrayWithObject:[self.cartObj.potentialProductPromotions
                                                                                                    objectAtIndex:indexPath.row]]];

        if ([promotionView.text isEmpty]) {
            return 0.0;
        }

        // Resize
        CGSize stringSize = [promotionView.text sizeWithFont:promotionView.font
                                           constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH - (STANDARD_MARGIN * 4), CONSTRAINED_HEIGHT)
                                               lineBreakMode:NSLineBreakByWordWrapping];
        return stringSize.height + STANDARD_MARGIN + STANDARD_MARGIN;
    }

    return 0.0;
}


@end
