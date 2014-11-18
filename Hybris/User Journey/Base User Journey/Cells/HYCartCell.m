//
// HYCartCell.m
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


#import "HYCartCell.h"


@implementation HYCartCell

@synthesize imageView;


- (void)awakeFromNib {
    [super awakeFromNib];

    // Reset all fields to remove examples from storyboard
    [self.imageView setImage:[UIImage imageNamed:HYProductCellPlaceholderImage]];

    self.productBrandLabel.text = @"";
    self.productBrandLabel.font = UIFont_smallFont;

    self.itemPriceLabel.text = @"";
    self.itemPriceLabel.font = UIFont_priceFont;

    self.totalPriceLabel.text = @"";
    self.totalPriceLabel.font = UIFont_priceFont;
    self.totalPriceLabel.textColor = UIColor_lightBlueTextTint;

    self.itemQuantityLabel.text = @"";
    self.itemQuantityLabel.font = UIFont_variantFont;

    self.productTitleLabel.text = @"";
    self.productTitleLabel.font = UIFont_bodyFont;

    // Draw the line
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    separatorView.backgroundColor = UIColor_dividerBorderColor;
    [self addSubview:separatorView];

    // Background
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
    
    self.quantityDescriptionLabel.text = NSLocalizedString(@"Quantity", @"Quantity label");
    self.quantityDescriptionLabel.font = UIFont_titleFont;
}


@end
