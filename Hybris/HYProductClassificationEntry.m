//
// HYProductClassificationEntry.m
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

#import "HYProductClassificationEntry.h"

@implementation HYProductClassificationEntry
@synthesize leftLabel;
@synthesize rightLabel;

- (void)setup {
    self.leftLabel.font = UIFont_smallFont;
    self.leftLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.rightLabel.font = UIFont_smallFont;
    self.rightLabel.lineBreakMode = UILineBreakModeWordWrap;
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
