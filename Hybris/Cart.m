//
// Cart.m
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

#import "CartEntry.h"
#import "Price.h"
#import "HYProduct+Factory.h"

@implementation Cart

@synthesize code;
@synthesize productDiscounts;
@synthesize totalPrice;
@synthesize net;
@synthesize totalDiscounts;
@synthesize appliedProductPromotions;
@synthesize potentialProductPromotions;
@synthesize totalTax;
@synthesize totalUnitCount;
@synthesize orderDiscounts;
@synthesize potentialOrderPromotions;
@synthesize totalItems;
@synthesize entries;
@synthesize appliedOrderPromotions;
@synthesize subTotal;
@synthesize deliveryAddress;
@synthesize deliveryCost;
@synthesize deliveryMode;
@synthesize paymentInfo;

+ (Cart *)cartWithInfo:(NSDictionary *)infoDictionary {
    Cart *cart = [[Cart alloc] init];

    @try {
        [cart setValuesForKeysWithDictionary:infoDictionary];
    }@catch (NSException *exception) {
        logDebug(@"%@", exception);
    }

    if (cart.potentialProductPromotions && cart.potentialProductPromotions.count) {
        NSMutableArray *promotions = [NSMutableArray array];

        for (NSDictionary *d in cart.potentialProductPromotions) {
            [promotions addObject:[d objectForKey:@"promotion"]];
        }

        cart.potentialProductPromotions = [NSArray arrayWithArray:promotions];
    }

    if (cart.appliedProductPromotions && cart.appliedProductPromotions.count) {
        NSMutableArray *promotions = [NSMutableArray array];

        for (NSDictionary *d in cart.appliedProductPromotions) {
            [promotions addObject:[d objectForKey:@"promotion"]];
        }

        cart.appliedProductPromotions = [NSArray arrayWithArray:promotions];
    }

    for (id object in infoDictionary) {
        if ([object isEqualToString:@"entries"]) {
            NSMutableArray *entries = [[NSMutableArray alloc] init];

            for (NSMutableDictionary *entryInfo in[infoDictionary objectForKey : @"entries"]) {
                CartEntry *cartEntry = [[CartEntry alloc] init];
                [cartEntry setValuesForKeysWithDictionary:entryInfo];

                Price *priceObject = [[Price alloc] init];
                [priceObject setValuesForKeysWithDictionary:[entryInfo objectForKey:@"totalPrice"]];
                [cartEntry setValue:priceObject forKey:@"totalPrice"];

                priceObject = [[Price alloc] init];
                [priceObject setValuesForKeysWithDictionary:[entryInfo objectForKey:@"basePrice"]];
                [cartEntry setValue:priceObject forKey:@"basePrice"];

                NSString *imgURL =
                    [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_base_url_preference"], @""];
                [entryInfo setValue:imgURL forKey:@"imageBaseURL"];
                HYProduct *p = [HYProduct objectWithInfo:entryInfo]; //thread safe?
                [cartEntry setValue:p forKey:@"product"];

                [entries addObject:cartEntry];
            }

            [cart setValue:entries forKey:object];
        }
        else if ([object isEqualToString:@"totalPrice"] || [object isEqualToString:@"totalDiscounts"] || [object isEqualToString:@"totalTax"] ||
            [object isEqualToString:@"orderDiscounts"] || [object isEqualToString:@"subTotal"] || [object isEqualToString:@"productDiscounts"]) {
            Price *price = [[Price alloc] init];
            [price setValuesForKeysWithDictionary:[infoDictionary objectForKey:object]];
            [cart setValue:price forKey:object];
        }

//        else {
//            //[cart setValuesForKeysWithDictionary:<#(NSDictionary *)#>]
//            [cart setValue:[infoDictionary objectForKey:object] forKey:object];
//        }
    }

    return cart;
}


@end
