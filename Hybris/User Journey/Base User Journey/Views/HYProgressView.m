//
// HYProgressView.m
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

@implementation HYProgressView

- (void)setup {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    self.trackTintColor = UIColor_trackTintColor;
    self.progressTintColor = UIColor_progressTintColor;
    }
}


- (void)awakeFromNib {
    [self setup];
}


- (id)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)setProgress:(float)progress {
    [super setProgress:progress];

    if (progress == 1.0) {
        [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.hidden = YES;
            }
        ];
    }
    else {
        self.hidden = NO;
        self.alpha = 1.0;
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    [super setProgress:progress animated:animated];

    if (progress == 1.0) {
        [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.hidden = YES;
            }
        ];
    }
    else {
        self.hidden = NO;
        self.alpha = 1.0;
    }
}

@end
