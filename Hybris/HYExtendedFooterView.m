//
// HYExtendedFooterView.m
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

@implementation HYExtendedFooterView

@synthesize textView = _textView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        CGRect textFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        _textView = [[HYTextView alloc] initWithFrame:textFrame];
        _textView.textAlignment = UITextAlignmentLeft;
        _textView.textColor = UIColor_textColor;
        _textView.font = UIFont_smallFont;
        [self addSubview:_textView];
    }

    return self;
}


@end
