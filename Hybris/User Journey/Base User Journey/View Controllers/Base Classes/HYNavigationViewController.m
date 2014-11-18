//
// HYNavigationViewController.m
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

@interface HYNavigationViewController ()


/**
 *  Perform any additional setup for the view controller, after being created
 *  programatically or from a nib/storyboard.
 */
- (void)setup;
@end

@implementation HYNavigationViewController

#pragma mark - Custom Methods

- (void)setup {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationBar.tintColor = UIColor_standardTint;
        self.toolbar.tintColor = UIColor_standardTint;
    }
}


#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
