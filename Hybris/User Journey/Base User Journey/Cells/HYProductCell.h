//
// HYProductCell.h
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
#import "HYTableViewCell.h"

@class HYLabel;


@interface HYProductCell : HYTableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView *imageBorder;
@property (nonatomic, strong) IBOutlet HYLabel *nameLabel;
@property (nonatomic, strong) IBOutlet HYLabel *brandLabel;
@property (nonatomic, strong) IBOutlet HYLabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet HYLabel *priceLabel;
@property (nonatomic, strong) IBOutlet HYLabel *stockLevelLabel;

@property (nonatomic) BOOL finalCell;

@end
