//
// HYProductClassificationView.m
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

#import "HYProductClassificationView.h"

@implementation HYProductClassificationView
@synthesize titleLabel;

- (void)setup {
    self.titleLabel.font = UIFont_defaultFont;
}


- (void)awakeFromNib {
    [self setup];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setup];
    }

    return self;
}


/*
 *  // Only override drawRect: if you perform custom drawing.
 *  // An empty implementation adversely affects performance during animation.
 *  - (void)drawRect:(CGRect)rect
 *  {
 *   // Drawing code
 *  }
 */

@end
