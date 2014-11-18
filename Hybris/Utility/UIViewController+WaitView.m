//
// UIViewController+WaitView.m
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

@implementation UIViewController (WaitView)

- (HYWaitView *)waitViewShow:(BOOL)show {
    HYWaitView *waitView = nil;

    if ([self isKindOfClass:[UIViewController class]]) {
        waitView = (HYWaitView *)[((UIViewController *)self).view viewWithTag:9999];
    }

    if (!waitView) {
        waitView = (HYWaitView *)[[[NSBundle mainBundle] loadNibNamed:@"HYWaitView" owner:nil options:nil] objectAtIndex:0];

        if ([self isKindOfClass:[UIViewController class]]) {
            [((UIViewController *)self).view addSubview:waitView];
        }
        float height = [UIScreen mainScreen].bounds.size.height;
        CGRectSetHeight(waitView.frame, height);
//
//
//        [waitView.dismissButton addBlock:^(void)
//         {
//             [self waitViewDismissed:waitView];
//         } forControlEvents:UIControlEventTouchUpInside];
    }

    waitView.tag = 9999;
    waitView.messageLabel.text = @"Loading...";

    waitView.messageLabel.hidden = YES;
    waitView.activityIndicator.hidden = YES;

    [waitView performBlock:^{
            waitView.messageLabel.hidden = NO;
            waitView.activityIndicator.hidden = NO;
        } afterDelay:2];

    if (show) {
//        if (dismissText == nil)
//        {
//            waitView.dismissButton.hidden = TRUE;
//        }
//        else
//        {
//            waitView.dismissButton.hidden = FALSE;
//            [waitView.dismissButton setTitle:dismissText forState:UIControlStateNormal];
//        }

        waitView.alpha = 0;
    }

    [UIView animateWithDuration:0.2 animations:^(void)
        {
            waitView.alpha = show ? 1:0;
        } completion:^(BOOL finished)
        {
            if (!show) {
                [waitView removeFromSuperview];
            }
        }];

    return waitView;
}

@end
