//
// HYAppDelegate.m
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

#import "HYCategoryManager.h"
#import "HYProductDetailViewController.h"
#import "HYOrderDetailViewController.h"
#import "HYStoreSearchViewController.h"
#import <HockeySDK/HockeySDK.h>


@interface HYAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>


/**
 *  Register an object for network activity notifications.
 *  The object being registered should make use of calls to HYConnectionStartedNotification and HYConnectionStoppedNotification.
 *  This method can safely be called more than once.
 *  @param object The objectto register.
 */
- (void)registerNetworkActivityIndicatorForObject:(id)object;


/**
 *  Unregister an object for network activity notifications.
 *  This method can safely be called more than once.
 *  @param object The object to unregister.
 */
- (void)unregisterNetworkActivityIndicatorForObject:(id)object;


/**
 *  Load the defaults from NSUserDefaults.
 *
 *  This method uses the default settings from the Settings bundle. It is in this bundle you should set the default
 *  behaviour of an app.
 */
- (void)loadApplicationDefaults;


/**
 *  Load the system settings form the config dictionary settings.plist.
 *
 *  This is used for settings not appropriate for NSUserDefaults
 */
- (void)loadSystemSettings;


/**
 *  Load the webservice url from NSUserDefaults.
 *
 *  This method uses the default settings from the Settings bundle and sets the webservice url to use according to the settings
 */
- (void)loadWebserviceUrl;

#ifndef DEBUG
/**
 * Uncaught exception handler
 */
static void uncaughtExceptionHandler(NSException *exception);
#endif

/**
 * Facebook handler
 */
- (void)sessionStateChanged:(FBSession *)session
   state                   :(FBSessionState)state
   error                   :(NSError *)error;


/**
 * Facebook block
 */
@property (nonatomic, strong) NSVoidBlock facebookCompletionBlock;

/**
 * name of the site (catalog) which the product data is loaded from
 */
@property (nonatomic, strong) NSString *site;

@end

@implementation HYAppDelegate


#pragma mark - Custom getters and setters

- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:[NSNumber numberWithBool:isLoggedIn] forKey:@"user_logged_in"];
    [userDefaults synchronize];
}


- (BOOL)isLoggedIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults valueForKey:@"user_logged_in"] boolValue];
}


- (void)setUsername:(NSString *)username {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![username isEmpty]) {
        [userDefaults setValue:username forKey:@"logged_in_username"];
        [userDefaults synchronize];
    }
}


- (NSString *)username {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults valueForKey:@"logged_in_username"];
}



#pragma mark - Preset App

- (void)resetCategories {
    [self loadWebserviceUrl];
    
    NSString *site = [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"];
    
    // reset
    if (![self.site isEqualToString:site]) {
        if (self.site != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HYSiteChangedNotification object:nil];
        }
        
        self.site = site;
        
        if ([[site substringFromIndex:[site length] - 1] isEqualToString:@"/"]) {
            site = [site substringToIndex:[site length] - 1];
        }
        
        NSString *plistFileName = [NSString stringWithFormat:@"categories.%@", site];
        NSURL *pathToCategoriesPlist = [[self applicationPrivateDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plistFileName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[pathToCategoriesPlist filePathURL] path]]) {
            NSError *error;
            
            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"]
                                                    toPath:[[pathToCategoriesPlist filePathURL] path] error:&error];
        }
        
        NSURL *url = [NSURL fileURLWithPath:[[pathToCategoriesPlist filePathURL] path]];
        
        [HYCategoryManager reloadCategoriesFromPlist:url];
    }
    self.categoriesReady = YES;
}


- (void)loadApplicationDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultsDictionary =
    [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"] stringByAppendingPathComponent:
                                                @"Root.plist"]];
    NSArray *preferences = [defaultsDictionary objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        
        if (key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [userDefaults setValue:@"1" forKey:@"keep_me_logged_in"]; //for refreshing tokens
    [userDefaults registerDefaults:defaultsToRegister];
    [userDefaults synchronize];
}


- (void)loadSystemSettings {
    NSURL *pathToSettingsPlist = [[self applicationPrivateDocumentsDirectory] URLByAppendingPathComponent:@"settings.plist"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[pathToSettingsPlist filePathURL] path]]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]
                                                toPath:[[pathToSettingsPlist filePathURL] path] error:&error];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:[[pathToSettingsPlist filePathURL] path] error:&error];
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]
                                                toPath:[[pathToSettingsPlist filePathURL] path] error:&error];
    }
    
    NSURL *url = [NSURL fileURLWithPath:[[pathToSettingsPlist filePathURL] path]];
    self.configDictionary = [PListSerialisation dataFromPlistAtPath:url];
}


- (void)loadWebserviceUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"web_services_use_specific_base_url_preference"] && [[userDefaults stringForKey:@"web_services_specific_base_url_preference"] length] > 0) {
        [userDefaults setValue:[userDefaults stringForKey:@"web_services_specific_base_url_preference"] forKey:@"web_services_base_url_preference"];
    } else {
        [userDefaults setValue:[userDefaults stringForKey:@"web_services_predefined_base_url_preference"] forKey:@"web_services_base_url_preference"];
    }
    
    [userDefaults synchronize];
}



#pragma mark - Application life cycle

// TODO get code for init an app
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
    
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"BETA_IDENTIFIER"
                                                         liveIdentifier:nil
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // Load the app's defaults
    [self loadApplicationDefaults];
    
    // Additional User level settings
    [self loadSystemSettings];
    
    // Set the locale info - this will get overrriden if the user logs in
    //    NSString *language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    //    [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"web_services_language_preference"];
    
    // This causes a problem with OCC as currency codes to not match up
    //    NSString *currency = [[NSLocale currentLocale] objectForKey: NSLocaleCurrencyCode];
    //    [[NSUserDefaults standardUserDefaults] setValue:currency forKey:@"web_services_currency_preference"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Link the content fetcher to the network activity indicator
    [self registerNetworkActivityIndicatorForObject:[HYWebService shared]];
    
    // This sets up the default Facets
    [self resetCategories];
    
    // UI Setup
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.window setTintColor:UIColor_appTint];
    }
    
    // Tab bar
    UIImage *tabBarBackground = [[UIImage imageNamed:@"tabBarBackground.png"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[UITabBar appearance] setSelectedImageTintColor:UIColor_highlightTint];
        [[UITabBar appearance] setTintColor:UIColor_tabTint];
    }
    
    // Navigation bar
    UIImage *navigationBarBackground = [[UIImage imageNamed:@"navigationBar.png"]
                                        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Navigation bar buttons
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:39.0/255.0 green:53.0/255.0 blue:70.0/255.0 alpha:1.0]];
    }
        
    // Search bar
    UIImage *searchBackground = [[UIImage imageNamed:@"searchbar-background.png"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UISearchBar appearance] setBackgroundImage:searchBackground];
    
    // Reachability
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.reachableOnWWAN = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reachability startNotifier];
    
    return YES;
}

- (void)reachabilityChanged:(NSNotification*)notification {
    Reachability * reachability = [notification object];
    
    if([reachability isReachable]) {
        logInfo(@"Reachable");
    }
    else {
        logInfo(@"Not Reachable");
    }
    
    if ([[self visibleViewController] respondsToSelector:@selector(reachabilityChanged:)]) {
        [[self visibleViewController] performSelector:@selector(reachabilityChanged:) withObject:reachability];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self unregisterNetworkActivityIndicatorForObject:[HYWebService shared]];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self registerNetworkActivityIndicatorForObject:[HYWebService shared]];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
    // optionally refresh the user interface.
    
    // Clean up aborted facebook connections
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession close];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self resetCategories];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [self unregisterNetworkActivityIndicatorForObject:[HYWebService shared]];
    [FBSession.activeSession close];
}


#pragma mark - Helper Methods

#ifndef DEBUG
static void uncaughtExceptionHandler(NSException *exception) {
    logError(@"App crashed for exception: %@/ %@", exception, [exception callStackSymbols]);
    
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Application Problem", @"Crash alert title")
                                                        message:NSLocalizedString(
                                                                                  @"Sorry we have to close the app because an unknown error has occurred. We have logged this error and if this happens frequently you should look out for an app update.",
                                                                                  @"Friendly crash alert copy")
                                                       delegate:[[UIApplication sharedApplication] delegate] cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK button"), nil];
        [alert show];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
}
#endif


- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSURL *)applicationPrivateDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    libraryDirectory = [libraryDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:libraryDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:libraryDirectory
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSURL fileURLWithPath:libraryDirectory isDirectory:YES];
}


/// Responsible for returning the visible view controller
- (UIViewController *)visibleViewController {
    UIViewController *vc = self.window.rootViewController;
    
    while (vc.presentedViewController != nil) {
        if ([vc respondsToSelector:@selector(presentedViewController)]) {
            vc = ((UINavigationController *)vc).presentedViewController;
        }
        
        if ([vc respondsToSelector:@selector(selectedViewController)]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }
        
        if ([vc respondsToSelector:@selector(visibleViewController)]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }
    }
    
    return vc;
}


- (void)registerNetworkActivityIndicatorForObject:(id)object {
    id activityIndicator = [SDNetworkActivityIndicator sharedActivityIndicator];
    
    // Remove observer in case it was previously added
    [self unregisterNetworkActivityIndicatorForObject:object];
    
    [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                             selector:@selector(startActivity)
                                                 name:HYConnectionStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                             selector:@selector(stopActivity)
                                                 name:HYConnectionStoppedNotification object:nil];
}


- (void)unregisterNetworkActivityIndicatorForObject:(id)object {
    id activityIndicator = [SDNetworkActivityIndicator sharedActivityIndicator];
    
    [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:HYConnectionStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:HYConnectionStoppedNotification object:nil];
}


+ (HYAppDelegate *)sharedDelegate {
    return (HYAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)alertWithError:(NSError *)error {
    NSString *errorMsg;
    
    if ([error.userInfo objectForKey:@"message"]) {
        errorMsg = [error.userInfo objectForKey:@"message"];
    }
    else if ([error.userInfo objectForKey:@"detailMessage"]) {
        errorMsg = [error.userInfo objectForKey:@"detailMessage"];
    }
    else {
        errorMsg = error.localizedDescription;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert box title") message:errorMsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Facebook Delegate Methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
        default: {
        }
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"ErrorMessage", @"Error alert title")
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    if (state == FBSessionStateOpen && self.facebookCompletionBlock) {
        _facebookCompletionBlock();
        self.facebookCompletionBlock = nil;
    }
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI completionBlock:(NSVoidBlock)completionBlock {
    self.facebookCompletionBlock = completionBlock;
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish_stream",
                            nil];
    return [FBSession openActiveSessionWithPublishPermissions:permissions
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                                 allowLoginUI:allowLoginUI
                                            completionHandler:^(FBSession *session,
                                                                FBSessionState state,
                                                                NSError *error) {
                                                [self sessionStateChanged:session
                                                                    state:state
                                                                    error:error];
                                            }];
}

// Required where SSO is not available
- (BOOL) application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation {    
    return [FBSession.activeSession handleOpenURL:url];
}



#pragma mark - HockeyApp delegate methods

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    return nil;
}


@end
