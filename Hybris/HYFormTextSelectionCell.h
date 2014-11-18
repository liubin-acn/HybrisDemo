//
// HYFormTextSelectionCell.h
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


@interface HYFormTextSelectionCell : HYTableViewCell

@property (nonatomic, weak) IBOutlet HYLabel *titleLabel;
@property (nonatomic, weak) IBOutlet HYLabel *currentSelectionLabel;

@property (nonatomic, strong) NSArray *values;

@end
