//
// HYAddressListViewController.m
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

#import "HYAddressListViewController.h"
#import "HYAddressDetailViewController.h"
#import "HYBasicCell.h"


@interface HYAddressListViewController ()

@property (nonatomic, strong) NSArray *addresses;
@property (nonatomic, strong) NSString *selectedAddressID;

- (void)updateEditButton;

@end


@implementation HYAddressListViewController

static NSString *basicIdentifier = @"Hybris Basic Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Address Book", "Title for the view that shows the users address book.");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self showDeliveryAddresses];

    if (self.editing) {
        self.editing = NO;
    }
    
    [self updateEditButton];
}


- (void)showDeliveryAddresses {
    if (self.canSelectAddress) {
        [self waitViewShow:YES];
        
        [[HYWebService shared] cartWithCompletionBlock:^(NSArray *array, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    if (array.count) {
                        Cart *cart = [array objectAtIndex:0];
                        self.selectedAddressID = [cart.deliveryAddress objectForKey:@"id"];
                        [self waitViewShow:YES];
                        [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
                                [self waitViewShow:NO];

                                if (error) {
                                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                                }
                                else {
                                    logDebug (@"%@", array);

                                    // brings the selected address to top of stack
                                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];

                                    for (NSDictionary *dict in tempArray) {
                                        if ([[dict objectForKey:@"id"] isEqual:_selectedAddressID]) {
                                            id obj = dict;
                                            [tempArray removeObject:dict];
                                            [tempArray insertObject:obj atIndex:0];
                                            break;
                                        }
                                    }

                                    self.addresses = [NSArray arrayWithArray:tempArray];
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
        
        [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    self.addresses = [NSArray arrayWithArray:array];
                    [self.tableView reloadData];
                    [self updateEditButton];
                }
            }];
    }
}


- (NSArray *)addressesInfoForRow:(NSInteger)rowIndex {
    NSDictionary *singleAddress = [_addresses objectAtIndex:rowIndex];
    NSMutableArray *addressArray = [[NSMutableArray alloc] init];

    [addressArray addObject:[NSArray arrayWithObjects:[singleAddress objectForKey:@"title"], [singleAddress objectForKey:@"firstName"],
            [singleAddress objectForKey:@"lastName"], nil]];

    if ([singleAddress objectForKey:@"line1"]) {
        [addressArray addObject:[singleAddress objectForKey:@"line1"]];
    }

    if ([singleAddress objectForKey:@"line2"]) {
        [addressArray addObject:[singleAddress objectForKey:@"line2"]];
    }

    if ([singleAddress objectForKey:@"town"]) {
        [addressArray addObject:[singleAddress objectForKey:@"town"]];
    }

    if ([singleAddress objectForKey:@"postalCode"]) {
        [addressArray addObject:[singleAddress objectForKey:@"postalCode"]];
    }

    if ([singleAddress valueForKeyPath:@"country.name"]) {
        [addressArray addObject:[singleAddress valueForKeyPath:@"country.name"]];
    }
    else {
        logError(@"Required JSON data missing");
    }

    return addressArray;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return 1;
        }
        case 1: {
            return self.addresses.count;
        }
        default: {
            return 0;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return [HYBasicCell heightForCellWithContents:NSLocalizedString(@"Add new address", @"Title of the button that lets the user enter a new address and also the views title.")];
        }
        case 1: {
            return [HYBasicCell heightForCellWithContents:[self addressesInfoForRow:indexPath.row]];
        }
        default: {
            return 0;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    switch (indexPath.section) {
        case 0:
        {
            [cell decorateCellLabelWithContents:NSLocalizedString(@"Add new address", @"Title of the button that lets the user enter a new address and also the views title.")];
//            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView =
                [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
            break;
        }
        case 1:
        {
            cell.label.textAlignment = NSTextAlignmentLeft;

            if (_addresses.count >= indexPath.row) {
                NSDictionary *singleAddress = [_addresses objectAtIndex:indexPath.row];

                if (self.canSelectAddress) {
                    if (self.selectedAddressID && [[singleAddress objectForKey:@"id"] isEqualToString:_selectedAddressID]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }

                [cell decorateCellLabelWithContents:[self addressesInfoForRow:indexPath.row]];
            }
            cell.accessoryView = nil;
            break;
        }
        default: {
        }
        break;
    }

    return cell;
}



#pragma mark - Table view delegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
        case 1: {
            return path;
        }
        default: {
            return nil;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
        {
            if (self.tableView.isEditing) {
                [self setEditing:NO animated:NO];
            }

            HYAddressDetailViewController *vc = [[HYAddressDetailViewController alloc] initWithTitle:NSLocalizedString(@"Add New Address", @"Title of the view that lets the user enter a new address.")];
            [self setShowPlainBackButton:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case 1:
        {
            if (_addresses.count >= indexPath.row) {
                NSDictionary *singleAddress = [_addresses objectAtIndex:indexPath.row];

                if (self.canSelectAddress) {
                    self.selectedAddressID = [singleAddress objectForKey:@"id"];
                    [self waitViewShow:YES];
                    [[HYWebService shared] setCartDeliveryAddressWithID:_selectedAddressID completionBlock:^(NSDictionary *dictionary, NSError *error) {
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
                else {
                    HYAddressDetailViewController *vc = [[HYAddressDetailViewController alloc] initWithTitle:NSLocalizedString(@"Edit Address", @"Title for the view that lets the user edit a address.") values:singleAddress];
                    [self setShowPlainBackButton:YES];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
        default: {
        }
        break;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove row from data source
        if (self.addresses.count >= indexPath.row) {
            NSString *addressID = [[self.addresses objectAtIndex:indexPath.row] objectForKey:@"id"];
            [[HYWebService shared] deleteCustomerAddressWithID:addressID completionBlock:^(NSError *error) {
                    if (error) {
                        [[HYAppDelegate sharedDelegate] alertWithError:error];
                    }
                    else {
                        NSMutableArray *editedArray = [NSMutableArray arrayWithArray:self.addresses];
                        [editedArray removeObjectAtIndex:indexPath.row];
                        self.addresses = [NSArray arrayWithArray:editedArray];
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
    if (self.addresses.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

@end
