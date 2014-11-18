//
// HYOCCCustomersTests.m
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
#import "HybrisTests.h"


@interface HYOCCCustomersTests : HybrisTests

@end


@implementation HYOCCCustomersTests


#pragma mark - Helpers

- (NSString *)newUser {
    int r = arc4random() % 10000000;

    return [NSString stringWithFormat:@"firstname%i@lastemail.com", r];
}



#pragma mark Logging In / Out Tests

- (void)test001LogInLogOut {
    __block int done = 0;

    // 1. Register and login
    [self logInAndWait];

    // Get Address
    [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Log out
    [self logOutAndWait];

    // Get Address - Should fail
    [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNotNil (error, @"Error should not be nil");
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


// Your server must have the following set in ycommercewebservices-web-spring.xml
// <property name="accessTokenValiditySeconds" value="2" />
- (void)test002RefreshToken {
    __block int done = 0;

    [self logInAndWait];

    // 1. Wait
    logDebug(@"Waiting...");
    NSDate *future = [NSDate dateWithTimeIntervalSinceNow:5.00];
    [NSThread sleepUntilDate:future];
    logDebug(@"...done.");

    // 2. Get Address (should still work as SDK will refresh token automatically
    [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //////////////////////

    // 3. Call auth provider directly
    [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 4. Set an invalid refresh token
    NSString *invalidToken = @"7fe113fe-f464-4bb7-b2be-a869dd018ff4";
    [[NSUserDefaults standardUserDefaults] setValue:invalidToken forKey:@"refresh_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 5. Call auth provider directly, should error
    [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
            STAssertNotNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 6. Log in again (correcting the stored tokens)
    [self logInAndWait];

    // 7. Call auth provider directly, should work again
    [HYWebServiceAuthProvider refreshAccessTokenWithCompletionBlock:^(NSError* error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}



#pragma mark - Customer tests

- (void)test140RegisterNewCustomer {
    __block int done = 0;

    // 1. Generate random username
    NSString *login = [self newUser];

    // 2.  Register (automatically gets client credentials token)
    [[HYWebService shared] registerCustomerWithFirstName:@"FirstName" lastName:@"LastName" titleCode:@"mr" login:login password:@"test123" completionBlock:^(
            NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    [[HYWebService shared] registerCustomerWithFirstName:@"FirstName" lastName:@"LastName" titleCode:@"mrr" login:login password:@"test123" completionBlock:^(
            NSError *error) {
            STAssertNotNil (error, @"The error should not be nil.");
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


// Test customer address methods
- (void)test150CustomerAddresses {
    __block int done = 0;

    // 1. Generate random username
    NSString *login = [self newUser];

    // 2.  Register (automatically gets client credentials token)
    [[HYWebService shared] registerCustomerWithFirstName:@"FirstName" lastName:@"LastName" titleCode:@"mr" login:login password:@"test123" completionBlock:^(
            NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 3. Log in
    [[HYWebService shared] loginWithUsername:login password:@"test123" completionBlock:^(NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 4. Create an address
    __block NSString *addressID = nil;
    [[HYWebService shared] createCustomerAddressWithFirstName:@"First" lastName:@"Name" titleCode:@"mr" addressLine1:@"line1" addressLine2:@"line2" town:
        @"Town" postCode:@"SE18 1RL" countryISOCode:@"GB" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            STAssertTrue ([[dict objectForKey:@"firstName"] isEqualToString:@"First"], nil);
            addressID = [dict objectForKey:@"id"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 8. Update the first address
    [[HYWebService shared] updateCustomerAddressWithFirstName:@"ChangeFirst" lastName:@"ChangeLast" titleCode:@"mr" addressLine1:@"ChangeLine1" addressLine2:
        @"Change2" town:@"Town2" postCode:@"POSTCODE" countryISOCode:@"GB" addressID:addressID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, nil);
            STAssertTrue ([[dict objectForKey:@"firstName"] isEqualToString:@"ChangeFirst"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 5. Get all addresses
    [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue (array.count, nil);
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 6. Create another address
    __block NSString *addressID2 = nil;
    [[HYWebService shared] createCustomerAddressWithFirstName:@"First" lastName:@"Name" titleCode:@"mr" addressLine1:@"addressA" addressLine2:@"addressB" town:
        @"SomeTown" postCode:@"SE18 1RL" countryISOCode:@"GB" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            STAssertTrue ([[dict objectForKey:@"firstName"] isEqualToString:@"First"], nil);
            addressID2 = [dict objectForKey:@"id"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 7. Delete the second address
    [[HYWebService shared] deleteCustomerAddressWithID:addressID2 completionBlock:^(NSError *error) {
            STAssertNil (error, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 8. Update the first address
    [[HYWebService shared] updateCustomerAddressWithFirstName:@"Change2First" lastName:@"ChangeLast" titleCode:@"mr" addressLine1:@"ChangeLine1" addressLine2:
        @"Change2" town:@"Town2" postCode:@"POSTCODE" countryISOCode:@"GB" addressID:addressID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, nil);
            STAssertTrue ([[dict objectForKey:@"firstName"] isEqualToString:@"Change2First"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 9. Get all addresses
    [[HYWebService shared] customerAddressesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue (array.count, nil);
            STAssertNil (error, [error description]);

            if (array.count) {
                NSDictionary *dictArray = [array objectAtIndex:0];
                addressID = [dictArray objectForKey:@"id"];
                STAssertTrue ([[dictArray objectForKey:@"firstName"] isEqualToString:@"Change2First"], nil);
            }

            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 10. Set the address as default
    [[HYWebService shared] setDefaultCustomerAddressWithID:addressID completionBlock:^(NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test210CustomerProfile {
    __block int done = 0;
    __block NSString *prevFirstName;
    __block NSString *prevLastName;
    __block NSString *firstName = @"UpdatedFirstName";
    __block NSString *lastName = @"UpdatedLastName";

    // Log in
    [self logInAndWait];

    // Get Profile
    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            STAssertFalse ([[dict valueForKey:@"firstName"] isEqualToString:firstName], nil);
            STAssertFalse ([[dict valueForKey:@"lastName"] isEqualToString:lastName], nil);

            prevFirstName = [dict valueForKey:@"firstName"];
            prevLastName = [dict valueForKey:@"lastName"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Update the profile
    [[HYWebService shared] updateCustomerProfileWithFirstName:firstName
        lastName:lastName
        titleCode:@"mr"
        language:@"en"
        currency:@"USD"
        completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Get the profile and check change has been made
    [[HYWebService shared] customerProfileWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertTrue ([[dict valueForKey:@"firstName"] isEqualToString:firstName], nil);
            STAssertTrue ([[dict valueForKey:@"lastName"] isEqualToString:lastName], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Update the profile with wrong title code
    [[HYWebService shared] updateCustomerProfileWithFirstName:firstName
        lastName:lastName
        titleCode:@"LOL"
        language:@"en"
        currency:@"USD"
        completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNotNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Revert the profile
    [[HYWebService shared] updateCustomerProfileWithFirstName:prevLastName lastName:prevLastName titleCode:@"mr" language:@"en" currency:@"GBP" completionBlock
        :^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test220CustomerPassword {
    __block int done = 0;
    
    //1. Login
    [self logInAndWait];

    //2. Update
    [[HYWebService shared] updateCustomerPasswordWithNewPassword:@"newpassword" oldPassword:kPassword completionBlock:^(NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Revert
    [[HYWebService shared] updateCustomerPasswordWithNewPassword:kPassword oldPassword:@"newpassword" completionBlock:^(NSError *error) {
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test230GetCustomerPaymentInfo {
    __block int done = 0;
    
    //1. Login
    [self logInAndWait];

    //2. Get All payment Infos
    [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

- (void)test240GetCustomerPaymentInfoWithID {
    __block int done = 0;
    __block NSString *paymentID;
    
    //1. Login
    [self logInAndWait];
    
    //2. Get a paymentID
    [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue([array count] > 0, @"No payment infomations available");
            paymentID = [[array lastObject] objectForKey:@"id"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Get Info of PaymentID by ID
    [[HYWebService shared] customerPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Delete the payment info
    [[HYWebService shared] deleteCustomerPaymentInfoWithID:paymentID completionBlock:^(NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //4. Get again
    [[HYWebService shared] customerPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            // No error message is returned from the API when you try to get a deleted paymentInfo.
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

- (void)test260UpdateCustomerPaymentInfoWithID {
    __block int done = 0;
    __block NSString *paymentID;
    
    //1. Login
    [self logInAndWait];

    //2. Get a paymentID
    [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertTrue([array count] > 0, @"No payment infomations available");
            paymentID = [[array lastObject] objectForKey:@"id"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Update
    [[HYWebService shared] updateCustomerPaymentInfoWithAccountHolderName:@"UpdateName" cardNumber:@"1234567890129999" cardType:@"visa" expiryMonth:@"12"
        expiryYear:@"2013" saved:YES defaultPaymentInfo:YES paymentInfoID:paymentID completionBlock:^(NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //4. Get again
    [[HYWebService shared] customerPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertTrue ([[dict objectForKey:@"accountHolderName"] isEqualToString:@"UpdateName"], nil);
            STAssertTrue ([[dict objectForKey:@"cardNumber"] isEqualToString:@"************9999"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

- (void)test270UpdateCustomerPaymentBillingInfo {
    __block int done = 0;
    __block NSString *paymentID;
    
    //1. Login
    [self logInAndWait];

    //2. Get Payment ID
    [[HYWebService shared] customerPaymentInfosWithCompletionBlock:^(NSArray *array, NSError *error) {        
            STAssertTrue([array count] > 0, @"No payment infomations available");
            paymentID = [[array lastObject] objectForKey:@"id"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Update
    [[HYWebService shared] updateCustomerPaymentInfoBillingAddresssWithFirstName:@"TestFirst" lastName:@"TestLast" titleCode:@"mr" addressLine1:@"TestLine1"
        addressLine2:@"TestLine2" town:@"TestTown" postCode:@"TEST123" countryISOCode:@"GB" defaultPaymentInfo:YES paymentInfoID:paymentID completionBlock:^(
            NSError
            *error) {
            STAssertNil (error, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //4. Check
    [[HYWebService shared] customerPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            NSDictionary *billingAddress = [dict objectForKey:@"billingAddress"];
            STAssertTrue ([[billingAddress objectForKey:@"postalCode"] isEqualToString:@"TEST123"], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

@end
