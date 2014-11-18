//
// HYShopSearchCell.m
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


#import "HYShopSearchCell.h"


@implementation HYShopSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shopDistance.font = UIFont_titleFont;
    self.shopDistance.textColor = UIColor_distanceColor;
    self.shopName.font = UIFont_titleFont;
    self.shopAddress.font = UIFont_informationLabelFont;
    
    self.shopName.highlightedTextColor = UIColor_lightBlueTextTint;
    self.shopAddress.highlightedTextColor = UIColor_lightBlueTextTint;
    
    // Draw the line
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    separatorView.backgroundColor = UIColor_dividerBorderColor;
    [self addSubview:separatorView];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    UIView *backgroundSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    backgroundSeparatorView.backgroundColor = UIColor_dividerBorderColor;
    [self.selectedBackgroundView addSubview:backgroundSeparatorView];
    _highlightedSeparatorLine = backgroundSeparatorView;

    // Indicator
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // Re-set the background color of the line
    for (UIView *v in self.selectedBackgroundView.subviews) {
        v.backgroundColor = UIColor_dividerBorderColor;
    }
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
