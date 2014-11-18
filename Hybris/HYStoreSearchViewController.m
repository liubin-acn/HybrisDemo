//
// HYStoreSearchViewController.m
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

#import "HYStoreSearchViewController.h"
#import "HYStoreSearchObject.h"
#import "HYBasicCell.h"
#import "HYShopSearchCell.h"


typedef enum {
    HYStoreSearchTypeLocation,
    HYStoreSearchTypeQuery,
} HYStoreSearchType;


@interface HYStoreSearchViewController ()

@property (nonatomic, strong) NSMutableArray *storeArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic, strong) NSString *currentSearch;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) HYSearchResultsHeaderView *searchHeaderView;
@property (nonatomic, strong) HYFooterView *footerView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingStoresIndicator;
@property (nonatomic, strong) UIView *headerView;

// BOOL to prevent view reload from replacing search results
@property (nonatomic) BOOL hasPerformedSearch;

/// the Blocker view, to cover the table when searching
@property (weak, nonatomic) IBOutlet UIButton *blockerView;

@property (nonatomic) HYStoreSearchType locationType;

- (IBAction)dismissBlockerView:(id)sender;
- (void)startSearch;
- (void)searchStoresForLocation:(CLLocation *)location withRadius:(NSInteger)radius;
- (void)startLocationUpdate;
- (void)locationUpdateTimedOut;

@end


@implementation HYStoreSearchViewController

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize radius = _radius;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 0;
    self.totalPage = 1;
    self.title = NSLocalizedStringWithDefaultValue(@"Store Locator", nil, [NSBundle mainBundle], @"Store Locator", @"Title of Store Locator View Controller");
    
    self.blockerView.frame = CGRectMake(0.0, 88.0, 320.0, 960.0);
    self.blockerView.hidden = YES;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, 44.0)];
    self.searchBar.delegate = self;

    if (self.searchHeaderView == nil) {
        self.searchHeaderView =
        [[ViewFactory shared] make:[HYSearchResultsHeaderView class] withFrame:CGRectMake (0, 0, self.tableView.frame.size.width,
                                                                                           HEADER_HEIGHT)];
    }
    
    self.footerView = [[ViewFactory shared] make:[HYFooterView class] withFrame:CGRectMake(0, 0, self.tableView.frame.size.width, FOOTER_HEIGHT)];
    
    // create and add an activity indicator to the footer - it automatically hides when not animating
    self.loadingStoresIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(280.0, 3.0, 35.0, 35.0)];
    self.loadingStoresIndicator.hidesWhenStopped = YES;
    
    [self.footerView addSubview:self.loadingStoresIndicator];
    [self.tableView setTableFooterView:self.footerView];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // create custom location button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30.0, 30.0);
    [button setImage:[UIImage imageNamed:@"location-button.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button] ;

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.searchBar.frame.size.height +
                                             self.searchHeaderView.frame.size.height)];
    [self.headerView addSubview:self.searchBar];
    [self.headerView addSubview:self.searchHeaderView];
    CGRectSetY(self.searchHeaderView.frame, self.searchBar.frame.size.height);
    self.tableView.tableHeaderView = self.headerView;
    
    self.radius = -1;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = LOCATION_ACCURACY;    
    }
    
    if (!self.hasPerformedSearch && self.latitude == 0 && self.longitude == 0) {
        [self startLocationUpdate];
    } else if (self.latitude != 0 && self.longitude != 0) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
        [self searchStoresForLocation:location withRadius:self.radius];
    }
    
    [self checkLocationServices];

}


- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}


- (void)clearTable {
    // if a search is being replaced, wipe the data
    if ([self.storeArray count]) {
        [self.storeArray removeAllObjects];
        self.currentPage = 0;
        [self.tableView reloadData];
    }
}


- (void)checkLocationServices {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showDisabledLocationState];
    }
}


- (void)showDisabledLocationState {
    if (!self.footerView.hidden) {
        self.footerView.hidden = YES;
        self.loadingStoresIndicator.hidden = YES;
    }
    
    if (self.searchHeaderView.label.text.length) {
        self.searchHeaderView.label.text = @"";
    }    
}


- (void)dismissSearch {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.blockerView.hidden = YES;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}


- (void)displayResultsWithDictionary:(NSDictionary *)dict {
    NSArray *variants = [dict valueForKeyPath:@"stores"];
    self.totalPage = [[dict valueForKeyPath:@"pagination.totalPages"] integerValue];    
    NSInteger totalResuls = [[dict valueForKeyPath:@"pagination.totalResults"] integerValue];    
    NSString *labelString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"n total results", nil, [NSBundle mainBundle], @"%1$i total results",
                                                                               @"Completed count of results (plural)"),totalResuls];
    self.searchHeaderView.label.text = labelString;    
    NSMutableArray *tempArray = [NSMutableArray array];
    HYStoreSearchObject *searchObject;
    
    if (self.currentPage < self.totalPage) {
        for (NSDictionary *storeDictionary in variants) {
            searchObject = nil;            
            searchObject = [[HYStoreSearchObject alloc] init];            
            searchObject.latitude = [[storeDictionary valueForKeyPath:@"geoPoint.latitude"]  floatValue];
            searchObject.longitude = [[storeDictionary valueForKeyPath:@"geoPoint.longitude"]  floatValue];            
            searchObject.storeName = [storeDictionary objectForKey:@"name"];
            searchObject.storeDistance = [storeDictionary objectForKey:@"formattedDistance"];
            NSString *secondAddressLine = @"";
            
            if ([storeDictionary valueForKeyPath:@"address.line2"]) {
                secondAddressLine = [storeDictionary valueForKeyPath:@"address.line2"];
            }
            
            searchObject.storeAddressShort = [storeDictionary valueForKeyPath:@"address.line1"];
            
            NSString *postCode = @"";
            
            if ( [storeDictionary valueForKeyPath:@"address.postalCode"]) {
                postCode = [storeDictionary valueForKeyPath:@"address.postalCode"];
            }
            
            NSString *fullStoreAddress = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",
                                          [storeDictionary valueForKeyPath:@"address.line1"],
                                          secondAddressLine,
                                          postCode,
                                          [storeDictionary valueForKeyPath:@"address.town"],
                                          [storeDictionary valueForKeyPath:@"address.country.name"]
                                          ];

            searchObject.storeAddressFull = [fullStoreAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                             
            searchObject.phoneNumber = [storeDictionary valueForKeyPath:@"address.phone"];
            
            if ([storeDictionary objectForKey:@"storeImages"]) {
                for (NSArray *imageArray in [storeDictionary objectForKey:@"storeImages"]) {
                    searchObject.productImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                    [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"],
                                                    [[[storeDictionary objectForKey:@"storeImages"] objectAtIndex:0] objectForKey:@"url"]]];
                }
                
                //Get the features
                NSArray *storeFeaturesArray = [storeDictionary objectForKey:@"features"];
                NSMutableArray *featuresArray = [NSMutableArray array];
                for (NSDictionary *features in storeFeaturesArray) {
                    [featuresArray addObject:[features objectForKey:@"value"]];
                }
                searchObject.features = featuresArray;
                
                //Get the times
                NSArray *openingTimes = [[storeDictionary objectForKey:@"openingHours"] objectForKey:@"weekDays"];
                
                NSArray *timesArray = [NSArray arrayWithArray:openingTimes];
                
                for (NSDictionary *timesDict in timesArray) {
                    NSMutableDictionary *hoursDictionary = [[NSMutableDictionary alloc] init];
                    
                    if ([[timesDict objectForKey:@"closingTime"] objectForKey:@"formattedHour"]) {
                        [hoursDictionary setObject:[[timesDict objectForKey:@"closingTime"] objectForKey:@"formattedHour"] forKey:@"closing"];
                    }
                    
                    if ([[timesDict objectForKey:@"openingTime"] objectForKey:@"formattedHour"]) {
                        [hoursDictionary setObject:[[timesDict objectForKey:@"openingTime"] objectForKey:@"formattedHour"] forKey:@"opening"];
                    }
                    
                    [hoursDictionary setObject:[timesDict objectForKey:@"closed"] forKey:@"openStatus"];
                    [hoursDictionary setObject:[timesDict objectForKey:@"weekDay"] forKey:@"day"];
                    [searchObject.openingHours addObject:hoursDictionary];
                    hoursDictionary = nil;
                }
                
                [tempArray addObject:searchObject];
                searchObject = nil;
            }            
        }
        
        if (self.currentPage > 0) {
            self.storeArray = [[NSMutableArray alloc]initWithArray:(NSMutableArray *)[self.storeArray arrayByAddingObjectsFromArray:tempArray]];
        }
        else {
            self.storeArray = [[NSMutableArray alloc]initWithArray:tempArray];
        }                
    }
    
    if ([self.storeArray count]) {
        self.footerView.hidden = NO;
    }
    else {
        self.footerView.hidden = YES;
    }
    
    self.loadingStoresIndicator.hidden = YES;
    [self.tableView setTableFooterView:self.footerView];
    NSString *footerString;
    
    if (self.currentPage < self.totalPage) {
        footerString =
        [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"Showing n of m results", nil, [NSBundle mainBundle],
                                                                     @"Showing %1$i of %2$i results",
                                                                     @"On-going count of results"), self.storeArray.count, totalResuls];
    }
    else {
        footerString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"n total results", nil, [NSBundle mainBundle], @"%1$i total results",
                                                                                    @"Completed count of results (plural)"),totalResuls];
    }
    
    self.footerView.label.text = footerString;
    [self.loadingStoresIndicator stopAnimating];
    [self.tableView reloadData];
}



#pragma mark - custom getter and setter

- (void)setLatitude:(CGFloat)latitude {
    _latitude = latitude;
    self.hasPerformedSearch = NO;
}


- (void)setLongitude:(CGFloat)longitude {
    _longitude = longitude;
    self.hasPerformedSearch = NO;
}


- (void)setRadius:(NSInteger)radius {
    _radius = radius;
    self.hasPerformedSearch = NO;
}



#pragma mark - Tableview scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.loadingStoresIndicator startAnimating];

    if ([scrollView isEqual:self.tableView]) {
        if (([scrollView contentOffset].y + scrollView.frame.size.height) == [scrollView contentSize].height) {
            self.loadingStoresIndicator.hidden = NO;
            
            if (self.currentPage < self.totalPage - 1) {
                self.currentPage = self.currentPage + 1;

                switch (self.locationType) {
                    case HYStoreSearchTypeLocation:
                    {
                        NSInteger radius = 50000;
                        if (self.radius > -1) {
                            radius = self.radius;
                        }
                        
                        [[HYWebService shared] storesAtLocation:self.currentLocation withCurrentPage:self.currentPage radius:radius completionBlock:^(NSDictionary *dictionary, NSError *error) {
                            if (error) {
                                [[HYAppDelegate sharedDelegate] alertWithError:error];
                            }
                            else {
                                self.locationType = HYStoreSearchTypeLocation;
                                [self displayResultsWithDictionary:dictionary];
                            }
                        }];
                    }
                        break;
                    case HYStoreSearchTypeQuery:
                    {
                        [[HYWebService shared] storesWithQueryString:self.currentSearch withCurrentPage:self.currentPage completionBlock:^(NSDictionary *dict, NSError *error) {
                            [self displayResultsWithDictionary:dict];
                            self.hasPerformedSearch = YES;
                            self.blockerView.hidden = YES;
                        }];
                    }
                        break;
                    default:
                        break;
                }
            }
            else {
                [self.loadingStoresIndicator stopAnimating];
            }
        }
        else {
            [self.loadingStoresIndicator stopAnimating];
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    if ([segue.destinationViewController respondsToSelector:@selector(setStoreSearchObject:)]) {
        HYStoreSearchObject *searchObject = [self.storeArray objectAtIndex:indexPath.row];
        [segue.destinationViewController performSelector:@selector(setStoreSearchObject:) withObject:searchObject];
        ((UIViewController *)segue.destinationViewController).title = NSLocalizedStringWithDefaultValue(searchObject.storeName,
            nil,
            [NSBundle mainBundle],
            searchObject.storeName,
            @"Product description title");
        [self setShowPlainBackButton:YES];
    }
}



#pragma mark - Table view delegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.storeArray count]) {
        return [self.storeArray count];
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Hybris Basic Cell";
    static NSString *searchCellIdentifier = @"Hybris Shop Search Cell";
    NSString *noContentString;
    id finalCell;

    if ([self.storeArray count]) {        
        HYShopSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];        
        HYStoreSearchObject *storeSearchObject = [self.storeArray objectAtIndex:indexPath.row];

        cell.shopName.text = storeSearchObject.storeName;
        cell.shopAddress.text = storeSearchObject.storeAddressShort;
        cell.shopDistance.text = [storeSearchObject.storeDistance uppercaseString];
        cell.shopDistance.textColor = UIColor_distanceColor;
        finalCell = cell;
    }
    else {
        HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {            
            noContentString =  NSLocalizedStringWithDefaultValue(@"Location services are disabled\n Please enable in your settings",
                                                     nil,
                                                     [NSBundle mainBundle],
                                                     @"Location services are disabled\n Please enable in your settings",
                                                     @"Message displayed if location services are disabled");
        }
        else {
            noContentString =  @"";
            self.searchHeaderView.label.text = NSLocalizedStringWithDefaultValue(@"No results",
                                                                     nil, [NSBundle mainBundle],
                                                                     @"No results",
                                                                     @"No results message");
        }

        cell.label.text = noContentString;
        finalCell = cell;
        self.footerView.hidden = YES;
    }

    return (UITableViewCell *)finalCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark - Location service delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
        [self.locationManager stopUpdatingLocation];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationUpdateTimedOut) object:nil];
    }
    
    [self searchStoresForLocation:newLocation withRadius:(self.radius == -1)?50000:self.radius];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self locationError:error];
}


- (void)locationError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationUpdateTimedOut) object:nil];
    
    switch([error code])
    {
        case kCLErrorDenied:
            break;
        case kCLErrorNetwork: // general, network-related error
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert box title") message:NSLocalizedString(@"Unable to geolocate you.", @"Error message for location update that took too long.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
            [alert show];
        }
            break;
    }
    
    [self checkLocationServices];
}



#pragma mark - UI search bar delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.currentPage = 0;
    self.latitude = 0;
    self.longitude = 0;
    self.radius = -1;
    
    [[HYWebService shared] storesWithQueryString:searchBar.text withCurrentPage:self.currentPage completionBlock:^(NSDictionary *dict, NSError *error) {
        self.locationType = HYStoreSearchTypeQuery;
        [self clearTable];
        [self displayResultsWithDictionary:dict];
        self.hasPerformedSearch = YES;
        self.blockerView.hidden = YES;
        self.currentSearch = searchBar.text;
        [self.searchBar setShowsCancelButton:NO animated:YES];
        
    }];
    
    [searchBar resignFirstResponder];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.blockerView.hidden = NO;
    [self.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:YES];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissSearch];
}



#pragma mark - private methods

- (IBAction)dismissBlockerView:(id)sender {
    self.blockerView.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}


- (void)startSearch {
    [self clearTable];
    self.latitude = 0;
    self.longitude = 0;
    self.radius = -1;
    
    [self startLocationUpdate];
    [self checkLocationServices];
    
    if (self.searchBar.text.length) {
        self.searchBar.text = @"";
    }
    
    self.hasPerformedSearch = YES;
}


- (void)searchStoresForLocation:(CLLocation *)location withRadius:(NSInteger)radius {
    self.currentPage = 0;
    [self clearTable];
    
    [[HYWebService shared] storesAtLocation:location withCurrentPage:self.currentPage radius:radius completionBlock:^(NSDictionary *dictionary, NSError *error) {
        if (error) {
            [[HYAppDelegate sharedDelegate] alertWithError:error];
        }
        else {
            self.locationType = HYStoreSearchTypeLocation;
            self.currentLocation = location;
            [self displayResultsWithDictionary:dictionary];
        }
    }];
}


- (void)startLocationUpdate {
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(locationUpdateTimedOut) withObject:nil afterDelay:LOCATION_TIMEOUT];
}


- (void)locationUpdateTimedOut {
    [self.locationManager stopUpdatingLocation];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert box title") message:NSLocalizedString(@"Unable to geolocate you.", @"Error message for location update that took too long.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
    [alert show];
}

@end
