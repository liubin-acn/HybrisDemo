//
// HYTableViewCell.m
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


#import "HYTableViewCell.h"


@implementation HYTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.backgroundColor = UIColor_cellBackgroundColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.backgroundColor = UIColor_cellBackgroundColor;
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
    }
    
    return self;
}

@end
