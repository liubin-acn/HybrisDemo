//
// HYTextView.m
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

@implementation HYTextView

- (void)setup {
    self.textColor = UIColor_textColor;
    self.font = UIFont_bodyFont;
    self.editable = NO;

    // Remove horizontal padding
    UIEdgeInsets edgeInsets = self.contentInset;
    edgeInsets.left = -8.0;
    edgeInsets.right = -8.0;
    self.contentInset = edgeInsets;
}


- (void)awakeFromNib {
    [self setup];
}


- (HYTextView *)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


@end
