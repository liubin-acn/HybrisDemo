//
// HYFooterView.m
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

@implementation HYFooterView

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        CGRect labelFrame = CGRectMake(20.0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        _label = [[HYLabel alloc] initWithFrame:labelFrame];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColor_inverseTextColor;
        [self addSubview:_label];
        self.backgroundColor = UIColor_standardTint;
    }

    return self;
}


@end
