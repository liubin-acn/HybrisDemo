//
// HYObjectListViewController.h
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

#import "HYShopTableViewController.h"
#import "ModalViewControllerDelegate.h"


@interface HYObjectListViewController:HYShopTableViewController<ModalViewControllerDelegate, UISearchBarDelegate>

/** The type of objects that the view controller wil display */
@property (nonatomic, strong) NSString *entityName;

/** The sort decsriptors that will order the returned objects */
@property (nonatomic, strong) NSArray *sortDescriptors;

/** The table view. This is created in the storyboard and so is a weak reference. */
@property (nonatomic, weak) IBOutlet UITableView *tableView;

/** The footer view for the table view. This is created programmatically and so is a strong reference. */
@property (nonatomic, strong) HYFooterView *footerView;

/** The objects */
@property (nonatomic, strong) NSArray *allObjects;

/// The filter button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;

/// The search table view
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

/** The header view for the table view. This is created programmatically and so is a strong reference. */
@property (nonatomic, strong) HYSearchResultsHeaderView *searchHeaderView;

/// The search bar
@property (strong, nonatomic) UISearchBar *searchBar;

/// The Blocker view, to cover the table when searching
@property (weak, nonatomic) IBOutlet UIButton *blockerView;
- (IBAction)dismissBlockerView:(id)sender;

- (void)hideSearchBar;

@end
