//
// HYProductOrderCell.m
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


#import "HYProductOrderCell.h"


@implementation HYProductOrderCell

- (void)awakeFromNib {
    self.productTitleLabel.text = @"";
    self.productTitleLabel.font = UIFont_bodyFont;

    self.productBrandLabel.text = @"";
    self.productBrandLabel.font = UIFont_smallFont;

    self.productTotalLabel.text = @"";
    self.productTotalLabel.font = UIFont_bodyFont;
    self.productTotalLabel.textColor = UIColor_priceTextColor;
    
    self.productItemPriceAndQuantityLabel.text = @"";
    self.productItemPriceAndQuantityLabel.font = UIFont_smallFont;

    // Selected state
    self.productTitleLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    self.productTotalLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    
    // Indicator
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
}


+ (NSString *)cellIdentifier {
    return @"Hybris Product Order Cell";
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:NO];
    
    if (selected && animated) {
        [UIView animateWithDuration:0.5 animations:^() {
            self.backgroundView.alpha = 0.5;
        }];
    }
    
    if (!selected && animated) {
        [UIView animateWithDuration:0.5 animations:^() {
            self.backgroundView.alpha = 1.0;
        }];
    }
}

@end
