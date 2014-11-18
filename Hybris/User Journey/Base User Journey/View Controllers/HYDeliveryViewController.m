//
// HYDeliveryViewController.m
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


#import "HYDeliveryViewController.h"


@implementation HYDeliveryViewController

- (NSString *)displayString {
    return self.descriptionView.text;
}


- (void)setDisplayString:(NSString *)displayString {
    self.descriptionView.text = displayString;
    self.scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, self.descriptionView.contentSize.height);
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setDescriptionView:nil];
    [super viewDidUnload];
}


@end
