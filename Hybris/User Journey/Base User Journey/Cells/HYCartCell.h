//
// HYCartCell.h
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


#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "HYPickerControl.h"
#import "HYTableViewCell.h"


@interface HYCartCell : HYTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageBorder;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet HYLabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet HYLabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet HYLabel *itemQuantityLabel;
@property (weak, nonatomic) IBOutlet HYLabel *productBrandLabel;
@property (weak, nonatomic) IBOutlet HYLabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeQuantityButton;
@property (weak, nonatomic) IBOutlet HYLabel *quantityDescriptionLabel;

@end
