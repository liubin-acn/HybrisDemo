//
// HYWebServiceAuthProvider.m
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

#import "HYWebServiceAuthProvider.h"

@interface HYWebServiceAuthProvider ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSErrorBlock completionDataBlock;
- (id)initWithCompletionBlock:(NSErrorBlock)completionBlock;
- (NSString *)callbackURL;
- (NSURL *)URLByEncodingString:(NSString *)url;
@end

// Dummy interface to avoid a warning.
@interface NSMutableURLRequest (DummyInterface)
//#warning Do not ship without a signed certificate in place.
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end

@implementation HYWebServiceAuthProvider

@synthesize connection = _connection;
@synthesize data = _data;
@synthesize completionDataBlock = _completionDataBlock;

#pragma mark - Class Helper Methods

+ (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"];
}


+ (NSString *)refreshToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"refresh_token"];
}


+ (BOOL)shouldRefreshToken {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"keep_me_logged_in"] boolValue];
}


+ (NSString *)tokenURL {
    return [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"], @"/rest/oauth/token"];
}


+ (NSString *)logoutURL {
    return [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"],
        @"/rest/v1/customers/current/logout"];
}


+ (BOOL)tokenExpiredHint {
    NSTimeInterval interval = -[[[NSUserDefaults standardUserDefaults] objectForKey:@"issued_on"] timeIntervalSinceNow];

    return interval > [[[NSUserDefaults standardUserDefaults] valueForKey:@"expires_in"] integerValue];
}


#pragma mark Private Helper Methods

- (NSString *)callbackURL {
    return [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"], @"/oauth2_callback"];
}


- (NSURL *)URLByEncodingString:(NSString *)url {
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


+ (void)saveTokensWithDictionary:(NSDictionary *)dict {
    [[NSUserDefaults standardUserDefaults] setValue:[dict objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setValue:[dict objectForKey:@"refresh_token"] forKey:@"refresh_token"];
    [[NSUserDefaults standardUserDefaults] setValue:[dict objectForKey:@"expires_in"] forKey:@"expires_in"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"issued_on"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)clearAuthInformation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:@"access_token"];
    [defaults removeObjectForKey:@"refresh_token"];
    [defaults removeObjectForKey:@"expires_in"];
    [defaults removeObjectForKey:@"issued_on"];
    [defaults synchronize];

    // Clear cookies
    for (NSHTTPCookie *cookie in[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}


#pragma mark - Public Accessor

+ (void)refreshAccessTokenWithCompletionBlock:(NSErrorBlock)completionBlock {
    (void)[[HYWebServiceAuthProvider alloc] initWithCompletionBlock:completionBlock];
}


#pragma mark - Designated Initializer (private)

- (id)initWithCompletionBlock:(NSErrorBlock)completionBlock {
    if (self = [super init]) {
        self.completionDataBlock = completionBlock;

        logDebug(@"Refreshing token");
        NSString *authStr = [NSString stringWithFormat:@"refresh_token=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=refresh_token",
            [HYWebServiceAuthProvider refreshToken],
            HYAuthClientID,
            HYAuthClientSecret,
            [self callbackURL]];
        NSData *postData = [NSData dataWithBytes:[authStr UTF8String] length:[authStr length]];
        NSURL *url = [self URLByEncodingString:[HYWebServiceAuthProvider tokenURL]];

        NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:HYConnectionTimeout];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];

        // Set locale information
        [request setValue:[NSString stringWithFormat:@"%@",
                [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_language_preference"]] forHTTPHeaderField:@"Accept-Language"];
        [request setValue:[NSString stringWithFormat:@"%@",
                [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_currency_preference"]] forHTTPHeaderField:@"Accept-Currency"];

        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

//#ifdef DEBUG
        [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[request.URL host]];
//#endif
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        if (_connection) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStartedNotification object:nil];
            _data = [[NSMutableData alloc] init];
        }
        else {
            if (completionBlock) {
                completionBlock([NSError errorWithDomain:@"com.hybris" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Could not make connection" forKey:
                            @"reason"]]);
            }
        }
    }

    return self;
}


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.data.length = 0;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    logError(@"%@", [error description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStoppedNotification object:nil];

    if (_completionDataBlock) {
        _completionDataBlock(error);
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    logDebug(@"Data load complete.");
    [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStoppedNotification object:nil];

    NSError *jsonError;
    NSDictionary *dict =
        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableContainers error:&jsonError]];

    if (jsonError) {
        if (_completionDataBlock) {
            _completionDataBlock(jsonError);
        }

        return;
    }

    BOOL success = [dict objectForKey:@"access_token"] ? YES : NO;
    [HYWebServiceAuthProvider saveTokensWithDictionary:dict];

    if (_completionDataBlock) {
        if (success) {
            _completionDataBlock(nil);
        }
        else {
            _completionDataBlock([NSError errorWithDomain:@"com.hybris" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Refresh Token Failed" forKey:
                        @"reason"]]);
        }
    }
}


@end
