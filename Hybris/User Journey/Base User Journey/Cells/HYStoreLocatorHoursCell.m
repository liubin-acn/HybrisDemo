//
// HYStoreLocatorHoursCell.m
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


#import "HYStoreLocatorHoursCell.h"


@implementation HYStoreLocatorHoursCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.title.font = UIFont_detailBoldFont;
    self.title.textColor = UIColor_textColor;
    self.openingHours.font = UIFont_detailFont;
    self.openingHours.textColor = UIColor_textColor;
    self.labels.font = UIFont_detailFont;
    self.labels.textColor = UIColor_textColor;
}


@end
