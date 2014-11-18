//
// HYArrayViewController.m
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

#import "HYArrayViewController.h"
#import "HYBasicCell.h"

@interface HYArrayViewController ()

@end

@implementation HYArrayViewController

- (void)itemWasSelected {
}


- (void)setDetails:(NSArray *)details {
    _details = details;
    [self.tableView reloadData];
    [self waitViewShow:NO];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.canSelect = YES;
    self.selectedItem = -1;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.details.count;
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Basic Cell";
    HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[HYBasicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if ([self.classType isEqualToString:NSStringFromClass([NSDictionary class])]) {
        cell.label.text = [[self.details objectAtIndex:indexPath.row] objectForKey:self.key];
    }
    // Assume NSString
    else {
        cell.label.text = [self.details objectAtIndex:indexPath.row];
    }

    if (self.canSelect && indexPath.row == self.selectedItem) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.canSelect) {
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedItem = indexPath.row;

        [self itemWasSelected];
    }
}


@end
