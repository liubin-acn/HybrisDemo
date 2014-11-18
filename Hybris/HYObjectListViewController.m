//
// HYObjectListViewController.m
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

#import "HYObjectListViewController.h"
#import "HYUserInformation.h"
#import "HYCategoryManager.h"
#import "HYFilterViewController.h"
#import "HYProductDetailViewController.h"
#import "HYProductCell.h"

@interface HYObjectListViewController ()

@property (nonatomic, strong) NSMutableArray *legacyFacets;
@property (nonatomic, strong) HYQuery *query;

/// List of sort method
@property (nonatomic, strong) NSArray *sortArray;

/// Array of arrays of strings for search table
@property (nonatomic, strong) NSMutableOrderedSet *searchTableData;

/// Flag set to true if a fetch request is executing
@property (nonatomic) BOOL isRequestingMoreItems;

/// Timer for search
@property (nonatomic, strong) NSTimer *delayTimer;

@property (nonatomic) BOOL searchBarShown;

@property (nonatomic, strong) UIActivityIndicatorView *loadingProductsActivityIndicator;

/// Set to yes once the view has received a response
@property (nonatomic) BOOL hasData;

- (void)updateAndShowSearchTable;

- (void)fetchData;

- (HYObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

/// Helper to tell us if we are the root view controller (i.e. the "home page")
- (BOOL)rootViewController;

@end

@implementation HYObjectListViewController

- (BOOL)rootViewController {
    return self == [self.navigationController.viewControllers objectAtIndex:0];
}


- (void)setQuery:(HYQuery *)query {
    if (![_query isEqual:query]) {
        _query = query;
        
        // Fetch
        [self fetchData];
    }

    self.title = query.name;
}


- (void)fetchData {
    if (self.hasData) {
        return;
    }
    
    if (self.query == nil) {
        self.query = [HYQuery query];
        self.query.queryString = @"";
    }

    self.filterButton.enabled = NO;
    [[HYWebService shared] products:self.query completionBlock:^(NSDictionary *results, NSError *error) {
        
            NSMutableArray *categories = [NSMutableArray array];
            NSMutableArray *products = [NSMutableArray array];
            NSMutableArray *didYouMean = [NSMutableArray array];
        
            // Categories
            if (self.rootViewController) {
                HYCategory *rootCategory = [HYCategoryManager rootCategory];
                
                for (id item in rootCategory.childCategories) {
                    if ([item isKindOfClass:[HYCategory class]]) {
                        [categories addObject:item];
                    }
                }
            }
        
            if (error) {
                [self.loadingProductsActivityIndicator stopAnimating];
                
                // Offline?
                if (error.code == -1009) {
                    self.footerView.label.text = NSLocalizedStringWithDefaultValue(@"Offline", nil, [NSBundle mainBundle], @"Offline", @"Offline message");
                    self.tableView.scrollEnabled = NO;
                }
                else {
                    self.footerView.label.text = @"";
                }
            }
            else {
                self.tableView.scrollEnabled = YES;
                self.hasData = YES;
                [self.loadingProductsActivityIndicator stopAnimating];
                NSArray *items = [NSArray arrayWithArray:self.query.items];
                for (id item in items) {
                    if ([item isKindOfClass:[HYCategory class]]) {
                        [categories addObject:item];
                    }
                    else if ([item isKindOfClass:[HYProduct class]]) {
                        [products addObject:item];
                    }
                    else if ([item isKindOfClass:[HYDidYouMean class]]) {
                        [didYouMean addObject:item];
                    }
                }

                // If this is the first vc, add the categories
                if (self.rootViewController) {
//                    HYCategory *rootCategory = [HYCategoryManager rootCategory];
//
//                    for (id item in rootCategory.childCategories) {
//                        if ([item isKindOfClass:[HYCategory class]]) {
//                            [categories addObject:item];
//                        }
//                    }

                    if (!PRODUCTS_IN_SHOP_FRONT) {
                        [products removeAllObjects];
                        self.footerView.hidden = YES;
                    }
                }

                if (categories.count && !PRODUCTS_IN_CATEGORY_VIEW) {
                    [products removeAllObjects];
                    self.footerView.hidden = YES;
                }

                // Sort the products
                NSArray *sortedProducts;
                sortedProducts = [products sortedArrayUsingComparator:^NSComparisonResult (id a, id b) {
                        return ((HYProduct *)a).sortRank > ((HYProduct *)b).sortRank;
                    }];

                self.allObjects = [NSArray arrayWithObjects:didYouMean, categories, [sortedProducts mutableCopy], nil];

                // The header that shows the number of products (not shown on root vc)
                if (self.searchHeaderView == nil && !self.rootViewController) {
                    self.searchHeaderView =
                        [[ViewFactory shared] make:[HYSearchResultsHeaderView class] withFrame:CGRectMake (0, 0, self.tableView.frame.size.width,
                            HEADER_HEIGHT)];
                }

                [self.tableView reloadData];
                [self refreshViews];
            }
        }];
}

#pragma mark - Helper Methods

- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"object"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)addObservers {
    [self addObserver:self forKeyPath:@"object" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteChanged:) name:HYSiteChangedNotification object:nil];
}

- (void)reachabilityChanged:(Reachability *)reachability {
    [super reachabilityChanged:reachability];
    
    if([reachability isReachable]) {
        [self fetchData];
    }
    else {
    }
}

- (HYObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return (HYObject *)[[self.allObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}



#pragma mark - View Lifecyle

- (void)awakeFromNib {
    // Refine button
    self.navigationItem.rightBarButtonItem.title = NSLocalizedStringWithDefaultValue(@"Refine", nil, [NSBundle mainBundle], @"Refine", @"Refine button");
    if (self.rootViewController) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    // Show or Hide Products
    self.entityName = @"HYItem";
    if (self.rootViewController) {
        if (!PRODUCTS_IN_SHOP_FRONT) {
            self.entityName = @"HYCategory";
            self.footerView.hidden = YES;
        }
    }
    else if (!PRODUCTS_IN_CATEGORY_VIEW) {
        self.entityName = @"HYCategory";
        self.footerView.hidden = YES;
    }

    self.sortDescriptors = [NSArray arrayWithObjects:
        [NSSortDescriptor sortDescriptorWithKey:@"internalClass" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
        nil];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    self.searchBar.placeholder = NSLocalizedStringWithDefaultValue(@"Search", nil, [NSBundle mainBundle], @"Search", @"Search placeholder text");
    self.searchBar.delegate = self;
    self.searchBarShown = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the search table data
    self.searchTableData = [[NSMutableOrderedSet alloc] initWithArray:[HYUserInformation previousSearches]];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    [self.searchTableView reloadData];

    // Footer
    self.footerView = [[ViewFactory shared] make:[HYFooterView class] withFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)];
    self.loadingProductsActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(280.0, 3.0, 35.0, 35.0)];
    self.loadingProductsActivityIndicator.hidesWhenStopped = YES;
    [self.footerView addSubview:self.loadingProductsActivityIndicator];
    [self.tableView setTableFooterView:self.footerView];

    // Plain back button
    [self setShowPlainBackButton:YES];
    
    self.isRequestingMoreItems = NO;
    self.tableView.scrollsToTop = YES;
    
    // Fetch
    [self fetchData];
}


- (void)viewDidUnload {
    self.loadingProductsActivityIndicator = nil;
    self.footerView = nil;
    self.tableView = nil;
    self.searchBar = nil;
    self.blockerView = nil;
    self.searchTableView = nil;
    self.searchHeaderView = nil;
    self.filterButton = nil;

    [self removeObservers];
    
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)refreshViews {
    [self.loadingProductsActivityIndicator startAnimating];

    NSString *labelString;
    if ([self.query.totalResults intValue] <= [self.query.pageSize intValue] ||
        ([self.query.currentPage intValue] + 1) * [self.query.pageSize intValue] > [self.query.totalResults intValue] ||
        [self.query.totalResults intValue] == ([self.query.currentPage intValue] + 1) * [self.query.pageSize intValue]) {
        if ([self.query.totalResults intValue] == 0) {
            if ([HYWebService shared].progress == 1.0) {
                // No results, so replace footer
                if ([self.tableView.tableFooterView isEqual:self.footerView]) {
                    labelString =
                    [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"No results", nil, [NSBundle mainBundle], @"No results", @"No results message")];
                    [self.loadingProductsActivityIndicator stopAnimating];
                    [self.tableView setTableFooterView:self.footerView];
                }
            }
            else {
                labelString =
                    [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"Loading", nil, [NSBundle mainBundle], @"Loading", @"Loading message")];
                [self.tableView setTableFooterView:self.footerView];
            }
        }
        else {
            if ([self.query.totalResults intValue] == 1) {
                labelString =
                    [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"n product", nil, [NSBundle mainBundle], @"%1$i product",
                        @"Completed count of product (singular)"),
                    [self.query.totalResults intValue]];
            }
            else {
                labelString =
                    [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"n total products", nil, [NSBundle mainBundle], @"%1$i total products",
                        @"Completed count of products (plural)"),
                    [self.query.totalResults intValue]];
            }

            [self.tableView setTableFooterView:self.footerView];
            [self.loadingProductsActivityIndicator stopAnimating];
        }
    }
    else {
        labelString =
            [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"Showing n of m products", nil, [NSBundle mainBundle],
                @"Showing %1$i out of %2$i products",
                @"On-going count of products"),
            ([self.query.currentPage intValue] + 1) * [self.query.pageSize intValue],
            [self.query.totalResults intValue]];
        [self.tableView setTableFooterView:self.footerView];
    }

    self.footerView.label.text = labelString;

    // Header
    if (self.searchHeaderView) {
        self.searchHeaderView.label.text = labelString;
    }

    self.filterButton.enabled = YES;
}


- (void)suggestiveSearchWithText:(id)sender {
    [[HYWebService shared] suggestionsForQuery:self.searchBar.text completionBlock:^(NSArray *results) {
            if (results) {
                [self.searchTableData addObjectsFromArray:results];
            }

            [self.searchTableView reloadData];
        }];
}

- (void)filterResultsTable {
    [self.searchTableData addObjectsFromArray:[HYUserInformation previousSearches]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", self.searchBar.text];
    NSArray *filteredResults = [[self.searchTableData array] filteredArrayUsingPredicate:predicate];
    self.searchTableData = [NSMutableOrderedSet orderedSetWithArray:filteredResults];
    [self.searchTableView reloadData];
}


- (void)updateAndShowSearchTable {
    if (self.searchTableView.hidden) {
        // update saved searches
        self.searchTableData = [[NSMutableOrderedSet alloc] initWithArray:[HYUserInformation previousSearches]];
        [self.searchTableView reloadData];

        self.searchTableView.hidden = NO;
        
        int topInset = 0;
        topInset = [self respondsToSelector:@selector(topLayoutGuide)] ? self.topLayoutGuide.length : 0;
        self.searchTableView.frame = CGRectMake(0, topInset + self.searchBar.frame.size.height, self.searchTableView.frame.size.width, self.searchTableView.frame.size.height);
    }
}

-(void) dealloc{
    [self.tableView setDelegate:nil];
}

- (void)hideSearchBar {
    self.searchBarShown = NO;
}


#pragma mark - Search pagination method

- (void)furtherItems {
    if (self.rootViewController) {
        return;
    }

    if (self.isRequestingMoreItems) {
        return;
    }

    NSNumber *i = [NSNumber numberWithInt:[self.query.currentPage intValue] + 1];

    if ([i intValue] < [self.query.totalPages intValue]) {
        self.isRequestingMoreItems = YES;

        [[HYWebService shared] fetchFurtherItems:self.query withCompletionBlock:^(NSDictionary *results, NSError *error) {
                self.isRequestingMoreItems = NO;

                // Get the new products
                NSMutableArray *products = [NSMutableArray array];

                for (id item in self.query.items) {
                    if ([item isKindOfClass:[HYProduct class]]) {
                        [products addObject:item];
                    }
                }

                // Sort the new products
                NSArray *sortedProducts;
                sortedProducts = [products sortedArrayUsingComparator:^NSComparisonResult (id a, id b) {
                        return ((HYProduct *)a).sortRank > ((HYProduct *)b).sortRank;
                    }];

                [[self.allObjects objectAtIndex:2] removeAllObjects];
                [[self.allObjects objectAtIndex:2] addObjectsFromArray:sortedProducts];

                [self.tableView reloadData];
                [self refreshViews];
            }];
    }
    else {
        [self refreshViews];
    }
}

#pragma mark - Tableview methods


/*
 * Note that this view has two tables, and so each delegate method must check the tableView parameter
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchTableView) {
        return self.searchTableData.count;
    }
    else {
        return ((NSArray *)[self.allObjects objectAtIndex:section]).count;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchTableView) {
        return 1;
    }
    else {
        return self.allObjects.count;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        self.searchBar.text = [self.searchTableData objectAtIndex:indexPath.row];
        [HYUserInformation addPreviousSearch:self.searchBar.text];
        [self performSelector:@selector(searchBarSearchButtonClicked:)withObject:self.searchBar afterDelay:0];
    }
    else {
        HYObject *object = (HYObject *)[self objectAtIndexPath:indexPath];

        // Did You Mean? pressed
        if ([object isKindOfClass:[HYDidYouMean class]]) {
            // Remove the old footer
            [self.tableView setTableFooterView:nil];
            [self.tableView setTableFooterView:self.footerView];

            // Re-perform the search
            HYDidYouMean *didYouMeanItem = (HYDidYouMean *)object;
            self.query = [HYQuery query];
            self.query.queryString = didYouMeanItem.name;
            self.hasData = NO;
            [self fetchData];
        }
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    id finalCell;
    if (tableView == self.searchTableView) {
        static NSString *cellIdentifier = @"Hybris Search Text Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }

        cell.textLabel.text = [self.searchTableData objectAtIndex:indexPath.row];
        cell.textLabel.font = UIFont_defaultFont;
        // Boldify saved searches
        for (NSString *searchString in[HYUserInformation previousSearches]) {
            if ([searchString caseInsensitiveCompare:cell.textLabel.text] == NSOrderedSame) {
                cell.textLabel.font = UIFont_defaultBoldFont;
                break;
            }
        }


        finalCell = cell;
    }
    else {
        static NSString *didYouMeanCellIdentifier = @"Hybris DidYouMean Cell";
        static NSString *categoryCellIdentifier = @"Hybris Category Cell";
        static NSString *productCellIdentifier = @"Hybris Product Cell";

        HYObject *object = [self objectAtIndexPath:indexPath];

        if ([object isKindOfClass:[HYCategory class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];

            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:categoryCellIdentifier];
            }
        }
        else if ([object isKindOfClass:[HYProduct class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:productCellIdentifier];

            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:productCellIdentifier];
 
            }
            ((HYProductCell *)cell).stockLevelLabel.textColor = [UIColor lightGrayColor];
            ((HYProductCell *)cell).stockLevelLabel.highlightedTextColor = [UIColor lightGrayColor];
            ((HYProductCell *)cell).stockLevelLabel.font = UIFont_smallBoldFont;
            ((HYProductCell *)cell).priceLabel.textColor = UIColor_brandTextColor;
            ((HYProductCell *)cell).priceLabel.highlightedTextColor = UIColor_brandTextColor;

            // Hide the divider line for the last cell
            logDebug(@"%d", ((NSArray *)[self.allObjects objectAtIndex:indexPath.section]).count);
            if (((NSArray *)[self.allObjects objectAtIndex:indexPath.section]).count == indexPath.row + 1) {
                ((HYProductCell *)cell).finalCell = YES;
            }
            else {
                ((HYProductCell *)cell).finalCell = NO;
            }
        }
        else if ([object isKindOfClass:[HYDidYouMean class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:didYouMeanCellIdentifier];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        }
        
        [[object class] decorateCell:cell withObject:object];
        finalCell = cell;
        
        if ([object isKindOfClass:[HYProduct class]]) {
            CGFloat width = ((HYProductCell *)cell).nameLabel.frame.size.width;
            [((HYProductCell *)cell).nameLabel sizeToFit];
            CGRectSetWidth(((HYProductCell *)cell).nameLabel.frame, width);
        }
    }
    return finalCell;
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        return 44.0;
    }
    else {
        HYObject *object = [self objectAtIndexPath:indexPath];

        if ([object isKindOfClass:[HYProduct class]]) {
            return 97.0;
        }
        else if ([object isKindOfClass:[HYCategory class]]) {
            return 44.0;
        }
        else if ([object isKindOfClass:[HYDidYouMean class]]) {
            return 44.0;
        }
        else {
            return 0.0;
        }
    }
}


- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchTableView) {
        return 0.0;
    }
    else {
        if (section == 0) {
            if (self.rootViewController) {
                UIImageView *bannerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"digital-camera-banner.png"]];
                return self.searchBar.frame.size.height + self.searchHeaderView.frame.size.height + bannerImage.frame.size.height;
            }
            else if (self.searchBarShown) {
                return self.searchBar.frame.size.height + self.searchHeaderView.frame.size.height;
            }
            else {
                return self.searchHeaderView.frame.size.height;
            }
        }
        else {
            return 0.0;
        }
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchTableView) {
        return nil;
    }
    else {
        if (section == 0) {
            // Home page, search and banner
            if (self.rootViewController) {
                // Calculate the height based on search bar and search header
                float bannerHeight = (self.searchBar.frame.size.height + self.searchHeaderView.frame.size.height);
                UIImageView *bannerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"digital-camera-banner.png"]];
                bannerImage.frame = CGRectMake(0, bannerHeight, bannerImage.frame.size.width, bannerImage.frame.size.height);
                
                UIView *headerView =
                [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.searchBar.frame.size.height +
                                                         self.searchHeaderView.frame.size.height + bannerImage.frame.size.height)];
                [headerView addSubview:self.searchBar];
                [headerView addSubview:self.searchHeaderView];
                [headerView addSubview:bannerImage];
                CGRectSetY(self.searchHeaderView.frame, self.searchBar.frame.size.height);
                return headerView;
            }
            // Normal page, search and header
            else if (self.searchBarShown ) {
                UIView *headerView =
                [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.searchBar.frame.size.height +
                                                         self.searchHeaderView.frame.size.height)];
                [headerView addSubview:self.searchBar];
                [headerView addSubview:self.searchHeaderView];
                CGRectSetY(self.searchHeaderView.frame, self.searchBar.frame.size.height);
                return headerView;
            }
            // Search results page, just header
            else {
                return self.searchHeaderView;
            }
        }
        else {
            return nil;
        }
    }
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {    
    int topInset = 0;
    topInset = [self respondsToSelector:@selector(topLayoutGuide)] ? self.topLayoutGuide.length : 0;
    
    self.blockerView.frame = CGRectMake(0.0, topInset + self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    self.blockerView.hidden = NO;
    [self.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:YES];
    [self.searchBar setShowsCancelButton:YES animated:YES];

    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSString *queryString = [aSearchBar.text stringByTrimmingWhitespace];

    // Save the search
    [HYUserInformation addPreviousSearch:queryString];

    // Push the results
    HYObjectListViewController *vc = [[UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"HYObjectListViewController"];
    HYQuery *query = [HYQuery query];
    query.queryString = self.searchBar.text;
    vc.query = query;
    [vc hideSearchBar];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.delayTimer) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }

    if (![searchText isEmpty]) {
        [self updateAndShowSearchTable];
        self.delayTimer =
            [NSTimer scheduledTimerWithTimeInterval:SEARCH_SUGGESTION_DELAY target:self selector:@selector(suggestiveSearchWithText:)userInfo:nil repeats:NO];
    }

    [self filterResultsTable];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissSearch];
}


- (void)dismissSearch {
    self.searchTableView.hidden = YES;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.searchBar.text = @"";
    self.searchTableView.hidden = YES;
    [self.searchBar resignFirstResponder];
    self.blockerView.hidden = YES;
}


#pragma mark - Tableview scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
        if (([scrollView contentOffset].y + scrollView.frame.size.height) >= [scrollView contentSize].height - INFINITE_SCROLL_AREA_HEIGHT) {
            [self furtherItems];
        }

        [self.searchBar resignFirstResponder];
    }
}


#pragma mark - Segue method

- (void)segue:(id)sender {
    [self performSegueWithIdentifier:@"showFacetsSegue" sender:sender];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"categorySegue"]) {
        HYObjectListViewController *vc = (HYObjectListViewController *)segue.destinationViewController;
        HYQuery *query = [HYQuery query];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        HYCategory *category = (HYCategory *)[self objectAtIndexPath:indexPath];
        query.name = category.name;
        query.selectedCategory = category;

        for (HYCategory *childCategory in category.childCategories) {
            childCategory.query = query;
        }


        [vc performSelector:@selector(setQuery:)withObject:query];
    }
    else if ([segue.identifier isEqualToString:@"showFilterSegue"]) {
        [self.searchBar resignFirstResponder];
        self.blockerView.hidden = YES;
        [self dismissSearch];
        HYFilterViewController *vc = (HYFilterViewController *)((UINavigationController *)segue.destinationViewController).visibleViewController;

        if ([vc isKindOfClass:[HYFilterViewController class]]) {
            self.legacyFacets = [NSMutableArray array];
            [self.legacyFacets addObjectsFromArray:[self.query.selectedFacetValues allObjects]];

            if (self.query.selectedSort) {
                [self.legacyFacets addObject:self.query.selectedSort];
            }

            [vc performSelector:@selector(setQuery:)withObject:self.query];
            vc.delegate = self;
        }
    }
    else if ([segue.identifier isEqualToString:@"Product Detail Segue"]) {
        HYProductDetailViewController *vc = (HYProductDetailViewController *)segue.destinationViewController;
        self.showPlainBackButton = YES;
        HYProduct *product = (HYProduct *)[self objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        [vc performSelector:@selector(setProduct:)withObject:product];
        [vc performSelector:@selector(setThumbnail:)withObject:((HYProductCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                ]).imageView];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}


#pragma mark - ModalViewControllerDelegate

- (void)requestDismissAnimated:(BOOL)animated sender:(id)sender {
    [self dismissModalViewControllerAnimated:animated];

    NSMutableArray *currentFacets = [NSMutableArray array];
    [currentFacets addObjectsFromArray:[self.query.selectedFacetValues allObjects]];

    if (self.query.selectedSort) {
        [currentFacets addObject:self.query.selectedSort];
    }

    if (currentFacets.count != self.legacyFacets.count) {
        self.hasData = NO;
        [self fetchData];
    }
    else {
        if (![currentFacets isEqualToArray:self.legacyFacets]) {
            self.hasData = NO;
            [self fetchData];
        }
    }

    //Checks the return from the sender, button state depends on active selected facets
    if ([self.query.selectedFacetValues count]) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.filterButton setTintColor:UIColor_highlightTint];
            [self.filterButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor],  UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];
        }
    }
    else {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.filterButton setTintColor:UIColor_standardTint];
            [self.filterButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        }
    }
}


#pragma mark - Blocker View methods

- (IBAction)dismissBlockerView:(id)sender {
    self.blockerView.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];

    if ([[self.searchBar.text stringByTrimmingWhitespace] isEmpty]) {
        self.query.queryString = @"";
        [[HYWebService shared] products:self.query completionBlock:^(NSDictionary *results, NSError *error) {
                [self refreshViews];
            }];
    }
}

@end
