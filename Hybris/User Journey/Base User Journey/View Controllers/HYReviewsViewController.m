//
// HYReviewsViewController.m
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

#import "HYReviewsViewController.h"
#import "HYReviewCell.h"

@interface HYReviewsViewController ()

@end

@implementation HYReviewsViewController

- (void)setReviews:(NSArray *)reviews {
    _reviews = reviews;
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.reviews = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviews.count;
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[HYReviewCell class] cellIdentifier]];

    return [cell heightForReview:[self.reviews objectAtIndex:indexPath.row]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[HYReviewCell class] cellIdentifier]];

    [cell decorateCellWithReview:[self.reviews objectAtIndex:indexPath.row]];

    return cell;
}


@end
