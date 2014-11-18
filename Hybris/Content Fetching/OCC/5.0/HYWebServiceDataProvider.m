//
// HYWebServiceDataProvider.m
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

#import "HYWebServiceDataProvider.h"
#import "HYWebServiceAuthProvider.h"

// Private interface
@interface HYWebServiceDataProvider ()
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSDataNSErrorBlock completionDataBlock;
@property (nonatomic, strong) NSMutableURLRequest *currentRequest;
@property (nonatomic, strong) NSMutableURLRequest *savedRequest;
@property (assign) BOOL refreshedOnce;

- (id)initWithRequest:(NSMutableURLRequest *)request allowRefresh:(BOOL)allowRefresh completionBlock:(NSDataNSErrorBlock)completionBlock;
- (id)initWithAuthorizedURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock;
- (id)initWithAuthorizedURL:(NSString *)url clientCredentialsToken:(NSString *)token httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)
   completionBlock;
- (NSURL *)URLByEncodingString:(NSString *)url;
- (float)progress;
- (BOOL)validateResponse:(NSDictionary *)dict;
- (void)reRunRequest;
@end

// Dummy interface to avoid a warning.
@interface NSMutableURLRequest (DummyInterface)
//#warning Do not ship without a signed certificate in place.
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end

@implementation HYWebServiceDataProvider

@synthesize data = _data;
@synthesize connection = _connection;
@synthesize completionDataBlock = _completionDataBlock;
@synthesize currentRequest = _currentRequest;
@synthesize savedRequest = _savedRequest;
@synthesize refreshedOnce = _refreshedOnce;
long expectedContentLength;

#pragma mark - Private method

- (id)initWithRequest:(NSMutableURLRequest *)request allowRefresh:(BOOL)allowRefresh completionBlock:(NSDataNSErrorBlock)completionBlock {
    if (self = [super init]) {
        if (completionBlock) {
            self.completionDataBlock = completionBlock;
        }

        if (!allowRefresh) {
            _refreshedOnce = YES;
        }

        // Save the request
        self.currentRequest = request;

        // Set locale information
        NSString *urlAsString = [request.URL absoluteString];
        NSString *spacer = @"&";

        if ([urlAsString rangeOfString:@"?" options:NSBackwardsSearch].location == NSNotFound) {
            spacer = @"?";
        }

        urlAsString = [NSString stringWithFormat:@"%@%@lang=%@&curr=%@",
            urlAsString,
            spacer,
            [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_language_preference"],
            [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_currency_preference"]];

        request.URL = [NSURL URLWithString:urlAsString];
        logDebug(@"Requesting %@", request.URL);

//        [request setValue:[NSString stringWithFormat:@"%@",
//                           [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_language_preference"]] forHTTPHeaderField:@"Accept-Language"];
//        [request setValue:[NSString stringWithFormat:@"%@",
//                           [[NSUserDefaults standardUserDefaults] valueForKey:@"web_services_currency_preference"]] forHTTPHeaderField:@"Accept-Currency"];

        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //logDebug(@"%@", [request allHTTPHeaderFields]);
//#ifdef DEBUG
        [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[request.URL host]];
//#endif
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        if (_connection) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStartedNotification object:nil];
            _data = [[NSMutableData alloc] init];
        }
        else {
            return nil;
        }
    }

    return self;
}


- (void)reRunRequest {
    self.connection = nil;
    self.data = nil;

    // Update auth
    NSString *token = [HYWebServiceAuthProvider accessToken];

    if (token != nil) {
        NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
        [self.currentRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    }

    _connection = [[NSURLConnection alloc] initWithRequest:self.currentRequest delegate:self];

    if (_connection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStartedNotification object:nil];
        _data = [[NSMutableData alloc] init];
    }
}


#pragma mark - Public methods

- (id)initWithURL:(NSString *)url completionBlock:(NSDataNSErrorBlock)completionBlock {
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:HYConnectionTimeout];

    [request setHTTPMethod:@"GET"];
    return [self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
}


- (id)initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock {
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:HYConnectionTimeout];

    if (httpMethod && ![httpMethod isEmpty] && ([httpMethod isEqualToString:@"PUT"]
            || [httpMethod isEqualToString:@"DELETE"]
            || [httpMethod isEqualToString:@"GET"]
            || [httpMethod isEqualToString:@"POST"])) {
        [request setHTTPMethod:httpMethod];
    }

    if (postData) {
        [request setHTTPBody:postData];
    }

    return [self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
}


- (void)authorizedURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock {
    // Check for expired token
    if ([HYWebServiceAuthProvider tokenExpiredHint]) {
        [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
                // Ignoring the error since there is another chance to refresh later
                (void)[self initWithAuthorizedURL:url httpMethod:httpMethod httpBody:postData completionBlock:completionBlock];
            }];
    }
    else {
        (void)[self initWithAuthorizedURL:url httpMethod:httpMethod httpBody:postData completionBlock:completionBlock];
    }
}

- (void)authorizedURL:(NSString *)url clientCredentialsToken:(NSString *)token httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock
{
    // Check for expired token
    if ([HYWebServiceAuthProvider tokenExpiredHint]) {
        [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
                // Ignoring the error since there is another chance to refresh later
                (void)[self initWithAuthorizedURL:url clientCredentialsToken:token httpBody:postData completionBlock:completionBlock];
            }];
    }
    else {
        (void)[self initWithAuthorizedURL:url clientCredentialsToken:token httpBody:postData completionBlock:completionBlock];
    }
}

- (id)initWithAuthorizedURL:(NSString *)url httpMethod:(NSString *)httpMethod httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)completionBlock {
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:HYConnectionTimeout];

    if (httpMethod && ![httpMethod isEmpty] && ([httpMethod isEqualToString:@"PUT"]
            || [httpMethod isEqualToString:@"DELETE"]
            || [httpMethod isEqualToString:@"GET"]
            || [httpMethod isEqualToString:@"POST"])) {
        [request setHTTPMethod:httpMethod];
    }

    if (postData) {
        [request setHTTPBody:postData];
    }

    NSString *token = [HYWebServiceAuthProvider accessToken];

    if (![token isEmpty]) {
        NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }

    return [self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
}


- (id)initWithAuthorizedURL:(NSString *)url clientCredentialsToken:(NSString *)token httpBody:(NSData *)postData completionBlock:(NSDataNSErrorBlock)
   completionBlock {
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:HYConnectionTimeout];

    [request setHTTPMethod:@"POST"];

    if (postData) {
        [request setHTTPBody:postData];
    }

    if (token) {
        NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }

    return [self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
}


- (void)loginWithUsername:(NSString *)userName password:(NSString *)password completionBlock:(NSDataNSErrorBlock)completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"grant_type=password&username=%@&password=%@", userName, password];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    NSString *authStr = [NSString stringWithFormat:@"%@:%@", HYAuthClientID, HYAuthClientSecret];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];

    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithWrapWidth:80]];

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:[HYWebServiceAuthProvider tokenURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData
        timeoutInterval:HYConnectionTimeout];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    (void)[self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
}


- (void)logoutWithCompletionBlock:(NSDataNSErrorBlock)completionBlock {
    NSVoidBlock logoutBlock = ^{
        NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:[self URLByEncodingString:[HYWebServiceAuthProvider logoutURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData
            timeoutInterval:HYConnectionTimeout];

        [request setHTTPMethod:@"POST"];

        NSString *token = [HYWebServiceAuthProvider accessToken];

        if (![token isEmpty]) {
            NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
            [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        }

        (void)[self initWithRequest:request allowRefresh:YES completionBlock:completionBlock];
    };

    // Check for expired token
    if ([HYWebServiceAuthProvider tokenExpiredHint]) {
        [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
                // Ignoring the error since there is another chance to refresh later
                logoutBlock ();
            }];
    }
    else {
        logoutBlock ();
    }
}

#pragma mark - Helper methods

- (NSURL *)URLByEncodingString:(NSString *)url {
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


- (float)progress {
    return (float)self.data.length / (float)expectedContentLength;
}


- (BOOL)validateResponse:(NSDictionary *)dict {
    if ([[dict objectForKey:@"error"] isEqualToString:@"invalid_token"]) {
        return NO;
    }
    else {
        return YES;
    }
}


- (void)debug:(NSData *)data {
    NSString *newStr = [[NSString alloc] initWithData:data
        encoding:NSUTF8StringEncoding];

    logInfo(@"%@", newStr);
}


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    //logDebug(@"%@", [response allHeaderFields]);
    self.data.length = 0;
    expectedContentLength = 0;
    expectedContentLength = [response expectedContentLength];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
    [HYWebService shared].progress = [self progress];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    logError(@"%@", [error description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStoppedNotification object:nil];

    if (_completionDataBlock) {
        dispatch_async(dispatch_queue_create("com.hybris.parseData", NULL), ^{ _completionDataBlock (nil, error);
            });
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    logDebug(@"Data load complete.");
    [[NSNotificationCenter defaultCenter] postNotificationName:HYConnectionStoppedNotification object:nil];

    if (_completionDataBlock) {
        if (self.data && self.data.length) {
            // Check for JSON parsing errors
            NSError *jsonError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableContainers error:&jsonError];

            if (jsonError) {
                [self debug:self.data];
                dispatch_async(dispatch_queue_create("com.hybris.parseData", NULL), ^{ _completionDataBlock (nil, jsonError);
                    });
                return;
            }

            // Check for invalid token
            if ([self validateResponse:dict]) {
                dispatch_async(dispatch_queue_create("com.hybris.parseData", NULL), ^{ _completionDataBlock (self.data, nil);
                    });
            }
            else {
                // If we've already tried to refresh, return an error
                if (self.refreshedOnce) {
                    dispatch_async(dispatch_queue_create("com.hybris.parseData", NULL), ^{ _completionDataBlock (nil,
                                [NSError errorWithDomain:@"com.hybris" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Refresh Token Failed" forKey:
                                        @"reason"]]);
                        });
                }
                else {
                    // Refresh the access token and re-run the request
                    self.refreshedOnce = YES;
                    [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
                            if (error == nil) {
                                [self reRunRequest];
                            }
                            else {
                                dispatch_async (dispatch_queue_create ("com.hybris.parseData", NULL), ^{ _completionDataBlock (nil, error);
                                    });
                            }
                        }];
                }
            }
        }
        // No data
        else {
            dispatch_async (dispatch_queue_create ("com.hybris.parseData", NULL), ^{ _completionDataBlock (nil, nil);
                });
        }
    }
}

@end
