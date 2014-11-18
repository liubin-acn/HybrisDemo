//
// HYWebServiceAuthProvider.h
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

#import <Foundation/Foundation.h>


/**
 *  Helper class that encapsulates the access_token refreshing and provides other
 *  auth information.
 *
 *  This class does not need to be public for users of the SDK.
 */

@interface HYWebServiceAuthProvider:NSObject


/**
 *  Request a new refresh token based on the current tokens stored in NSUserDefaults
 */
+ (void)refreshAccessTokenWithCompletionBlock:(NSErrorBlock)completionBlock;

#pragma mark - Class Helper Methods


/**
 *  Returns the current access token
 */
+ (NSString *)accessToken;


/**
 *  Returns the current refresh token
 */
+ (NSString *)refreshToken;


/**
 *  Check the preferences to see if the user is allowing automatic token refresh
 */
+ (BOOL)shouldRefreshToken;


/**
 *  Return the URL for getting a new token access
 */
+ (NSString *)tokenURL;


/**
 *  Return the URL for logging out
 */
+ (NSString *)logoutURL;


/**
 *  Checks the length of time since the access token was issued against its validity time.
 *  The value is not guarunteed to be correct since it is worked out client-side.
 */
+ (BOOL)tokenExpiredHint;


/**
 *  Stores the new auth information
 */
+ (void)saveTokensWithDictionary:(NSDictionary *)dict;


/**
 *  Clear the suth information
 */
+ (void)clearAuthInformation;

@end
