//
// HYPaymentListViewController.m
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

#import "HYPaymentListViewController.h"
#import "HYPaymentDetailViewController.h"
#import "HYBasicCell.h"

#define ADD_CELL_TEXT NSLocalizedString(@"Add new payment", nil)


@interface HYPaymentListViewController ()

@property (nonatomic, strong) NSArray *paymentMethods;
@property (nonatomic, strong) NSString *selectedPaymentID;
@property (nonatomic, strong) NSArray *sectionIdentifiers;

- (void)updateEditButton;

@end


@implementation HYPaymentListViewController

static NSString *basicIdentifier = @"Hybris Basic Cell";
static NSString *paymentInfosSectionIdentifier = @"PaymentInfosSection";
static NSString *addPaymentSectionIdentifier = @"AddPaymentSection";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Payment Details", "Title for the view that shows the users payment details.");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];

    if (self.canSelectPayment) {
        self.sectionIdentifiers = [NSArray arrayWithObjects:addPaymentSectionIdentifier, paymentInfosSectionIdentifier, nil];
    }
    else {
        self.sectionIdentifiers = [NSArray arrayWithObjects:paymentInfosSectionIdentifier, nil];
    }

    [self showPaymentMethods];

    if (self.editing) {
        self.editing = NO;
    }
}


- (void)showPaymentMethods {
    if (self.canSelectPayment) {
        [self waitViewShow:YES];
        
        [[HYWebService shared] cartWithCompletionBlock:^(NSArray *array, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    if (array.count) {
                        Cart *cart = [array objectAtIndex:0];
                        self.selectedPaymentID = [cart.paymentInfo objectForKey:@"id"];
                        [self waitViewShow:YES];
                        
                        [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {
                                [self waitViewShow:NO];

                                if (error) {
                                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                                }
                                else {
                                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array]; //do i have to do this?

                                    for (NSDictionary *dict in tempArray) {
                                        if ([[dict objectForKey:@"id"] isEqual:_selectedPaymentID]) {
                                            id obj = dict;
                                            [tempArray removeObject:dict];
                                            [tempArray insertObject:obj atIndex:0];
                                            break;
                                        }
                                    }

                                    self.paymentMethods = [[NSArray alloc] initWithArray:tempArray];
                                    [self.tableView reloadData];
                                    [self updateEditButton];
                                }
                            }];
                    }
                }
            }];
    }
    else {
        [self waitViewShow:YES];
        
        [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    self.paymentMethods = [NSArray arrayWithArray:array];
                    [self.tableView reloadData];
                    [self updateEditButton];
                }
            }];
    }
}


- (NSArray *)paymentInfoForRow:(NSInteger)rowIndex {
    NSDictionary *singlePayment = [_paymentMethods objectAtIndex:rowIndex];

    return [NSArray arrayWithObjects:[singlePayment valueForKeyPath:@"accountHolderName"],
        [singlePayment valueForKeyPath:@"cardNumber"],
        [singlePayment valueForKeyPath:@"cardType.name"],
        nil];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIdentifiers.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.sectionIdentifiers objectAtIndex:section] isEqualToString:paymentInfosSectionIdentifier]) {
        return self.paymentMethods.count;
    }
    else if ([[self.sectionIdentifiers objectAtIndex:section] isEqualToString:addPaymentSectionIdentifier]) {
        return 1;
    }
    else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:paymentInfosSectionIdentifier]) {
        return [HYBasicCell heightForCellWithContents:[self paymentInfoForRow:indexPath.row]];
    }
    else if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:addPaymentSectionIdentifier]) {
        return [HYBasicCell heightForCellWithContents:ADD_CELL_TEXT];
    }
    else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:paymentInfosSectionIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.label.textAlignment = NSTextAlignmentLeft;

        if (_paymentMethods.count >= indexPath.row) {
            NSDictionary *singlePayment = [_paymentMethods objectAtIndex:indexPath.row];

            if (self.canSelectPayment) {
                if (self.selectedPaymentID && [[singlePayment objectForKey:@"id"] isEqualToString:_selectedPaymentID]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else {
                if ([[singlePayment objectForKey:@"defaultPaymentInfo"] boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }

                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            [cell decorateCellLabelWithContents:[self paymentInfoForRow:indexPath.row]];
        }
    }
    else if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:addPaymentSectionIdentifier]) {
        [cell decorateCellLabelWithContents:ADD_CELL_TEXT];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
    }

    return cell;
}



#pragma mark - Table view delegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:addPaymentSectionIdentifier]) {
        return NO;
    }
    else {
        return YES;
    }
}


- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path {
    switch (path.section) {
        case 0: {
            return path;
        }
        break;
        case 1: {
            return path;
        }
        default: {
            return nil;
        }
        break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:paymentInfosSectionIdentifier]) {
        if (_paymentMethods.count >= indexPath.row) {
            NSDictionary *singlePayment = [_paymentMethods objectAtIndex:indexPath.row];

            if (self.canSelectPayment) {
                self.selectedPaymentID = [singlePayment objectForKey:@"id"];
                [self waitViewShow:YES];
                
                // set cart payment
                [[HYWebService shared] setCartPaymentInfoWithID:_selectedPaymentID completionBlock:^(NSDictionary *dictionary, NSError *error) {
                        [self waitViewShow:NO];

                        if (error) {
                            [[HYAppDelegate sharedDelegate] alertWithError:error];
                        }
                        else {
                            for (NSIndexPath *path in self.tableView.indexPathsForVisibleRows) {
                                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
                                cell.accessoryType = UITableViewCellAccessoryNone;
                            }

                            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                            [self performBlock:^{
                                    [self.navigationController popViewControllerAnimated:YES];
                                } afterDelay:POP_VIEW_CONTROLLER_DELAY];
                        }
                    }];
            }
            // push editing view
            else {
                HYPaymentDetailViewController *vc = [[HYPaymentDetailViewController alloc] initWithTitle:NSLocalizedString(@"Edit Payment Details", "Title for the view that lets the user edit payment details.") values:singlePayment];
                [self setShowPlainBackButton:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else if ([[self.sectionIdentifiers objectAtIndex:indexPath.section] isEqualToString:addPaymentSectionIdentifier]) {
        HYPaymentDetailViewController *vc = [[HYPaymentDetailViewController alloc] initWithTitle:NSLocalizedString(@"Payment Details", "Title for the view that shows the users payment details.")];
        [self setShowPlainBackButton:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove row from data source
        if (self.paymentMethods.count >= indexPath.row) {
            NSString *paymentID = [[self.paymentMethods objectAtIndex:indexPath.row] objectForKey:@"id"];
            [[HYWebService shared] deleteCustomerPaymentInfoWithID:paymentID completionBlock:^(NSError *error) {
                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }
                    else {
                        NSMutableArray *editedArray = [NSMutableArray arrayWithArray:self.paymentMethods];
                        [editedArray removeObjectAtIndex:indexPath.row];
                        self.paymentMethods = [NSArray arrayWithArray:editedArray];
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }];
        }
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self updateEditButton];
}



#pragma mark - private methods

- (void)updateEditButton {
    if (self.paymentMethods.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}


@end
