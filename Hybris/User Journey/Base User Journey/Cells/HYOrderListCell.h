//
// HYOrderListCell.h
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
#import "HYTableViewCell.h"


@interface HYOrderListCell : HYTableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *firstLine;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *secondLine;

@property (weak, nonatomic) NSString *orderNumber;
@property (weak, nonatomic) NSString *orderDate;
@property (weak, nonatomic) NSString *orderStatus;

- (void)decorateCellLabels;

@end
