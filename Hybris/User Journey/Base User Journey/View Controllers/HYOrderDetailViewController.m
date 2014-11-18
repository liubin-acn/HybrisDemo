//
// HYOrderDetailViewController.m
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

#import "HYOrderDetailViewController.h"
#import "HYBasicCell.h"
#import "HYBasicAttributedCell.h"
#import "HYProductOrderCell.h"
#import "CartEntry.h"
#import "Price.h"
#import "HYProductDetailViewController.h"
#import "HYCheckoutSummaryCell.h"


@interface HYOrderDetailViewController ()

// Section identifiers
@property (nonatomic, strong) NSArray *sectionIdentifiers;

@end


static NSString *basicIdentifier = @"Hybris Basic Cell";
static NSString *basicAttributedIdentifier = @"Hybris Basic Attributed Cell";
static NSString *deliveryAddressSectionIdentifier = @"HYOrderDetailDeliveryAddressCell";
static NSString *deliveryMethodSectionIdentifier = @"HYOrderDetailDeliveryMethodCell";
static NSString *paymentMethodSectionIdentifier = @"HYOrderDetailPaymentMethodCell";
static NSString *summarySectionIdentifier = @"Hybris Summary Cell";


@implementation HYOrderDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.orderStatusLabel.font = UIFont_orderStatusFont;
    self.orderStatusLabel.textColor = UIColor_priceTextColor;
    self.orderStatusView.backgroundColor = UIColor_cellBackgroundColor;
        
    [self.orderStatusView.layer setCornerRadius:7];
    [self.orderStatusView.layer setBorderWidth:1.0f];
    [self.orderStatusView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
    
    self.orderStatusHeaderLabel.font = UIFont_titleFont;
    self.orderStatusHeaderLabel.text = NSLocalizedString(@"Order Status", @"Section header for order status");
    
    self.confirmationLabel.font = UIFont_detailMediumFont;
    self.confirmationLabel.numberOfLines = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicAttributedCell class]) bundle:nil] forCellReuseIdentifier:basicAttributedIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HYBasicCell class]) bundle:nil] forCellReuseIdentifier:basicIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Specify the order of the sections
    self.sectionIdentifiers = [NSArray arrayWithObjects:
                               deliveryAddressSectionIdentifier,
                               deliveryMethodSectionIdentifier,
                               paymentMethodSectionIdentifier,
                               [HYProductOrderCell cellIdentifier],
                               summarySectionIdentifier,
                               nil];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
}


- (void)viewDidUnload {
    [self setOrderStatusView:nil];
    [self setConfirmationLabel:nil];
    [self setOrderStatusLabel:nil];
    [super viewDidUnload];
}


- (void)setOrderDetails:(NSDictionary *)orderDetails {
    if (orderDetails) {
        _orderDetails = orderDetails;
        NSDate *orderDate = [NSDate dateFromISO8601String:[self.orderDetails objectForKey:@"created"]];
        NSString *placeOn = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Placed on", nil), [orderDate dateAndTimeAsString]];

        self.confirmationLabel.text = [NSString stringWithFormat:@"%@", placeOn];
        self.orderStatusLabel.text = [self.orderDetails objectForKey:@"statusDisplay"];

        [self.tableView reloadData];
    }
}


- (void)setOrderDetailID:(NSString *)orderDetailID {
    if (orderDetailID) {
        _orderDetailID = orderDetailID;
        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Your Order", nil), self.orderDetailID];
        [self waitViewShow:YES];
        [[HYWebService shared] orderDetailsWithID:self.orderDetailID completionBlock:^(NSDictionary *dict, NSError *error) {
                [self waitViewShow:NO];

                if (error) {
                    [[HYAppDelegate sharedDelegate] alertWithError:error];
                }
                else {
                    self.orderDetails = [[NSDictionary alloc] initWithDictionary:dict];
                }
            }];
    }
}



#pragma mark - Helper methods

- (NSArray *)addressArray {
    NSDictionary *addressInfo = [_orderDetails objectForKey:@"deliveryAddress"];
    NSMutableArray *addressArray = [[NSMutableArray alloc] init];

    if (addressInfo) {
        [addressArray addObject:[NSArray arrayWithObjects:[addressInfo objectForKey:@"title"], [addressInfo objectForKey:@"firstName"], [addressInfo objectForKey:@"lastName"], nil]];
        [addressArray addObject:[addressInfo objectForKey:@"line1"]];
        
        if ([addressInfo objectForKey:@"line2"]) {
            [addressArray addObject:[addressInfo objectForKey:@"line2"]];
        }
        
        [addressArray addObject:[addressInfo objectForKey:@"town"]];
        [addressArray addObject:[addressInfo objectForKey:@"postalCode"]];
        [addressArray addObject:[[addressInfo objectForKey:@"country"] objectForKey:@"name"]];
    }
    
    return addressArray;
}


- (NSArray *)deliveryMethodArray {
    NSDictionary *deliveryInfo = [_orderDetails objectForKey:@"deliveryMode"];

    return [NSArray arrayWithObjects:
        [deliveryInfo objectForKey:@"name"],
        [deliveryInfo objectForKey:@"description"],
        [[deliveryInfo objectForKey:@"deliveryCost"] objectForKey:@"formattedValue"],
        nil];
}


- (NSArray *)paymentInfoArray {
    NSDictionary *paymentInfo = [_orderDetails objectForKey:@"paymentInfo"];

    return [NSArray arrayWithObjects:
        [paymentInfo objectForKey:@"accountHolderName"],
        [paymentInfo objectForKey:@"cardNumber"],
        [[paymentInfo objectForKey:@"cardType"] objectForKey:@"name"],
        nil];
}


- (NSArray *)orderSummaryArray {
    NSString *itemString;
    
    if ([[self.orderDetails objectForKey:@"totalItems"] intValue] == 1) {
        itemString = [NSString stringWithFormat:NSLocalizedString(@"%i Item", @"Number of items (singular)"), [[self.orderDetails objectForKey:@"totalItems"] intValue]];
    } else {
        itemString = [NSString stringWithFormat:NSLocalizedString(@"%i Items", @"Number of items (plural)"), [[self.orderDetails objectForKey:@"totalItems"] intValue]];
    }
        
    return [NSArray arrayWithObjects:
            itemString,
            [[self.orderDetails objectForKey:@"totalDiscounts"]  objectForKey:@"formattedValue"],
            [[self.orderDetails objectForKey:@"totalTax"]  objectForKey:@"formattedValue"],
            [[self.orderDetails objectForKey:@"totalPrice"]  objectForKey:@"formattedValue"],
            
            nil];
    return nil;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIdentifiers.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:section];
    
    if ([sectionIdentifier isEqualToString:[HYProductOrderCell cellIdentifier]]) {
        return ((NSDictionary *)[self.orderDetails objectForKey:@"entries"]).count;
    }
    
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 49.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {    
    static NSString *cellIdentifier = @"orderDetailSectionHeaderCell";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *label = (UILabel *)[headerView viewWithTag:555];
    label.font = UIFont_titleFont;
    label.textColor = UIColor_textColor;
    
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:section];
        
    if ([sectionIdentifier isEqualToString:deliveryAddressSectionIdentifier]) {
        [label setText:@"Delivery Address"];
    } else if ([sectionIdentifier isEqualToString:deliveryMethodSectionIdentifier]) {
        [label setText:@"Delivery Method"];
    } else if ([sectionIdentifier isEqualToString:paymentMethodSectionIdentifier]) {
        [label setText:@"Payment Method"];
    } else if ([sectionIdentifier isEqualToString:[HYProductOrderCell cellIdentifier]]) {
        [label setText:@"Basket Details"];
    } else if ([sectionIdentifier isEqualToString:summarySectionIdentifier]) {
        [label setText:@"Summary"];
    }
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];
    
    if ([sectionIdentifier isEqualToString:deliveryAddressSectionIdentifier]) {
        return [HYBasicAttributedCell heightForCellWithContents:[self addressArray]];
    } else if ([sectionIdentifier isEqualToString:deliveryMethodSectionIdentifier]) {
        return [HYBasicCell heightForCellWithContents:[self deliveryMethodArray]] + 5.0;
    } else if ([sectionIdentifier isEqualToString:paymentMethodSectionIdentifier]) {
        return [HYBasicCell heightForCellWithContents:[self paymentInfoArray]] + 5.0;
    } else if ([sectionIdentifier isEqualToString:[HYProductOrderCell cellIdentifier]]) {
        return 105.0;
    } else if ([sectionIdentifier isEqualToString:summarySectionIdentifier]) {
        return 89.0;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];
    id finalCell;
    
    if ([sectionIdentifier isEqualToString:deliveryAddressSectionIdentifier]) {
        HYBasicAttributedCell *cell = [tableView dequeueReusableCellWithIdentifier:basicAttributedIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell decorateCellLabelWithContents:[self addressArray]];
        
        // Set first line bold
        NSString *address = cell.label.text;
        NSString *firstLine = [[address componentsSeparatedByString: @"\n"] objectAtIndex:0];
        
        [cell.label setText:address afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
            NSRange firstLineRange = [address rangeOfString:firstLine];
            
            if (firstLineRange.location != NSNotFound) {
                CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)UIFont_defaultBoldFont.fontName, UIFont_defaultBoldFont.pointSize, NULL);
                
                if (font) {
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:firstLineRange];
                    CFRelease(font);
                }
            }
            
            return mutableAttributedString;
        }];
        
        finalCell = cell;
    } else if ([sectionIdentifier isEqualToString:deliveryMethodSectionIdentifier]) {
        HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell decorateCellLabelWithContents:[self deliveryMethodArray]];
        finalCell = cell;
    } else if ([sectionIdentifier isEqualToString:paymentMethodSectionIdentifier]) {
        HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:basicIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell decorateCellLabelWithContents:[self paymentInfoArray]];
        finalCell = cell;
    } else if ([sectionIdentifier isEqualToString:[HYProductOrderCell cellIdentifier]]) {
        HYProductOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:[HYProductOrderCell cellIdentifier]];
        
        if (cell == nil) {
            cell = [[HYProductOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[HYProductOrderCell cellIdentifier]];
        }
        
        NSMutableDictionary *entryInfo = [[[self.orderDetails objectForKey:@"entries"] objectAtIndex:indexPath.row] mutableCopy];
        CartEntry *cartEntry = [[CartEntry alloc] init];
        [cartEntry setValuesForKeysWithDictionary:entryInfo];
        
        Price *priceObject = [[Price alloc] init];
        [priceObject setValuesForKeysWithDictionary:[entryInfo objectForKey:@"totalPrice"]];
        [cartEntry setValue:priceObject forKey:@"totalPrice"];
        
        priceObject = [[Price alloc] init];
        [priceObject setValuesForKeysWithDictionary:[entryInfo objectForKey:@"basePrice"]];
        [cartEntry setValue:priceObject forKey:@"basePrice"];
        
        [entryInfo setObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"] forKey:@"imageBaseURL"];
        
        HYProduct *p = [HYProduct objectWithInfo:entryInfo];
        [cartEntry setValue:p forKey:@"product"];
        
        cell.productTitleLabel.text = cartEntry.product.name;
        
        if (cartEntry.product.displayPrice) {
            cell.productItemPriceAndQuantityLabel.text = [NSString stringWithFormat:@"%@ - %@: %@", cartEntry.product.displayPrice, NSLocalizedString(@"Quantity", nil), [cartEntry.quantity stringValue]];
        }
        else {
            cell.productItemPriceAndQuantityLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Quantity", nil), [cartEntry.quantity stringValue]];
        }
        
        cell.productTotalLabel.text = cartEntry.totalPrice.formattedValue;
        [cell.productImageView setImageWithURL:[NSURL URLWithString:[cartEntry.product.primaryImageURLs objectForKey:@"cartIcon"]]];
        
        cell.productTotalLabel.textColor = UIColor_priceTextColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
        finalCell = cell;
    } else if ([sectionIdentifier isEqualToString:summarySectionIdentifier]) {
        HYCheckoutSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:summarySectionIdentifier];
        
        if (cell == nil) {
            cell = [[HYCheckoutSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:summarySectionIdentifier];
        }
        
        [cell decorateCellLabelWithContents:[self orderSummaryArray]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColor_cellBackgroundColor;
        finalCell = cell;
    }

    return finalCell;
}



#pragma mark - Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Product Detail Segue"]) {
        HYProductDetailViewController *vc = (HYProductDetailViewController *)segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary *entryInfo = [[[self.orderDetails objectForKey:@"entries"] objectAtIndex:indexPath.row] mutableCopy];
        [entryInfo setObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"] forKey:@"imageBaseURL"];
        HYProduct *product = [HYProduct objectWithInfo:entryInfo];
        [vc performSelector:@selector(setProduct:)withObject:product];
        [self setShowPlainBackButton:YES];

        // Get the rest of the product data
        NSArray *options =
            [NSArray arrayWithObjects:HYProductOptionBasic, HYProductOptionCategories, HYProductOptionClassification, HYProductOptionDescription,
            HYProductOptionGallery,
            HYProductOptionPrice, HYProductOptionPromotions, HYProductOptionReview, HYProductOptionStock, HYProductOptionVariant, nil];
        [[HYWebService shared] productWithCode:product.productCode options:options completionBlock:^(NSArray *results, NSError *error) {
                [vc refresh];
            }];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
