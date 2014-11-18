//
// HYOrderListViewController.m
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

#import "HYOrderListViewController.h"

#import "HYOrderDetailViewController.h"
#import "HYOrderListCell.h"
#import "HYFooterView.h"

#define kPageSize @"20"


@interface HYOrderListViewController ()

@property (nonatomic, strong) NSArray *orders;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic, strong) HYFooterView *footerView;

@end


@implementation HYOrderListViewController

@synthesize orders = _orders;
@synthesize currentPage = _currentPage;
@synthesize totalPage = _totalPage;
@synthesize footerView = _footerView;


- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = 0;
    self.totalPage = 1;
    _footerView = [[ViewFactory shared] make:[HYFooterView class] withFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)];

    [self showOrderDetails];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = NSLocalizedString(@"Order History", "Title for the view that shows the order history.");
}


- (void)showOrderDetails {
    if (self.currentPage < self.totalPage) {
        [self waitViewShow:YES];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"CHECKED_VALID", @"statuses"
            , [NSNumber numberWithInteger:self.currentPage], @"currentPage"                                         //current page is Zero
            , kPageSize, @"pageSize"
            , nil];
        [[HYWebService shared] ordersWithOptions:options completionBlock:^(NSDictionary *dictionary, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    logDebug (@"%@", dictionary);
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.orders];
                    [mutableArray addObjectsFromArray:[dictionary objectForKey:@"orders"]];
                    self.orders = [NSArray arrayWithArray:mutableArray];
                    self.totalPage = [[[dictionary objectForKey:@"pagination"] objectForKey:@"totalPages"] integerValue];
                    [self refreshViews];
                    [self.tableView reloadData];
                }
            }];
    }
}


- (void)refreshViews {
    // Footer
    NSString *labelString;

    labelString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"Showing n of m results", nil, [NSBundle mainBundle],
                                                                 @"Showing %1$i of %2$i results",
                                                                 @"On-going count of results"), self.orders.count, self.orders.count];
    self.footerView.label.text = labelString;
    [self.tableView setTableFooterView:self.footerView];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orders.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *orderListCellIdentifier = @"OrderListCell";    
    HYOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:orderListCellIdentifier];
    
    if (cell == nil) {
        cell = [[HYOrderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderListCellIdentifier];
    }
    
    if (_orders.count >= indexPath.row) {
        NSDictionary *singleOrder = [_orders objectAtIndex:indexPath.row];
        NSDate *orderDate = [NSDate dateFromISO8601String:[singleOrder objectForKey:@"placed"]];
        
        cell.orderNumber = [singleOrder objectForKey:@"code"];
        cell.orderDate = [orderDate dateAsString];
        cell.orderStatus = [singleOrder objectForKey:@"statusDisplay"];
        [cell decorateCellLabels];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];

    return cell;
}



#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Show Order Detail Segue" sender:self];
}



#pragma mark - Tableview scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
        if (([scrollView contentOffset].y + scrollView.frame.size.height) == [scrollView contentSize].height) {
            self.currentPage = self.currentPage + 1;
            [self showOrderDetails];
        }
    }
}



#pragma mark - Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Order Detail Segue"]) {
        HYOrderDetailViewController *vc = (HYOrderDetailViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        [self setShowPlainBackButton:YES];
        vc.orderDetailID = [[self.orders objectAtIndex:selectedIndexPath.row] objectForKey:@"code"];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}


@end
