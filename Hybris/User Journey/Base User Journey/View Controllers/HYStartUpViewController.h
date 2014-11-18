//
// HYStartUpViewController.h
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

#import <UIKit/UIKit.h>


/**
 *  A view controller to use as a splash screen while the app initialises.
 */

@interface HYStartUpViewController:UIViewController

/// Activity indicator
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
