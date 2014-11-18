//
// HYStoreDetailViewController.m
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

#import "HYStoreDetailViewController.h"
#import "HYStoreLocatorAddressCell.h"
#import "HYPhoneNumberCell.h"
#import <MapKit/MapKit.h>
#import "HYMapViewCell.h"
#import "HYStoreNameCell.h"
#import "HYStoreFeaturesCell.h"
#import "HYStoreLocatorHoursCell.h"
#import "HYStoreLocatorImageCell.h"


@interface HYStoreDetailViewController ()

@property (nonatomic, strong) HYStoreSearchObject *storeSearchObject;
@property (nonatomic, strong) NSArray *sectionIdentifiers;
@property (nonatomic) float featuresDynamicHeight;
@property (nonatomic, strong) NSDictionary *rowHeights;
@property (nonatomic, strong) UIImageView *storeImageView;

@end


@implementation HYStoreDetailViewController

static NSString *nameSectionIdentifier = @"HYStoreLocatorCellName";
static NSString *addressSectionIdentifier = @"HYStoreLocatorCellAddress";
static NSString *mapSectionIdentifier = @"HYStoreLocatorCellMap";
static NSString *phoneNumberSectionIdentifier = @"HYStoreLocatorCellPhone";
static NSString *hoursSectionIdentifier = @"HYStoreLocatorCellHours";
static NSString *featuresSectionIdentifier = @"HYStoreLocatorCellFeatures";
static NSString *imageSectionIdentifier = @"HYStoreLocatorCellImage";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionIdentifiers = [NSArray arrayWithObjects:
                               nameSectionIdentifier,
                               addressSectionIdentifier,
                               phoneNumberSectionIdentifier,
                               featuresSectionIdentifier,
                               hoursSectionIdentifier,
                               mapSectionIdentifier,
                               imageSectionIdentifier,
                               nil];
    
    self.title = NSLocalizedString(@"Store Description", @"Title of the store detail page");
    self.tableView.backgroundColor = UIColor_cellBackgroundColor;
}



#pragma mark Custom Accessors

/// Lazily set up when data is passed in
- (void)setStoreSearchObject:(HYStoreSearchObject *)storeObject {
    _storeSearchObject = storeObject;
    
    // Start downloading the image
    if (self.storeSearchObject.productImageUrl) {
        self.storeImageView = [[UIImageView alloc] init];
        [self.storeImageView setImageWithURL:self.storeSearchObject.productImageUrl];
    }
    
    [self calculateRowHeights];
    [self.tableView reloadData];
}


-(void) calculateRowHeights {
    float defaultCellHeight = 44.0;
    float nameCellHeight = 35.0;
    float addressCellHeight = 100.0;
    float imageCellHeight = 0.0;
    float phoneNumberCellHeight = 44.0;
    float featuresCellHeight = 0.0;
    float mapCellHeight = 290;
    float hoursCellHeight = 150;
    
    if (self.storeSearchObject.productImageUrl) {
        imageCellHeight = 220.0;
    }
    
    if ([HYStoreFeaturesCell heightForCellWithProduct:self.storeSearchObject] <= defaultCellHeight ) {
        featuresCellHeight = defaultCellHeight;
    }
    else {
        featuresCellHeight = [HYStoreFeaturesCell heightForCellWithProduct:self.storeSearchObject];
        
    }
    
    self.rowHeights = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithFloat:nameCellHeight],
                       nameSectionIdentifier,
                       [NSNumber numberWithFloat:addressCellHeight],
                       addressSectionIdentifier,
                       [NSNumber numberWithFloat:imageCellHeight],
                       imageSectionIdentifier,
                       [NSNumber numberWithFloat:phoneNumberCellHeight],
                       phoneNumberSectionIdentifier,
                       [NSNumber numberWithFloat:mapCellHeight],
                       mapSectionIdentifier,
                       [NSNumber numberWithFloat:hoursCellHeight],
                       hoursSectionIdentifier,
                       [NSNumber numberWithFloat:featuresCellHeight],
                       featuresSectionIdentifier,
                       nil];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionIdentifiers count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *nameCellIdentifier = @"StoreLocatorNameCell";
    static NSString *addressCellIdentifier = @"StoreLocatoraddressCell";
    static NSString *phoneCellIdentifier = @"StoreLocatorPhoneCell";
    static NSString *mapCellIdentifier = @"StoreLocatorMapCell";
    static NSString *featuresCellIdentifier = @"StoreLocatorFeaturesCell";
    static NSString *hoursCellIdentifier = @"StoreLocatorHoursCell";
    static NSString *imageCellIdentifier = @"StoreLocatorImageCell";
    
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];    
    id finalCell;
    
    if ([sectionIdentifier isEqualToString:nameSectionIdentifier]) {
        HYStoreNameCell *cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYStoreNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameCellIdentifier];
        }
        
        cell.storeName.text = self.storeSearchObject.storeName;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:addressSectionIdentifier]) {
        HYStoreLocatorAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:addressCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYStoreLocatorAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressCellIdentifier];
        }
        
        cell.addressTextView.text = self.storeSearchObject.storeAddressFull;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:phoneNumberSectionIdentifier]) {
        HYPhoneNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCellIdentifier];
        }
        [cell.button setTitle: self.storeSearchObject.phoneNumber forState:UIControlStateNormal];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:mapSectionIdentifier]) {
        HYMapViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mapCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYMapViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mapCellIdentifier];
        }
        
        cell.mapView.region = MKCoordinateRegionMakeWithDistance(
                                                                 CLLocationCoordinate2DMake(self.storeSearchObject.latitude,
                                                                                            self.storeSearchObject.longitude),
                                                                 500, 500);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(self.storeSearchObject.latitude, self.storeSearchObject.longitude);
        point.subtitle = self.storeSearchObject.storeName;
        [cell.mapView addAnnotation:point];
        
        cell.mapView.userInteractionEnabled = NO;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:featuresSectionIdentifier]) {
        HYStoreFeaturesCell *cell = [tableView dequeueReusableCellWithIdentifier:featuresCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYStoreFeaturesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:featuresCellIdentifier];
        }
        
        cell.title.text = NSLocalizedString(@"Features", @"Title of the feature section of a store detail.");
        NSMutableString * features = [NSMutableString stringWithString:@""];
        
        for (int i = 0; i < [self.storeSearchObject.features count]; i++) {
            [features appendString:[self.storeSearchObject.features objectAtIndex:i]];
            [features appendString:@"\n"];
        }
        
        cell.features.text = features;
        [cell.features sizeToFit];
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:hoursSectionIdentifier]) {
        HYStoreLocatorHoursCell *cell = [tableView dequeueReusableCellWithIdentifier:hoursCellIdentifier];
        
        if (cell == nil) {
            cell = [[HYStoreLocatorHoursCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hoursCellIdentifier];
        }
        
        cell.title.text = NSLocalizedString(@"Opening Hours", @"Title of the opening hours section of a store detail.");
        cell.labels.text = NSLocalizedString(@"Weekdays", @"Labels of the short weekdays names for the opening hours of a store.");
        NSMutableString * opening = [NSMutableString stringWithString:@""];
        
        for (int i = 0; i < [self.storeSearchObject.openingHours count]; i++) {
            if ([[[self.storeSearchObject.openingHours objectAtIndex:i] objectForKey:@"openStatus"] intValue] == 0) {
                [opening appendString:[NSString stringWithFormat:@"%@ - %@",
                                       [[self.storeSearchObject.openingHours objectAtIndex:i] objectForKey:@"opening"],
                                       [[self.storeSearchObject.openingHours objectAtIndex:i] objectForKey:@"closing"]]];
                [opening appendString:@"\n"];
            }
            else {
                [opening appendString: NSLocalizedStringWithDefaultValue(@"Closed", nil, [NSBundle mainBundle], @"Closed", @"Shop closed")];
            }
            
        }
        cell.openingHours.textAlignment = UITextAlignmentLeft;
        cell.openingHours.text = opening;
        [cell.openingHours sizeToFit];
        [cell.labels sizeToFit];
        finalCell = cell;
    }    
    else if ([sectionIdentifier isEqualToString:imageSectionIdentifier]) {
        HYStoreLocatorImageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
        cell.storeImageView.image = self.storeImageView.image;
        finalCell = cell;
    }
    
    return finalCell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];
    return [[self.rowHeights objectForKey:sectionIdentifier] floatValue];
}



#pragma mark Map external URL methods

- (IBAction)didPressShowInMaps {
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f", self.storeSearchObject.latitude, self.storeSearchObject.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
}


- (IBAction)didPressGetDirections {
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%f,%f", self.storeSearchObject.latitude, self.storeSearchObject.longitude];    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (IBAction)didPressCall:(id)sender {    
    NSString *telNum = [self.storeSearchObject.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", telNum]]];
}

@end
