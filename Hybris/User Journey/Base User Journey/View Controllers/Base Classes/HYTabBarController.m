//
// HYTabBarController.m
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

#import "HYTabBarController.h"
//#import "ScanditSDKBarcodePicker.h"


@implementation HYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the tabbar strings   
    [[self.viewControllers objectAtIndex:0] setTitle:NSLocalizedStringWithDefaultValue(@"Shop", nil, [NSBundle mainBundle], @"Shop", @"Home tab title")];
    [[self.viewControllers objectAtIndex:1] setTitle:NSLocalizedStringWithDefaultValue(@"Account", nil, [NSBundle mainBundle], @"Account", @"Account tab title")];;
    [[self.viewControllers objectAtIndex:2] setTitle:NSLocalizedStringWithDefaultValue(@"Scan", nil, [NSBundle mainBundle], @"Scan", @"Scan tab title")];
    [[self.viewControllers objectAtIndex:3] setTitle:NSLocalizedStringWithDefaultValue(@"Stores", nil, [NSBundle mainBundle], @"Stores", @"Store Locator tab title")];
    [[self.viewControllers objectAtIndex:4] setTitle:NSLocalizedStringWithDefaultValue(@"Basket", nil, [NSBundle mainBundle], @"Basket", @"Basket tab title")];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}


@end
