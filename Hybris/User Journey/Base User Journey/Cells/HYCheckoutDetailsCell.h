//
// HYCheckoutDetailsCell.h
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
#import "HYBasicCell.h"

@interface HYCheckoutDetailsCell : HYBasicCell

@property (nonatomic, weak) IBOutlet HYLabel *boldTextlabel;
@property (nonatomic, weak) IBOutlet HYLabel *normalTextlabel;
@property (nonatomic, weak) IBOutlet UIImageView *image;

- (void)decorateCellLabelWithContentsAndBoldTitle:(id)contents;

@end
