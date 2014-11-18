//
// HYOCCCartTests.m
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

#import "HybrisTests.h"


@interface HYOCCCartTests : HybrisTests

@end



@implementation HYOCCCartTests

#pragma mark - Cart Tests

- (void)test030CreateCart {
    __block int done = 0;
    __block NSArray *objects;

    // 1. Get cart
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            objects = results;
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    // Should return one cart
    STAssertTrue (objects.count == 1, nil);
}


- (void)test040AddToCart {
    __block int done = 0;
    
    // Log in
    [self logInAndWait];
    
    // Log out
    [self logOutAndWait];

    // 1. Get cart
    __block Cart *cart;

    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Empty the cart
    while ([cart.totalUnitCount intValue] > 0) {
        [[HYWebService shared] deleteProductInCartAtEntry:0 completionBlock:^(NSDictionary *dict, NSError *error) {
                STAssertNil (error, [error description]);
                done = 1;
            }];

        while (done == 0) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

        done = 0;

        [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
                STAssertNil (error, [error description]);
                cart = [results objectAtIndex:0];
                done = 1;
            }];

        while (done == 0) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

        done = 0;
    }

    done = 0;

    // 2. Add product to cart
    [[HYWebService shared] addProductToCartWithCode:@"23355" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 3. Check cart count before and after
    NSInteger countBefore = [cart.totalUnitCount integerValue];

    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    NSInteger countAfter = [cart.totalUnitCount integerValue];

    STAssertTrue (countAfter == (countBefore + 1), nil);
    logInfo (@"%d, %d", countBefore, countAfter);

    // 4. Add second product with quantity
    [[HYWebService shared] addProductToCartWithCode:@"107701" quantity:2 completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 5. Check cart count before and after
    countBefore = [cart.totalUnitCount integerValue];

    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    countAfter = [cart.totalUnitCount integerValue];

    STAssertTrue (countAfter == (countBefore + 2), nil);

    // 6. Get cart again
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 7. Update quantity to 4 (was 1)
    [[HYWebService shared] updateProductInCartAtEntry:0 quantity:4 completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 8. Check cart count before and after
    countBefore = [cart.totalUnitCount integerValue];

    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    countAfter = [cart.totalUnitCount integerValue];

    STAssertTrue (countAfter == (countBefore + 3), nil);

    // 9. Get cart again
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 10. Delete
    [[HYWebService shared] deleteProductInCartAtEntry:1 completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 11. Check cart count before and after
    countBefore = [cart.totalUnitCount integerValue];

    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            cart = [results objectAtIndex:0];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    countAfter = [cart.totalUnitCount integerValue];

    STAssertTrue (countAfter < countBefore, nil);
}


- (void)test070CartDeliveryAddressCreateAndDelete {
    __block int done = 0;

    // 1. Log in
    [self logInAndWait];

    // Add product to cart
    __block NSDictionary *results;
    [[HYWebService shared] addProductToCartWithCode:@"23355" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            results = dict;
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Get a cart
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 2. Create an address
    NSString *addressID = [self createCustomerAddress];

    // 3. Set delivery address
    [[HYWebService shared] setCartDeliveryAddressWithID:addressID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            NSDictionary *address = [dict objectForKey:@"deliveryAddress"];
            STAssertNotNil (address, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 4. Delete delivery address
    [[HYWebService shared] deleteCartDeliveryAddressWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            // Check dict does not contain a delivery address
            NSDictionary *address = [dict objectForKey:@"deliveryAddress"];
            STAssertNil (address, nil);
            done = 1;
        }];
    done = 0;

    // 6. Create an address again
    addressID = [self createCustomerAddress];

    // 4. Set delivery address
    [[HYWebService shared] setCartDeliveryAddressWithID:addressID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


- (void)test070CartDeliveryAddressAndCheckout {
    __block int done = 0;

    // 1. Log in
    [self logInAndWait];

    // Add product to cart
    __block NSDictionary *results;
    [[HYWebService shared] addProductToCartWithCode:@"23355" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            results = dict;
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Get a cart
    [[HYWebService shared] cartWithCompletionBlock:^(NSArray *results, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 2. Create an address
    NSString *addressID = [self createCustomerAddress];

    // 3. Set delivery address
    [[HYWebService shared] setCartDeliveryAddressWithID:addressID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);

            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 4. get delivery modes
    __block NSString *code;
    [[HYWebService shared] cartDeliveryModesWithCompletionBlock:^(NSArray *array, NSError *error) {
            STAssertNil (error, [error description]);
            STAssertTrue (array.count, @"Should have at least one object");
            code = [[array lastObject] objectForKey:@"code"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 5. set delivery mode
    [[HYWebService shared] setCartDeliveryModeWithCode:code completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            NSDictionary *mode = [dict objectForKey:@"deliveryMode"];
            STAssertNotNil (mode, nil);
            STAssertTrue ([[mode objectForKey:@"code"] isEqualToString:code], nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //6. Delete
    [[HYWebService shared] deleteCartDeliveryModesWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            NSDictionary *mode = [dict objectForKey:@"deliveryMode"];
            STAssertNil (mode, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // set delivery mode again
    [[HYWebService shared] setCartDeliveryModeWithCode:code completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Create bad payment info (incorrect card type)
    [self createPaymentMethodWithName:@"My Name" andCorrectCard:NO andCorrectTitle:YES andCorrectCountry:YES];
    
    // Create bad payment info (incorrect conutry code)
    [self createPaymentMethodWithName:@"My Name" andCorrectCard:YES andCorrectTitle:YES andCorrectCountry:NO];

    // 3. Create payment info
    NSString *paymentID = [self createPaymentMethodWithName:@"My Name" andCorrectCard:YES andCorrectTitle:YES andCorrectCountry:YES];

    // Get Info of PaymentID by ID
    [[HYWebService shared] customerPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // 3. Create another payment info (but don't use)
    [self createPaymentMethodWithName:@"Other Name" andCorrectCard:YES andCorrectTitle:YES andCorrectCountry:YES];

    // 4. Add payment info to cart
    [[HYWebService shared] setCartPaymentInfoWithID:paymentID completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    // Authorize
    [[HYWebService shared] authorizeCreditCardPaymentWithSecurityCode:@"123" completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //5. Place order
    [[HYWebService shared] placeOrderForCartWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}


#pragma TODO fix test (orders expected)
- (void)test135Orders {
    __block int done = 0;

    // log in
    [self logInAndWait];

    // Get orders.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"CHECKED_INVALID,FRAUD_CHECKED", @"statuses"
        , @"0", @"currentPage"                    //current page is Zero
        , @"2", @"pageSize"
        , nil];
    [[HYWebService shared] ordersWithOptions:options completionBlock:^(NSDictionary *dictionary, NSError *error) {
            STAssertNil (error, [error description]);
            STAssertTrue (dictionary.count, nil);
            NSDictionary *pagination = [dictionary objectForKey:@"pagination"];
            STAssertTrue ([[[pagination objectForKey:@"currentPage"] stringValue] isEqualToString:@"0"], @"Pagination failed");
            STAssertTrue ([[[pagination objectForKey:@"pageSize"] stringValue] isEqualToString:@"2"], @"Pagination failed");
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
    
    // returns all order history
    [[HYWebService shared] ordersWithOptions:nil completionBlock:^(NSDictionary *dictionary, NSError *error) {
            STAssertNil (error, [error description]);
            NSArray *orders = [dictionary objectForKey:@"orders"];
            STAssertTrue (orders.count, nil);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}

#pragma TODO fix test (orders expected)
- (void)test136OrderWithID {
    __block int done = 0;

    // 1. log in
    [self logInAndWait];
    
    //2. Get Orders
    __block NSString *orderNumber;
    
    [[HYWebService shared] ordersWithOptions:nil completionBlock:^(NSDictionary *dictionary, NSError *error) {
            STAssertNil (error, [error description]);
            NSArray *orders = [dictionary objectForKey:@"orders"];
            orderNumber = [[orders lastObject] objectForKey:@"code"];
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;

    //3. Get Order by ID
    [[HYWebService shared] orderDetailsWithID:orderNumber completionBlock:^(NSDictionary *dict, NSError *error) {
            STAssertNil (error, [error description]);
            done = 1;
        }];

    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    done = 0;
}



#pragma mark - Helper methods

-(NSString *)createCustomerAddress {
    __block int done = 0;
    __block NSString *addressID;
    
    [[HYWebService shared] createCustomerAddressWithFirstName:@"Red"
                                                     lastName:@"Ant"
                                                    titleCode:@"mr"
                                                 addressLine1:@"115b Drysdale St"
                                                 addressLine2:@"Hoxton"
                                                         town:@"London"
                                                     postCode:@"N1 6ND"
                                               countryISOCode:@"GB"
                                              completionBlock:^(NSDictionary *dict, NSError *error) {
                                                  addressID = [dict objectForKey:@"id"];
                                                  done = 1;
                                              }];
    
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return addressID;
}


-(NSString *)createPaymentMethodWithName:(NSString *)name andCorrectCard:(BOOL)correctCard andCorrectTitle:(BOOL)correctTitle andCorrectCountry:(BOOL)correctCountry {
    __block int done = 0;
    __block BOOL errorExpected = YES;
    __block NSString *paymentID;
    
    if (correctCard && correctTitle && correctCountry) {
        errorExpected = NO;
    }
    
    NSString *cardType = @"visa";
    
    if (!correctCard) {
        cardType = @"UNKNOWNCARD";
    }
    
    NSString *customerTitle = @"mr";
    
    if (!correctTitle) {
        customerTitle = @"title";
    }
    
    NSString *countryCode = @"DE";
    
    if (!correctCountry) {
        countryCode = @"uk";
    }    
    
    [[HYWebService shared] createCustomerPaymentInfoWithAccountHolderName:name
                                                               cardNumber:@"4111111111111111"
                                                                 cardType:cardType
                                                              expiryMonth:@"01"
                                                               expiryYear:@"2013"
                                                                    saved:YES
                                                       defaultPaymentInfo:YES
                                                  billingAddressTitleCode:customerTitle
                                                                firstName:@"my"
                                                                 lastName:@"name"
                                                             addressLine1:@"text1"
                                                             addressLine2:@"text2"
                                                                 postCode:@"12345"
                                                                     town:@"somecity"
                                                           countryISOCode:countryCode
                                                          completionBlock:^(NSDictionary *dict, NSError *error) {
                                                              
                                                                if (errorExpected) {
                                                                    STAssertNotNil(error, [error description]);
                                                                } else {
                                                                    STAssertNil(error, [error description]);
                                                                    paymentID = [[dict objectForKey:@"paymentInfo"] objectForKey:@"id"];
                                                                }
 
                                                                done = 1;
                                                          }];
    
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return paymentID;
}

@end
