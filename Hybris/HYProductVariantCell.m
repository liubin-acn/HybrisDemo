//
// HYProductVariantCell.m
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


#import "HYProductVariantCell.h"


@implementation HYProductVariantCell

- (void)setup {            
    self.variantValueLabel.font = UIFont_variantFont;
    
    self.variantTypeDescriptionLabel.font = UIFont_titleFont;
    self.variantTypeDescriptionLabel.text = @"";
    
    self.variantSelectButton.titleLabel.text = @"";
    self.variantValueLabel.textColor = UIColor_textColor;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self setup];
    }

    return self;
}


@end
