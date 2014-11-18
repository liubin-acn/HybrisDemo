//
// HYProductPriceCell.m
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


#import "HYProductPriceCell.h"
#import "HYProduct+Factory.h"


@implementation HYProductPriceCell

@synthesize price;
@synthesize stock;
@synthesize quantityLabel;
@synthesize quantityDescriptionLabel;


- (void)awakeFromNib {
    [super awakeFromNib];

    // Reset all fields to remove examples from storyboard
    self.price.text = @"";
    self.price.font = UIFont_priceLargeFont;
    self.stock.text = @"";
    self.stock.font = UIFont_smallBoldFont;

    self.quantityLabel.font = UIFont_variantFont;

    self.quantityDescriptionLabel.font = UIFont_titleFont;
    self.quantityDescriptionLabel.text = NSLocalizedString(@"Quantity", @"Quantity label");

    [self.quantityButton setTitle:@"" forState:UIControlStateNormal];

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
}


- (void)decorateCellWithProduct:(HYProduct *)product {
    self.price.text = product.displayPrice;
    self.stock.text = @"";
    self.price.textColor = UIColor_brandTextColor;
    self.stock.textColor = UIColor_lightTextColor;
    
    NSArray *sortedKeys = [[product.variantInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    if (product.purchasable == NO) {
        for (NSString *key in sortedKeys) {
            if ([product.selectedVariantInfo objectForKey:key] == nil) {
                self.stock.text = [NSString stringWithFormat:NSLocalizedString(@"select %@", @"Variant field with no selected value"), NSLocalizedString([key lowercaseString], @"")];
                break;
            }
        }
    }
    else if ([product.stockLevelStatus isEqualToString:@"lowStock"]) {
        self.stock.text = [NSString stringWithFormat:NSLocalizedString(@"Only %1$i left", @"Stock details low stock"), [product.stockLevel intValue]];
    }
    else if ([product.stockLevelStatus isEqualToString:@"outOfStock"]) {
        self.stock.text = [HYProduct mapStockCode:product.stockLevelStatus];
        self.stock.textColor = UIColor_warningTextColor;
    }
    else if ([product.stockLevelStatus isEqualToString:@"inStock"]) {
        self.stock.text = [HYProduct mapStockCode:product.stockLevelStatus];
    }
    
    // Replace the label with an actual number if we have one
    if ([product.stockLevel intValue] > 0) {
        self.stock.text = [NSString stringWithFormat:NSLocalizedString(@"%1i in stock", @"Stock details in stock"), [product.stockLevel intValue]];
    }
    
    // Hide other controls?
    if ([product.stockLevelStatus isEqualToString:@"Out Of Stock"] || [product.stockLevel intValue] == 0) {
        self.quantityDescriptionLabel.hidden = YES;
        self.quantityLabel.hidden = YES;
        self.quantityButton.enabled = NO;
    }
    else {
        self.quantityDescriptionLabel.hidden = NO;
        self.quantityLabel.hidden = NO;
        self.quantityButton.enabled = YES;
    }
}


@end
