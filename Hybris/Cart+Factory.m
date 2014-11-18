//
// Cart+Factory.m
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

#import "CartEntry.h"
#import "Price.h"
#import "HYCartCell.h"

@implementation Cart (Factory)

+ (void)decorateCell:(HYCartCell *)cell withObject:(Cart *)cartObject forCartEntry:(NSInteger)entry {
    CartEntry *cartEntry = [cartObject.entries objectAtIndex:entry];

    cell.totalPriceLabel.font = UIFont_priceFont;
    cell.totalPriceLabel.textColor = UIColor_lightBlueTextTint;

    [cell.imageView setImageWithURL:[NSURL URLWithString:cartEntry.product.thumbnail] placeholderImage:[UIImage imageNamed:HYProductCellPlaceholderImage]];
    cell.imageView.frame = CGRectMake(11.0, 16.0, 75.0, 75.0);
    cell.productTitleLabel.text = cartEntry.product.name;
    cell.productBrandLabel.text = cartEntry.product.manufacturer;
    cell.itemPriceLabel.text = cartEntry.basePrice.formattedValue;
    cell.totalPriceLabel.text = cartEntry.totalPrice.formattedValue;
    cell.itemQuantityLabel.text = [cartEntry.quantity stringValue];
    [cell setFrame:CGRectMake(0, 0, 320, 150.0)];
}


@end
