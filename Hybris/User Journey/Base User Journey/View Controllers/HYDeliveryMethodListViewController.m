//
// HYDeliveryMethodListViewController.m
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

#import "HYDeliveryMethodListViewController.h"
#import "HYBasicCell.h"


@interface HYDeliveryMethodListViewController ()

@property (nonatomic, strong) NSArray *deliveryMethods;
@property (nonatomic, strong) NSString *deliveryCode;

@end


@implementation HYDeliveryMethodListViewController

@synthesize tableView = _tableView;
@synthesize deliveryMethods = _deliveryMethods;
@synthesize deliveryCode = _deliveryCode;

static NSString *basicIdentifier = @"Hybris Basic Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Delivery Method", nil);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showDeliveryMethods];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}


- (void)showDeliveryMethods {
    [self waitViewShow:YES];
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                if (array.count) {
                    Cart *cart = [array objectAtIndex:0];
                    self.deliveryCode = [cart.deliveryMode objectForKey:@"code"];
                    [[HYWebService shared] cartDeliveryModesWithCompletionBlock:^(NSArray *array, NSError *error) {
                            if (error) {
                                [[HYAppDelegate sharedDelegate] alertWithError:error];
                            }
                            else {
                                logDebug (@"%@", array);
                                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];

                                for (NSDictionary *dict in tempArray) {
                                    if ([[dict objectForKey:@"code"] isEqual:_deliveryCode]) {
                                        id obj = dict;
                                        [tempArray removeObject:dict];
                                        [tempArray insertObject:obj atIndex:0];
                                        break;
                                    }
                                }

                                _deliveryMethods = [[NSArray alloc] initWithArray:tempArray];
                                [self.tableView reloadData];
                            }

                            [self waitViewShow:NO];
                        }];
                }
            }
        }];
}
- (NSArray *)deliveryModeForRow:(NSInteger)rowIndex {
    NSDictionary *singleDeliveryMode = [_deliveryMethods objectAtIndex:rowIndex];

    return [NSArray arrayWithObjects:
        [singleDeliveryMode objectForKey:@"name"],
        [singleDeliveryMode objectForKey:@"description"],
        [[singleDeliveryMode objectForKey:@"deliveryCost"] objectForKey:@"formattedValue"],
        nil];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deliveryMethods.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HYBasicCell heightForCellWithContents:[self deliveryModeForRow:indexPath.row]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];

    cell.accessoryType = UITableViewCellAccessoryNone;

    if (_deliveryMethods.count >= indexPath.row) {
        [cell decorateCellLabelWithContents:[self deliveryModeForRow:indexPath.row]];

        if (self.deliveryCode && [[[_deliveryMethods objectAtIndex:indexPath.row] objectForKey:@"code"] isEqualToString:_deliveryCode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}


#pragma mark - Table view delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_deliveryMethods.count >= indexPath.row) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *singleDeliveryMode = [_deliveryMethods objectAtIndex:indexPath.row];

        [self waitViewShow:YES];
        [[HYWebService shared] setCartDeliveryModeWithCode:[singleDeliveryMode objectForKey:@"code"] completionBlock:^(NSDictionary *dictionary, NSError *
                error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    logDebug (@"%@", dictionary);

                    for (NSIndexPath *path in self.tableView.indexPathsForVisibleRows) {
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }

                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [self performBlock:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        } afterDelay:0.5];
                }
            }];
    }
}

@end
