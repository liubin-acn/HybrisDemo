//
// HYProductDetailViewController.m
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

#import "HYProductDetailViewController.h"
#import "HYProduct+Factory.h"
#import "HYProductNameCell.h"
#import "HYProductImageCell.h"
#import "HYProductPriceCell.h"
#import "HYProductAddCell.h"
#import "HYProductShareCell.h"
#import "HYProductDescriptionCell.h"
#import "HYProductPromotionCell.h"
#import "HYBasicCell.h"
#import "HYAllReviewsCell.h"
#import "HYReviewsViewController.h"
#import "HYPickerControl.h"
#import "HYProductVariantCell.h"
#import "HYDescriptionViewController.h"
#import "HYDeliveryViewController.h"


@interface  HYProductDetailViewController ()

#pragma mark UI Elements

/// The name
@property (weak, nonatomic) HYLabel *nameLabel;

/// The manufacturer / brand
@property (weak, nonatomic) HYLabel *brandLabel;

/// The description
@property (weak, nonatomic) HYTextView *descriptionView;

/// The price
@property (weak, nonatomic) HYLabel *priceLabel;

/// The stock level
@property (weak, nonatomic) HYLabel *stockLevelLabel;

/// The product code
@property (weak, nonatomic) HYLabel *codeLabel;

/// The main image view. This will be replaced with a side-scrolling image viewer.
@property (weak, nonatomic) UIImageView *imageView;

/// Add To Cart Button
@property (weak, nonatomic) HYButton *addToCartButton;

#pragma mark Other Properties

/// Cell heights
@property (strong, nonatomic) NSDictionary *rowHeights;

/// A sharable object reference for tweeting/facebook etc
@property (strong, nonatomic) HYSharableObject *sharableObject;

/// A flag to say if the product has been fully populated
@property (nonatomic) BOOL populated;

// Tile view nib name
@property (nonatomic, strong) NSString *imageTileNibName;

// Gallery images
@property (nonatomic, strong) NSMutableArray *gallery;

// Section identifiers
@property (nonatomic, strong) NSArray *sectionIdentifiers;



#pragma mark Signatures

/// Helper to pre-calculate row heights
- (void)calculateRowHeights;

/// Fully populate the product
- (void)populateProduct;

/// Repopulate the product with a particular section
- (void)repopulateProductWithOptions:(NSArray *)options;

/// When a variant type is selected its sender is used as a reference point to load the picker
- (void)onVariantSelect:(id)sender;

/// Returns a string of variants from the selected array
- (NSMutableArray *)variantStringsFromArray:(NSArray *)variants andTitle:(NSString *)title;

/// Change quantity loads a custom UIPicker class which returns a selected value
- (IBAction)changeQuantity:(id)sender;

- (NSString *)createWebProductUrl;

@end

static NSString *nameSectionIdentifier = @"HYProductDetailCellName";
static NSString *imageSectionIdentifier = @"HYProductDetailCellImage";
static NSString *reviewsSectionIdentifier = @"HYProductDetailCellReviews";
static NSString *priceSectionIdentifier = @"HYProductDetailCellPrice";
static NSString *variantSectionIdentifier = @"HYProductDetailCellVariant";
static NSString *addSectionIdentifier = @"HYProductDetailCellAdd";
static NSString *promotionSectionIdentifier = @"HYProductDetailCellPromotion";
static NSString *descriptionSectionIdentifier = @"HYProductDetailCellDescription";
static NSString *classificationSectionIdentifier = @"HYProductDetailCellClassification";
static NSString *deliverySectionIdentifier = @"HYProductDetailCellDelivery";
static NSString *shareSectionIdentifier = @"HYProductDetailCellShare";


@implementation HYProductDetailViewController

#pragma mark - Overridden Accessors

- (void)setProduct:(HYProduct *)product {
    _product = product;
    [self populateProduct];
}


#pragma mark - View Lifecycle

- (void)refresh {
    [self calculateRowHeights];
    [self.tableView reloadData];
}


- (void)calculateRowHeights {
    // Calculate the size of the description cell
    HYProductDescriptionCell *tempDescriptionCell = [self.tableView dequeueReusableCellWithIdentifier:@"Product Description Cell"];

    tempDescriptionCell.description.text = self.product.productDescription;
    [tempDescriptionCell sizeToFit];

    float defaultCellHeight = 44.0;
    float priceCellHeight = 58.0;
    float addCellHeight = 51.0;
    float imageCellHeight = 208.0;
    float shareCellHeight = 54.0;
    float variantCellHeight = 45.0;

    // Checks for no content cells
    float promotionsCellHeight = 0.0;

    if (self.product.potentialPromotions && ((NSArray *)self.product.potentialPromotions).count) {
        promotionsCellHeight = [HYProductPromotionCell heightForCellWithProduct:self.product] + (STANDARD_MARGIN * 4);
    }

    float classificationsCellHeight = 0.0;

    if (self.product.classifications.count > 0) {
        classificationsCellHeight = defaultCellHeight;
    }

    float deliveryCellHeight = 0.0;

    if (self.product.deliveryInformation.length) {
        deliveryCellHeight = 48.0;
    }

    float reviewCellHeight = 0.0;

    if ([self.product.reviews count]) {
        reviewCellHeight = 44.0;
    }

    float descriptionCellHeight = 0.0;

    if (self.product.productDescription.length > 0) {
        descriptionCellHeight = tempDescriptionCell.description.frame.size.height + STANDARD_MARGIN * 4;
    }

    // Dictionary of row heights
    self.rowHeights = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSNumber numberWithFloat:0],
        nameSectionIdentifier,
        [NSNumber numberWithFloat:imageCellHeight],
        imageSectionIdentifier,
        [NSNumber numberWithFloat:reviewCellHeight],
        reviewsSectionIdentifier,
        [NSNumber numberWithFloat:priceCellHeight],
        priceSectionIdentifier,
        [NSNumber numberWithFloat:variantCellHeight],
        variantSectionIdentifier,
        [NSNumber numberWithFloat:addCellHeight],
        addSectionIdentifier,
        [NSNumber numberWithFloat:promotionsCellHeight],
        promotionSectionIdentifier,
        [NSNumber numberWithFloat:descriptionCellHeight],
        descriptionSectionIdentifier,
        [NSNumber numberWithFloat:classificationsCellHeight],
        classificationSectionIdentifier,
        [NSNumber numberWithFloat:deliveryCellHeight],
        deliverySectionIdentifier,
        [NSNumber numberWithFloat:shareCellHeight],
        shareSectionIdentifier,
        nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    HYLabel *label = [[ViewFactory shared] make:[HYLabel class] withFrame:CGRectMake(100.0, 0.0, 250.0, 44.0)];
    label.backgroundColor = [UIColor clearColor];
    label.font = UIFont_navigationBarFont;
    label.minimumFontSize = 10.0;
    label.numberOfLines = 1.0;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = UIColor_inverseTextColor;
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = label;

    self.title = self.product.name;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // keep this to fix a layout issue for promotions
    [self refresh];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageTileNibName = @"HYProductImageTile";

    // Specify the order of the sections
    self.sectionIdentifiers = [NSArray arrayWithObjects:
        nameSectionIdentifier,
        reviewsSectionIdentifier,
        imageSectionIdentifier,
        priceSectionIdentifier,
        variantSectionIdentifier,
        addSectionIdentifier,
        promotionSectionIdentifier,
        descriptionSectionIdentifier,
        classificationSectionIdentifier,
        deliverySectionIdentifier,
        shareSectionIdentifier,
        nil];
}


- (void)viewDidUnload {
    self.product = nil;
    self.brandLabel = nil;
    self.descriptionView = nil;
    self.priceLabel = nil;
    self.stockLevelLabel = nil;
    self.imageView = nil;
    self.sharableObject = nil;
    [self setCodeLabel:nil];
    [self setAddToCartButton:nil];
    self.tableView = nil;
    [super viewDidUnload];
}


- (void)setTitle:(NSString *)title {
    HYLabel *label = ((HYLabel *)self.navigationItem.titleView);

    label.text = title;
}

- (void)reachabilityChanged:(Reachability *)reachability {
    if ([reachability isReachable]) {
        [self populateProduct];
    }
    
    [super reachabilityChanged:reachability];
}


- (void)populateProduct {
    if (!self.populated) {
        // Get the rest of the product data
        NSArray *options =
            [NSArray arrayWithObjects:HYProductOptionBasic, HYProductOptionCategories, HYProductOptionClassification, HYProductOptionDescription,
            HYProductOptionGallery,
            HYProductOptionPrice, HYProductOptionPromotions, HYProductOptionReview, HYProductOptionStock, HYProductOptionVariant, nil];
        [[HYWebService shared] productWithCode:self.product.productCode options:options completionBlock:^(NSArray *results, NSError *error) {
                self.populated = YES;

                self.product = [results objectAtIndex:0];
                self.title = self.product.name;
                [self refresh];
            }];
    }
}

- (void)repopulateProductWithOptions:(NSArray *)options {
    if (!self.populated) {
        [self populateProduct];
    }
    else {
        [[HYWebService shared] productWithCode:self.product.productCode options:options completionBlock:^(NSArray *results, NSError *error) {
                self.populated = YES;
                [self.product addDetailsFromProduct:[results objectAtIndex:0]];
                [self refresh];
            }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIdentifiers.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:section];

    if ([sectionIdentifier isEqualToString:variantSectionIdentifier]) {
        return self.product.variantInfo.count;
    }

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *productCellIdentifier = @"Product Name Cell";
    static NSString *imageCellIdentifier = @"Product Image Cell";
    static NSString *priceCellIdentifier = @"Product Price Cell";
    static NSString *addCellIdentifier = @"Product Add Cell";
    static NSString *variantCellIdentifier = @"Variant Selection Cell";
    static NSString *shareCellIdentifier = @"Product Share Cell";
    static NSString *descriptionCellIdentifier = @"Product Description Cell";
    static NSString *promotionCellIdentifier = @"Product Promotion Cell";
    static NSString *classificationCellIdentifier = @"Product Classification Cell";
    static NSString *deliveryCellIdentifier = @"Product Delivery Cell";
    static NSString *reviewsCellIdentifier = @"All Reviews Cell";

    id finalCell;

    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];

    if ([sectionIdentifier isEqualToString:nameSectionIdentifier]) {
        HYProductNameCell *cell = [tableView dequeueReusableCellWithIdentifier:productCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:productCellIdentifier];
        }

        cell.label.text = self.product.name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:imageSectionIdentifier]) {
        HYProductImageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
        }

        NSString *imageURLString;

        if ([self.product.primaryImageURLs objectForKey:@"product"]) {
            imageURLString = [self.product.primaryImageURLs objectForKey:@"product"];
        }
        else {
            imageURLString = [self.product.primaryImageURLs objectForKey:@"thumbnail"];
        }

        [cell.imageView setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:[UIImage imageNamed:HYProductCellPlaceholderImage]];

        cell.scrollingTileBar.delegate = self;
        cell.scrollingTileBar.datasource = self;
        [cell.scrollingTileBar reloadDataWithAnimation:NO];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:priceSectionIdentifier]) {
        HYProductPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:priceCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductPriceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:priceCellIdentifier];
        }

        [cell decorateCellWithProduct:self.product];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:variantSectionIdentifier]) {
        HYProductVariantCell *cell = [tableView dequeueReusableCellWithIdentifier:variantCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.variantSelectButton addTarget:self action:@selector(onVariantSelect:)forControlEvents:UIControlEventTouchUpInside];
        NSArray *sortedKeys = [[self.product.variantInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        if ([self.product.selectedVariantInfo objectForKey:[sortedKeys objectAtIndex:indexPath.row]]) {
            [cell.variantValueLabel setText:[self.product.selectedVariantInfo objectForKey:[sortedKeys objectAtIndex:indexPath.row]]];
            cell.variantValueLabel.textColor = UIColor_textColor;
        }
        else {
            for (NSString *key in sortedKeys) {
                if ([self.product.selectedVariantInfo objectForKey:key] == nil) {
                    [cell.variantValueLabel setText:[NSString stringWithFormat:NSLocalizedString(@"select %@", @"Variant field with no selected value"), NSLocalizedString([key lowercaseString], @"")]];
                    cell.variantValueLabel.textColor = UIColor_brandTextColor;
                    break;
                }
            }
        }

        cell.variantTypeDescriptionLabel.text = [sortedKeys objectAtIndex:indexPath.row];
        cell.variantSelectButton.titleLabel.textAlignment = UITextAlignmentCenter;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:addSectionIdentifier]) {
        HYProductAddCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.addButton addTarget:self action:@selector(onAddToCart:)forControlEvents:UIControlEventTouchUpInside];

        // Disable if out of stock
        cell.addButton.enabled = [self.product.stockLevel intValue] != 0;

        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:shareSectionIdentifier]) {
        HYProductShareCell *cell = [tableView dequeueReusableCellWithIdentifier:shareCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shareCellIdentifier];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:promotionSectionIdentifier]) {
        HYProductPromotionCell *cell = [tableView dequeueReusableCellWithIdentifier:promotionCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductPromotionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:promotionCellIdentifier];
        }

        [cell decorateCellWithProduct:self.product];
        
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;

        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:descriptionSectionIdentifier]) {
        HYProductDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:descriptionCellIdentifier];

        if (cell == nil) {
            cell = [[HYProductDescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:descriptionCellIdentifier];
        }

        // Parse content
        NSString *updatedContent = [self.product.productDescription stringByReplacingOccurrencesOfString:@" -" withString:@"\n - "];
        updatedContent = [updatedContent stringByReplacingOccurrencesOfString:@"Features:" withString:@"\n\nFeatures:\n"];
        updatedContent = [updatedContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        cell.description.text = updatedContent;

        [cell sizeToFit];
        // Draw the line
        UIView *separatorView =
            [[UIView alloc] initWithFrame:CGRectMake(10.0, [[self.rowHeights objectForKey:descriptionSectionIdentifier] floatValue] - 1.0,
                cell.frame.size.width -
                20.0, 1.0)];
        separatorView.backgroundColor = UIColor_dividerBorderColor;
        [cell addSubview:separatorView];

        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        finalCell = cell;
    }
    else if ([sectionIdentifier isEqualToString:classificationSectionIdentifier]) {
        HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:classificationCellIdentifier];

        if (cell == nil) {
            cell = [[HYBasicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classificationCellIdentifier];
        }

        cell.label.text = NSLocalizedStringWithDefaultValue(@"More Information",
            nil,
            [NSBundle mainBundle],
            @"More Information",
            @"Product more information title");
        finalCell = cell;

        cell.textLabel.font = UIFont_informationLabelFont;

        // Indicator
        cell.accessoryView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];

        // Line
        cell.separatorLine.hidden = NO;
        cell.highlightedSeparatorLine.hidden = NO;
    }
    else if ([sectionIdentifier isEqualToString:deliverySectionIdentifier]) {
        HYBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:deliveryCellIdentifier];

        if (cell == nil) {
            cell = [[HYBasicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deliveryCellIdentifier];
        }

        cell.label.text = NSLocalizedStringWithDefaultValue(@"Delivery Information",
            nil,
            [NSBundle mainBundle],
            @"Delivery Information",
            @"Product delivery information title");
        finalCell = cell;

        // Indicator
        cell.accessoryView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];

        // Line
        cell.separatorLine.hidden = NO;
        cell.highlightedSeparatorLine.hidden = NO;
    }
    else if ([sectionIdentifier isEqualToString:reviewsSectionIdentifier]) {
        HYAllReviewsCell *cell = [tableView dequeueReusableCellWithIdentifier:reviewsCellIdentifier];
        [cell decorateCellWithProduct:self.product];
        [cell sizeToFit];

        // Indicator
        cell.accessoryView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];

        finalCell = cell;
    }

    return (UITableViewCell *)finalCell;
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = [self.sectionIdentifiers objectAtIndex:indexPath.section];

    return [[self.rowHeights objectForKey:sectionIdentifier] floatValue];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Product Description Cell Segue"]) {
        // More info
        [((HYDescriptionViewController *)segue.destinationViewController) setDisplayString:((HYProductDescriptionCell *)[self.tableView cellForRowAtIndexPath:indexPath]).description.text];
        ((UIViewController *)segue.destinationViewController).title = NSLocalizedStringWithDefaultValue(@"Description",
                                                                                                        nil,
                                                                                                        [NSBundle mainBundle],
                                                                                                        @"Description",
                                                                                                        @"Product description title");
    }
    else if ([segue.identifier isEqualToString:@"Product Delivery Cell Segue"]) {
        // Delivery info
        [((HYDeliveryViewController *)segue.destinationViewController) setDisplayString:self.product.deliveryInformation];
        ((UIViewController *)segue.destinationViewController).title = NSLocalizedStringWithDefaultValue(@"Description",
                                                                                                        nil,
                                                                                                        [NSBundle mainBundle],
                                                                                                        @"Description",
                                                                                                        @"Product description title");
    }
    else if ([segue.destinationViewController respondsToSelector:@selector(setProduct:)]) {
        // More information (classifications)
        [segue.destinationViewController performSelector:@selector(setProduct:)withObject:self.product];
        ((UIViewController *)segue.destinationViewController).title = NSLocalizedStringWithDefaultValue(@"More Information",
                                                                                                        nil,
                                                                                                        [NSBundle mainBundle],
                                                                                                        @"More Information",
                                                                                                        @"Product more information title");
    }
    else if ([segue.destinationViewController respondsToSelector:@selector(setReviews:)]) {
        // Show reviews
        [segue.destinationViewController performSelector:@selector(setReviews:)withObject:self.product.reviews];
        ((UIViewController *)segue.destinationViewController).title = NSLocalizedStringWithDefaultValue(@"All Reviews",
                                                                                                        nil,
                                                                                                        [NSBundle mainBundle],
                                                                                                        @"All Reviews",
                                                                                                        @"All Reviews title");
    }
}



#pragma mark - Actions

- (void)addToCartAnimation {
    // get the exact location of image
    CGRect rect = [self.thumbnail.superview convertRect:self.thumbnail.frame fromView:nil];

    rect = CGRectMake(5, (rect.origin.y* -1)-10, self.thumbnail.frame.size.width, self.thumbnail.frame.size.height);
    logDebug(@"rect is %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    // create new duplicate image
    UIImageView *starView = [[UIImageView alloc] initWithImage:self.thumbnail.image];
    [starView setFrame:rect];
    starView.layer.cornerRadius = 5;
    starView.layer.borderColor = [[UIColor blackColor] CGColor];
    starView.layer.borderWidth = 1;
    [self.view addSubview:starView];

    // begin ---- apply position animation
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = 0.65;
    pathAnimation.delegate = self;

    // tab-bar right side item frame-point = end point
    CGPoint endPoint = CGPointMake(self.view.frame.size.width - 37.0, 390+rect.size.height/2);

    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, starView.frame.origin.x, starView.frame.origin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, starView.frame.origin.y, endPoint.x, starView.frame.origin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    // end ---- apply position animation

    // apply transform animation
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform"];
    [basic setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 0.25)]];
    [basic setAutoreverses:NO];
    [basic setDuration:0.65];

    [starView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    [starView.layer addAnimation:basic forKey:@"transform"];

    [starView performSelector:@selector(removeFromSuperview)withObject:nil afterDelay:0.65];
    [self performSelector:@selector(reloadBadgeNumber)withObject:nil afterDelay:0.65];
}


- (void)reloadBadgeNumber {
    NSInteger sectionIndex = [self.sectionIdentifiers indexOfObject:priceSectionIdentifier];

    HYProductPriceCell *priceCell = (HYProductPriceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    NSInteger quantity = [priceCell.quantityLabel.text integerValue];

    for (NSInteger i = 0; i < quantity; i++) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HYItemAddedToCart object:nil];
    }
}

- (IBAction)onAddToCart:(id)sender {
    NSInteger priceSectionIndex = [self.sectionIdentifiers indexOfObject:priceSectionIdentifier];
    HYProductPriceCell *priceCell = (HYProductPriceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:priceSectionIndex]];
    NSInteger quantity = [priceCell.quantityLabel.text integerValue];

    NSInteger addSectionIndex = [self.sectionIdentifiers indexOfObject:addSectionIdentifier];
    HYProductAddCell *addCell = (HYProductAddCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:addSectionIndex]];

    addCell.addButton.enabled = NO;

    [[HYWebService shared] addProductToCartWithCode:self.product.productCode quantity:quantity completionBlock:^(NSDictionary *dictionary, NSError *error) {
            if (error) {
                [[HYAppDelegate sharedDelegate] alertWithError:error];
            }
            else {
                NSString *alertTitle;
                NSString *alertMessage;

                if ([[dictionary objectForKey:@"statusCode"] isEqualToString:@"success"]) {
                    [self addToCartAnimation];

                    // Update the product
                    [self repopulateProductWithOptions:[NSArray arrayWithObject:HYProductOptionPromotions]];
                }
                else {
                    alertTitle =
                        NSLocalizedStringWithDefaultValue (@"General Error alert box title", nil, [NSBundle mainBundle], @"Sorry",
                        @"Error alert box title for expected errors");
                    alertMessage =
                        [NSString stringWithFormat:NSLocalizedStringWithDefaultValue (@"Product not added to cart", nil, [NSBundle mainBundle],
                            @"Product could not be added: %1$@",
                            @"Product not added to cart message"), [dictionary objectForKey:@"statusCode"]];
                    UIAlertView *alert =
                        [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:NSLocalizedStringWithDefaultValue(
                            @"OK", nil, [NSBundle mainBundle], @"OK", @"OK button") otherButtonTitles:nil];
                    [alert show];
                }
            }

            addCell.addButton.enabled = YES;
        }];
}

- (IBAction)onTweet:(id)sender {
    self.sharableObject = [[HYSharableObject alloc] initWithString:self.product.name];
    self.sharableObject.link = [self createWebProductUrl];
    self.sharableObject.name = self.product.name;
    self.sharableObject.price = self.product.displayPrice;
    self.sharableObject.text = self.product.productDescription;

    if ([self.sharableObject respondsToSelector:@selector(tweetFromViewController:)]) {
        [self.sharableObject tweetFromViewController:self];
    }
}


- (IBAction)onFacebookPost:(id)sender {
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       self.product.name, @"name",
                                       [self createWebProductUrl], @"link",
                                       self.product.displayPrice, @"price",
                                       self.product.thumbnail, @"imageLink",
                                       self.product.productDescription, @"text",
                                       nil];
    
    self.sharableObject = [[HYSharableObject alloc] initWithDictionary:postParams];
    self.sharableObject.image = [UIImage imageNamed:@"action-facebook.png"];

    [[HYAppDelegate sharedDelegate] openSessionWithAllowLoginUI:YES completionBlock:^{
            if (self.sharableObject && [self.sharableObject respondsToSelector:@selector(facebookPostFromViewController:)]) {
                [self.sharableObject facebookPostFromViewController:self];
            }
        }];
}


- (IBAction)onMail:(id)sender {
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        self.product.name, @"name",
        [self createWebProductUrl], @"link",
        self.product.displayPrice, @"price",
        self.product.thumbnail, @"imageLink",
        self.product.productDescription, @"text",
        nil];

    self.sharableObject = [[HYSharableObject alloc] initWithDictionary:postParams];

    if ([self.sharableObject respondsToSelector:@selector(mailFromViewController:)]) {
        [self.sharableObject mailFromViewController:self];
    }
}


- (NSString *)createWebProductUrl {
    NSString *site = [[[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *webserviceUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"];
    
    return [NSString stringWithFormat:[[HYAppDelegate sharedDelegate].configDictionary objectForKey:@"productSharingPattern"],
            webserviceUrl,
            self.product.code,
            site
            ];
}



#pragma mark - Scrolling Tilebar DataSource and Delegate

- (NSUInteger)numberOfTilesInScrollingTileBar:(ScrollingTileBar *)aScrollingTileBar {
    return ((NSArray *)self.product.galleryImageURLs).count;
}


- (HYScrollingTileBarTile *)scrollingTileBar:(ScrollingTileBar *)aScrollingTileBar tileForTileAtIndex:(NSUInteger)tileIndex {
    HYScrollingTileBarTile *newTile;

    if (self.imageTileNibName) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.imageTileNibName owner:aScrollingTileBar options:nil];

        if ([nib count]) {
            newTile = [nib objectAtIndex:0];
        }
        else{
            logError(@"NIB incomplete");
        }
    }
    else {
        logError(@"NIB missing");
    }

    NSDictionary *galleryImage = [((NSArray *)self.product.galleryImageURLs) objectAtIndex:tileIndex];
    [newTile.imageView setImageWithURL:[NSURL URLWithString:[galleryImage objectForKey:@"product"]] placeholderImage:[UIImage imageNamed:
            HYProductCellPlaceholderImage]];

    return newTile;
}


- (void)scrollingTileBar:(ScrollingTileBar *)aScrollingTileBar didSelectTileAtIndex:(NSUInteger)tileIndex {
}


- (void)scrollingTileBarDidScroll:(ScrollingTileBar *)aScrollingTileBar {
}


- (void)didTapTileWithIndex:(NSInteger)tileIndex {
    // Build the gallery if needed
    if (self.gallery == nil) {
        self.gallery = [NSMutableArray array];

        for (NSDictionary *imageURLs in((NSArray *)self.product.galleryImageURLs)) {
            [self.gallery addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[imageURLs objectForKey:@"zoom"]]]];
        }
    }

    // Make and show the browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];

    [browser setInitialPageIndex:tileIndex];
    [self.navigationController presentModalViewController:[[HYNavigationViewController alloc] initWithRootViewController:browser] animated:YES];
}



#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return ((NSArray *)self.product.galleryImageURLs).count;
}


- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.gallery objectAtIndex:index];
}



#pragma mark - Quantity Methods

- (IBAction)changeQuantity:(id)sender {
    NSInteger rows = [self.product.stockLevel intValue];
    
    NSInteger priceSectionIndex = [self.sectionIdentifiers indexOfObject:priceSectionIdentifier];
    HYProductPriceCell *priceCell = (HYProductPriceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:priceSectionIndex]];
    NSMutableArray *values = [HYPickerControl arrayFromQuantity:rows withZero:NO];
    
    if (priceCell.quantityLabel.text) {
        NSInteger index = [priceCell.quantityLabel.text integerValue] - 1;
        [HYPickerControl showPickerWithValues:values labels:nil index:index completionBlock:^(NSInteger result) {
            priceCell.quantityLabel.text = [NSString stringWithFormat:@"%i", [[NSNumber numberWithDouble:result] intValue] + 1];
        }];
    }
}



#pragma mark - Variant Methods

- (void)onVariantSelect:(id)sender {
    NSInteger variantIndex = 0;

    // Gets a pointer to the selected cell
    HYProductVariantCell *clickedCell = (HYProductVariantCell *)[[sender superview] superview];

    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSInteger currentRow = clickedButtonPath.row;

    NSArray *sortedKeys = [[self.product.variantInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *variantData = [self.product.variantInfo objectForKey:[sortedKeys objectAtIndex:currentRow]];

    NSString *buttonTitle = clickedCell.variantSelectButton.titleLabel.text;

    // convert to array of strings
    NSMutableArray *pickerValues = [self variantStringsFromArray:variantData andTitle:buttonTitle];

    // Get the current index from the variant info so the picker will load on it
    for (NSString *value in pickerValues) {
        if ([value isEqualToString:[self.product.selectedVariantInfo objectForKey:[sortedKeys objectAtIndex:clickedButtonPath.row]]]) {
            variantIndex = [pickerValues indexOfObject:value];
            break;
        }
    }

    // make labels (so they can be different)
    NSMutableArray *labels;

    if ([[sortedKeys objectAtIndex:currentRow] isEqualToString:@"Size"]) {
        labels = [NSMutableArray array];

        for (NSDictionary *data in variantData) {
            if ([data objectForKey:@"stockLevel"]) {
                [labels addObject:[NSString stringWithFormat:@"%@   -   %@ %@",
                        [data objectForKey:@"value"],
                        [data objectForKey:@"stockLevel"],
                        NSLocalizedStringWithDefaultValue(@"in stock", nil, [NSBundle mainBundle], @"in stock", @"size picker stock label")]];
            }
        }

        if (labels.count != pickerValues.count) {
            labels = nil;
        }
    }

    //Pass the array to the picker and include the index of the selected value
    [HYPickerControl showPickerWithValues:pickerValues labels:labels index:variantIndex completionBlock:^(NSInteger result) {
            //Get the product code
            NSString *productCode = [[variantData objectAtIndex:result] objectForKey:@"code"];

            //Create a new product from the product code and refresh the page with it
            NSArray *options =
                [NSArray arrayWithObjects:HYProductOptionBasic, HYProductOptionCategories, HYProductOptionClassification, HYProductOptionDescription,
                HYProductOptionGallery, HYProductOptionPrice, HYProductOptionPromotions, HYProductOptionReview, HYProductOptionStock, HYProductOptionVariant,
                nil];
            [[HYWebService shared] productWithCode:productCode options:options completionBlock:^(NSArray *results, NSError *error) {
                    self.populated = YES;
                    self.product = nil;
                    self.product = [results objectAtIndex:0];
                    [self refresh];
                    [self setTitle:self.product.name];
                }];
        }];
}

- (NSMutableArray *)variantStringsFromArray:(NSArray *)variants andTitle:(NSString *)title {
    NSMutableArray *variantsArray = [NSMutableArray array];

    for (NSDictionary *productVariantDictionary in variants) {
        if ([productVariantDictionary objectForKey:@"value"]) {
            NSString *valueString = [productVariantDictionary objectForKey:@"value"];
            [variantsArray addObject:valueString];
        }
    }

    NSArray *unsortedArray = [NSArray arrayWithArray:variantsArray];
    [variantsArray removeAllObjects];
    NSArray *sortedArray = [unsortedArray sortedArrayUsingComparator:^(id firstObject, id secondObject) {
            return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
        }];
    variantsArray = [NSMutableArray arrayWithArray:sortedArray];

    return variantsArray;
}

@end

