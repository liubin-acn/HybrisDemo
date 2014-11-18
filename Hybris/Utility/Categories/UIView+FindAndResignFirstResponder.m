//
// UIView+FindAndResignFirstResponder.m
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

@implementation UIView (FindAndResignFirstResponder)

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }

    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder]) {
            return YES;
        }
    }

    return NO;
}


@end
