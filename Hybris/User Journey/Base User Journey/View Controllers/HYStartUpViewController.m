//
// HYStartUpViewController.m
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

#import "HYStartUpViewController.h"

@implementation HYStartUpViewController

#pragma mark - Notification Changes
@synthesize activityIndicator;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"categoriesReady"]) {
        if ([HYAppDelegate sharedDelegate].categoriesReady) {
            logInfo(@"Categories Ready. Loading view.");

            // UI Setup
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"startupSegue" sender:self];
        }
        else {
            logInfo(@"Categories not ready yet.");
        }
    }
}


#pragma mark - Helper Methods
- (void)removeObservers {
    [[HYAppDelegate sharedDelegate] removeObserver:self forKeyPath:@"categoriesReady"];
}


- (void)addObservers {
    [[HYAppDelegate sharedDelegate] addObserver:self forKeyPath:@"categoriesReady" options:NSKeyValueObservingOptionNew context:NULL];
}


#pragma mark - View Lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([HYAppDelegate sharedDelegate].categoriesReady) {
        logInfo(@"Categories Ready. Loading view.");

        // UI Setup
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

        [self.activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"startupSegue" sender:self];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [self removeObservers];
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}


@end
