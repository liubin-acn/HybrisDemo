//
// HYCheckoutSummaryCell.m
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


#import "HYCheckoutSummaryCell.h"


@interface HYCheckoutSummaryCell()

@property (nonatomic, weak) IBOutlet HYLabel *numberOfItemsLabel;
@property (nonatomic, weak) IBOutlet HYLabel *totalCostLabel;
@property (nonatomic, weak) IBOutlet HYLabel *totalCostTitleLabel;
@property (nonatomic, weak) IBOutlet HYLabel *preTaxCostLabel;
@property (nonatomic, weak) IBOutlet HYLabel *totalTaxLabel;
@property (nonatomic, weak) IBOutlet HYLabel *totalDiscountLabel;

@end



@implementation HYCheckoutSummaryCell

- (void)decorateCellLabelWithContents:(id)contents {
    self.numberOfItemsLabel.font = UIFont_informationLabelFont;
    self.totalDiscountLabel.font = UIFont_promotionFont;
    self.totalTaxLabel.font = UIFont_informationLabelFont;
    self.totalCostLabel.font = UIFont_promotionFont;
    
    if (contents && [contents isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)contents count] > 1) {
            self.numberOfItemsLabel.text = [contents objectAtIndex:0];
            self.totalCostLabel.text = [contents objectAtIndex:3];
            self.totalTaxLabel.text = [contents objectAtIndex:2];
            self.totalDiscountLabel.text = [contents objectAtIndex:1];
            self.preTaxCostLabel.text = [contents objectAtIndex:3];
            self.totalCostLabel.textColor = UIColor_lightBlueTextTint;
            self.totalCostTitleLabel.textColor = UIColor_lightBlueTextTint;
        }
    }
    self.backgroundColor = [UIColor whiteColor];
}


@end
