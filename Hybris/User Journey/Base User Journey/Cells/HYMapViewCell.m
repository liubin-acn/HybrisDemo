//
// HYMapViewCell.m
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


#import "HYMapViewCell.h"


@implementation HYMapViewCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.mapButton setTitle:NSLocalizedStringWithDefaultValue(@"Open Map", nil, [NSBundle mainBundle], @"Open Map", @"Title of map button") forState:UIControlStateNormal];
    
    [self.directionsButton setTitle:NSLocalizedStringWithDefaultValue(@"Get Directions", nil, [NSBundle mainBundle], @"Get Directions", @"Title of directions button") forState:UIControlStateNormal];
    
    self.mapButton.backgroundColor = UIColor_backgroundColor;
    self.directionsButton.backgroundColor = UIColor_backgroundColor;

}

@end
