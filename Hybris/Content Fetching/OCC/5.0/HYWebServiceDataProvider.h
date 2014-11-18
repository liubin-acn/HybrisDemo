//
// HYWebServiceDataProvider.h
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
 *  Helper class that provides asynchronous access to remote data.
 *
 *  This class does not need to be public for users of the SDK.
 */

@interface HYWebServiceDataProvider:NSObject

// Default HTTP GET request
- (id)initWithURL:(NSString *)url completionBlock:(NSDataNSErrorBlock)completionBlock;

// For HTTP requests without authorization.
- (id)initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock;

// For Authorization header requests
- (void)authorizedURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock;
- (void)authorizedURL:(NSString *)url clientCredentialsToken:(NSString *)token httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock;

// For logging in and out
- (void)loginWithUsername:(NSString *)userName password:(NSString *)password completionBlock:(NSDataNSErrorBlock)completionBlock;
- (void)logoutWithCompletionBlock:(NSDataNSErrorBlock)completionBlock;

@end
