//
// HYProductAddCell.m
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


#import "HYProductAddCell.h"


@implementation HYProductAddCell

@synthesize addButton;

- (void)setup {    
    self.textLabel.font = UIFont_buttonFont;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
    
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"add-to-cart_disabled@2x.png"] forState:UIControlStateDisabled];
    [self.addButton setTitleColor:UIColorMake(0, 0, 0) forState:UIControlStateDisabled];
    
    [self.addButton setTitle:NSLocalizedString(@"Add to cart", @"Title of the button to add a product to the cart") forState:UIControlStateNormal];
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
