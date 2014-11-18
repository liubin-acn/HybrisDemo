//
// HYTableViewController.m
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


#import "HYTableViewController.h"


@interface HYTableViewController ()

/**
 *  Perform any additional setup for the view controller, after being created
 *  programatically or from a nib/storyboard.
 */
- (void)setup;

@end



@implementation HYTableViewController

@synthesize tableView = _tableView;


#pragma mark - Custom Methods

- (void)setup {
    [super setup];

    for (id view in self.view.subviews) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 && [view respondsToSelector:@selector(setTintColor:)]) {
            [view setTintColor:UIColor_standardTint];
        }
    }
}



#pragma mark - Custom Getters and Setters

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;

    if (!titleView) {
        titleView = [[ViewFactory shared] make:[HYLabel class]];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.font = UIFont_navigationBarFont;
        titleView.textColor = UIColor_inverseTextColor;
        self.navigationItem.titleView = titleView;
    }

    titleView.text = title;
    [titleView sizeToFit];
}



#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Make sure the cell is on the screen for the fading out effect
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
    
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView.backgroundColor = UIColor_tableBackgroundColor;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Add the fading out cell effect that you get with UITableViewController
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
