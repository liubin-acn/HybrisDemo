//
// HYAppDelegate.h
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

@class HYManagedDocument;

@interface HYAppDelegate:UIResponder<UIApplicationDelegate>

/// App's main window
@property (strong, nonatomic) UIWindow *window;

/**
 *  Set to YES when the default categories have been read in and created in the document
 */
@property (nonatomic) BOOL categoriesReady;


/**
 *  System settings loaded from the settings.plist
 *
 *  This is used for system level settings that are not in NSUserDefaults.
 */
@property (nonatomic, strong) NSDictionary *configDictionary;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) BOOL isLoggedIn;

/// Custom shared delegate
+ (HYAppDelegate *)sharedDelegate;

/// Standard documents directory
- (NSURL *)applicationDocumentsDirectory;

/// Private documents directory (hidden from the user in iCloud, etc).
- (NSURL *)applicationPrivateDocumentsDirectory;

/// Visible non-navigation view controller
- (UIViewController *)visibleViewController;

/// Facebook callback
- (BOOL)openSessionWithAllowLoginUI:(BOOL) allowLoginUI completionBlock:(NSVoidBlock)completionBlock;

- (void)alertWithError:(NSError *)error;

/// resets the fixed categories from plist
- (void)resetCategories;

@end
