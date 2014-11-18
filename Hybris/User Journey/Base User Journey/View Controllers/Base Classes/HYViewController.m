//
// HYViewController.m
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

#import "HYViewController.h"


@interface HYViewController ()

@property (nonatomic, strong) HYFooterView *offlineView;

/// Reachablity Callback
- (void)reachabilityChanged:(Reachability *)reachability;

/**
 *  Add gesture for admin settings view.
 */
- (void)addSettingsGesture;

@end


@implementation HYViewController

- (void)setShowPlainBackButton:(BOOL)show {
    if (show) {
        self.navigationItem.backBarButtonItem = UIBarButtonPlain(NSLocalizedString(@"Back", nil), nil);
    }
}



#pragma mark - Custom Methods

- (void)setup {
    [self addSettingsGesture];

    // Offline view
    if (self.offlineView == nil) {
        self.offlineView = [[ViewFactory shared] make:[HYFooterView class] withFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
        self.offlineView.label.text = NSLocalizedStringWithDefaultValue(@"Offline", nil, [NSBundle mainBundle], @"Offline", @"Offline message");
        [self.view addSubview:self.offlineView];
    }

    for (id view in self.view.subviews) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            if ([view respondsToSelector:@selector(setTintColor:)]) {
                [view setTintColor:UIColor_standardTint];
            }
        }
    }
}


- (void)reachabilityChanged:(Reachability *)reachability {
    dispatch_async (dispatch_get_main_queue(), ^{
        if ([reachability isReachable]) {
            self.offlineView.hidden = YES;
        }
        else {
            self.offlineView.hidden = NO;
        }
    });
}



#pragma mark - Custom Getters and Setters

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;

    if (!titleView) {
        titleView = [[ViewFactory shared] make:[HYLabel class]];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.font = UIFont_navigationBarFont;
        titleView.textColor = UIColor_inverseTextColor;
        self.navigationItem.titleView = titleView;
        self.navigationItem.titleView.hidden = YES;
    }

    titleView.text = title;
    [titleView sizeToFit];
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.reachableOnWWAN = NO;
    self.offlineView.hidden = [reachability isReachable];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.titleView.hidden = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



#pragma mark - Settings Gesture Recognizer

- (void)addSettingsGesture {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];

    swipeGesture.numberOfTouchesRequired = 2;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:swipeGesture];
    
#if (TARGET_IPHONE_SIMULATOR)
    UISwipeGestureRecognizer *singularSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    
    singularSwipeGesture.numberOfTouchesRequired = 1;
    singularSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:singularSwipeGesture];
#endif
}


- (void)swipedScreen:(UISwipeGestureRecognizer *)swipeGesture {
    IASKAppSettingsViewController *settingsVC = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];

    settingsVC.delegate = self;
    [self presentModalViewController:[[HYNavigationViewController alloc] initWithRootViewController:settingsVC] animated:YES];
}



#pragma mark - IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [[HYAppDelegate sharedDelegate] resetCategories];
}


@end
