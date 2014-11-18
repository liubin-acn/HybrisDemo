//
// HYFilterViewController.m
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

#import "HYFilterViewController.h"

@interface HYFilterViewController ()

@property (nonatomic, strong) NSMutableArray *filterData;
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@end

@implementation HYFilterViewController

@synthesize query = _query;
@synthesize delegate = _delegate;

- (void)setQuery:(HYQuery *)query {
    if (![_query isEqual:query]) {
        _query = query;
    }

    self.title = query.name;
    [self refresh];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedStringWithDefaultValue(@"Refine", nil, [NSBundle mainBundle], @"Refine", @"Refine view title");
    [self.doneButton setTitle:NSLocalizedStringWithDefaultValue(@"Done", nil, [NSBundle mainBundle], @"Done", @"Title for the done button.")];
    [self.clearAllFiltersButton setTitle:NSLocalizedStringWithDefaultValue(@"Clear All", nil, [NSBundle mainBundle], @"Clear All", @"Clear all button title.")];
}


- (void)refresh {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];

    NSMutableArray *sorts = [NSMutableArray array];
    NSMutableArray *facets = [NSMutableArray array];

    for (id item in self.query.items) {
        if ([item isKindOfClass:[HYFacet class]]) {
            [facets addObject:item];
            logDebug(@"found %@", ((HYFacet *)item).name);
        }
        else if ([item isKindOfClass:[HYSort class]]) {
            [sorts addObject:item];
        }
    }

    // Sort the facets
    for (HYFacet *hyf in facets) {
        NSArray *sortedArray =
            [hyf.facetValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
        [mutableDict setObject:sortedArray forKey:hyf.name];
    }

    // Sort the sort options
    NSArray *sortedSortArray = [sorts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

    // Add the data
    self.filterData = [[NSMutableArray alloc] initWithArray:[mutableDict allValues]];
    [self.filterData insertObject:sortedSortArray atIndex:0];

    // Store the titles
    self.sectionTitles = [[NSMutableArray alloc] initWithArray:[mutableDict allKeys]];
    [self.sectionTitles insertObject:NSLocalizedStringWithDefaultValue(@"Sort By", nil, [NSBundle mainBundle], @"Sort By", @"Sort section title")
        atIndex:0];

    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filterData.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)[self.filterData objectAtIndex:section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CartIdentifier = @"Filter Cell";
    static NSString *SortIdentifier = @"Sort Cell";
    UITableViewCell *cell = nil;

    HYObject *object = [[self.filterData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([object isKindOfClass:[HYFacetValue class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CartIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CartIdentifier];
        }

        if (((HYFacetValue *)object).selected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        [HYFacetValue decorateCell:cell withObject:object];
    }
    else if ([object isKindOfClass:[HYSort class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:SortIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SortIdentifier];
        }

        cell.textLabel.text = ((HYSort *)object).name;

        if ([((HYSort *)object).internalName isEqualToString:self.query.selectedSort.internalName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        cell.detailTextLabel.text = @"";
    }

    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    HYObject *object = [[self.filterData objectAtIndex:section] objectAtIndex:0];

    // Perform a check to see whether the class is multiselect or not
    if ([object isKindOfClass:[HYFacetValue class]] && ![((HYFacetValue *)object).facet multiSelectEnabled]) {
        return [NSString stringWithFormat:@"%@ %@", [self.sectionTitles objectAtIndex:section],
            NSLocalizedStringWithDefaultValue(@"(Choose one)", nil, [NSBundle mainBundle], @"(Choose one)", @"Singular choice identifier")];
    }
    else {
        return [self.sectionTitles objectAtIndex:section];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    HYObject *object = [[self.filterData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if (([object isKindOfClass:[HYFacetValue class]] && [((HYFacetValue *)object).facet multiSelectEnabled])) {
        if (((HYFacetValue *)object).selected) {
            ((HYFacetValue *)object).selected = NO;
        }
        else {
            ((HYFacetValue *)object).selected = YES;
        }
    }
    else {
        if ([object isKindOfClass:[HYFacetValue class]]) {
            if (((HYFacetValue *)object).selected) {
                ((HYFacetValue *)object).selected = NO;
            }
            else {
                for (HYFacetValue *vf in((HYFacetValue *)object).facet.facetValues) {
                    vf.selected = NO;
                }

                ((HYFacetValue *)object).selected = YES;
            }
        }
        else if ([object isKindOfClass:[HYSort class]]) {
            [self.query setSelectedSort:(HYSort *)object];
        }
    }

    if ([self.query.selectedFacetValues count]) {
        [self.delegate requestDismissAnimated:YES sender:self];
    }
    else {
        [self clearAllFilters:self];
    }
}


#pragma mark - Actions

- (IBAction)dismiss:(id)sender {
    [self.delegate requestDismissAnimated:YES sender:self];
}


- (IBAction)clearAllFilters:(id)sender {
    [self.query.selectedFacetValues removeAllObjects];
    [self.delegate requestDismissAnimated:YES sender:self];
}


@end
