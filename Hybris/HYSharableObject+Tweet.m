//
// HYSharableObject+Tweet.m
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

#import <Twitter/Twitter.h>

@implementation HYSharableObject (Tweet)

- (void)tweetFromViewController:(UIViewController *)vc {
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];

    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:[NSString stringWithFormat:@"%1$@: %2$@ - %3$@",
                                         self.name,
                                         self.link,
                                         self.price]];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    break;
                case TWTweetComposeViewControllerResultDone:
                    break;
                    default:
                    break;
            }

            // Dismiss the tweet composition view controller.
            [vc dismissModalViewControllerAnimated:YES];
        }];

    [vc presentModalViewController:tweetViewController animated:YES];
}

@end
