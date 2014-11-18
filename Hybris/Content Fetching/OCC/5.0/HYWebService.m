//
// HYWebService.m
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


// Private Interface
@interface HYWebService ()

// Settings-based properties
@property (nonatomic, readonly, strong) NSUserDefaults *userDefaults;
@property (nonatomic, readonly, weak) NSString *baseURL;
@property (nonatomic, readonly, weak) NSString *imageURL;
@property (nonatomic, readonly, weak) NSString *siteURLSuffixsiteURLSuffix;

// This method generates the ETag from selected facets
- (NSString *)generateQueryTagFromQuery:(HYQuery *)query;
// Helper method for generating ETag
- (NSString *)generateQueryTagFromDictionary:(NSDictionary *)tagDictionary;
// Generates the url for API call
- (NSString *)urlWithSearchString:(NSString *)searchString pageSize:(int)pageSize currentPage:(int)currentPage;
// Updates the query object with pagination details
- (void)populateQuery:(HYQuery *)query withInfo:(NSDictionary *)pagination;
// Updates the query object with the sort methods returned from API server
- (void)populateSortMethodsForQuery:(HYQuery *)query withArray:(NSArray *)sortMethods;
// Updates the query object with Facets returned from API server
- (NSArray *)populateFacetsForQuery:(HYQuery *)query withArray:(NSArray *)facets;
// Updates the query object with the filtered products returned from API server
- (NSArray *)populateProductsForQuery:(HYQuery *)query withArray:(NSArray *)products;

/**
 *  Populate the store with all items for a particular query.
 *
 *  @param query The query object the items will be associated with. Also contains the free text for the search.
 *  @param resetQuery If this is YES, all items currently related to this query will be cleared befiore the new search.
 */
- (void)fetchItemsForQuery:(HYQuery *)query resetQuery:(BOOL) reset withCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;

@end

@implementation HYWebService

@synthesize userDefaults = _userDefaults;

#pragma mark - Properties
//Hybris test by bin
- (NSString *)baseURL {
    return [NSString stringWithFormat:@"%@%@", [self.userDefaults stringForKey:@"web_services_base_url_preference"], @"/rest/v1/"];
//    return [NSString stringWithFormat:@"%@%@", [self.userDefaults stringForKey:@"web_services_base_url_preference"], @"/bncstorefront/"];
}


- (NSString *)imageURL {
    return [NSString stringWithFormat:@"%@%@", [self.userDefaults stringForKey:@"web_services_base_url_preference"], @""];
}


- (NSString *)siteURLSuffix {
    return [self.userDefaults stringForKey:@"web_services_site_url_suffix_preference"];
}


- (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return _userDefaults;
}


#pragma mark - Designated Initializer

// Designated Initializer
PureSingleton(HYWebService);
- (id)init {
    if (self = [super init]) {
    }

    return self;
}


#pragma mark - Public API methods

/// This only returns HYProduct objects in its block
- (void)fetchItemsForQuery:(HYQuery *)query resetQuery:(BOOL)reset withCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    logInfo2(@"\n");

    if (reset) {
        logDebug(@"Resetting query...");
        [query resetObject];
    }

    NSString *sortMethod = query.selectedSort.internalName ? query.selectedSort.internalName : @"";
    NSString *searchQuery = [self generateQueryTagFromQuery:query];

    if (searchQuery) {
        searchQuery = [NSString stringWithFormat:@"%@:%@:%@", query.queryString, sortMethod, searchQuery];
    }
    else {
        searchQuery = [NSString stringWithFormat:@"%@:%@", query.queryString, sortMethod];
    }
    
    // Clear if there is no search
    if ([query.queryString isEmpty]) {
        searchQuery = [NSString stringWithFormat:@"%@&clear=true", searchQuery];
    }

    NSString *url = [self urlWithSearchString:searchQuery pageSize:[query.pageSize intValue] currentPage:[query.currentPage intValue]];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:url completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    dispatch_async (dispatch_get_main_queue (), ^{

                        NSArray *facets = [dict objectForKey:@"facets"];
                        NSArray *products = [dict objectForKey:@"products"];
                        NSDictionary *pagination = [dict objectForKey:@"pagination"];
                        NSArray *sortMethods = [dict objectForKey:@"sorts"];
                        NSDictionary *spellingSuggestion = [dict objectForKey:@"spellingSuggestion"];

                        __block NSMutableDictionary *objects = [[NSMutableDictionary alloc] init];

                        logDebug (@"*** Populating model...");

                        [self populateQuery:query withInfo:pagination];
                        [self populateSortMethodsForQuery:query withArray:sortMethods];
                        [self populateFacetsForQuery:query withArray:facets];

                        [objects setObject:[self populateProductsForQuery:query withArray:products] forKey:@"products"];

                        if (spellingSuggestion) {
                            [objects setObject:spellingSuggestion forKey:@"spellingSuggestion"];
                            [HYDidYouMean objectWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:[spellingSuggestion objectForKey:@"suggestion"], @"suggestion",
                                    query, @"query", nil]];
                        }

                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (objects, error);
                                });
                        }
                    });
                }
                else {
                    if (completionBlock) {
                        completionBlock (nil, error);
                    }
                }
            }
        }];
}

- (void)fetchFurtherItems:(HYQuery *)query withCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSNumber *i = [NSNumber numberWithInt:[query.currentPage intValue] + 1];

    if ([i intValue] < [query.totalPages intValue]) {
        [query setCurrentPage:i];
        [self fetchItemsForQuery:query resetQuery:NO withCompletionBlock:completionBlock];
    }
}


#pragma mark - Private methods

- (NSArray *)populateFacetsForQuery:(HYQuery *)query withArray:(NSArray *)facets {
    NSArray *ignoredFacets = [[HYAppDelegate sharedDelegate].configDictionary objectForKey:@"Ignored Facets"];

    if (ignoredFacets == nil) {
        ignoredFacets = [NSArray array];
    }

    NSMutableArray *objects = [[NSMutableArray alloc] init];

    // Remove all facets not being used
    NSMutableSet *remove = [[NSMutableSet alloc] init];

    for (id fv in query.items) {
        if ([fv isKindOfClass:[HYFacetValue class]] || [fv isKindOfClass:[HYFacet class]]) {
            [remove addObject:fv];
        }
    }

    // Add selected ones
    NSMutableSet *keepAlive = [[NSMutableSet alloc] init];

    for (HYFacetValue *fv in query.selectedFacetValues) {
        [keepAlive addObject:fv];
        [keepAlive addObject:fv.facet];
    }

    [query.items removeObjectsInArray:[remove allObjects]];
    [query.items addObjectsFromArray:[keepAlive allObjects]];

    for (NSDictionary *d1 in facets) {
        NSString *facetInternalName;
        NSString *facetvalue;
        NSMutableDictionary *facetInfo = [[NSMutableDictionary alloc] init];
        NSArray *facetValues = [d1 objectForKey:@"values"];
        NSMutableArray *facetValuesArray = [[NSMutableArray alloc] initWithCapacity:facetValues.count];

        BOOL hasData = NO;

        for (NSDictionary *d2 in facetValues) {
            if (![[d2 objectForKey:@"selected"] boolValue]) {
                hasData = YES;
                NSMutableDictionary *facetValuesDictionary = [[NSMutableDictionary alloc] init];
                NSString *facetQuery = [d2 objectForKey:@"query"];                
                NSArray *tempValues = [facetQuery componentsSeparatedByString:@":"];                
                facetInternalName = [tempValues objectAtIndex:tempValues.count-2];
                facetvalue = [tempValues lastObject];

                [facetValuesDictionary setObject:[d2 objectForKey:@"name"] forKey:@"name"]; // e.g. Black
                [facetValuesDictionary setObject:facetvalue forKey:@"value"]; // e.g. black
                [facetValuesDictionary setObject:[d2 valueForKey:@"count"] forKey:@"count"]; // 2
                [facetValuesDictionary setObject:[d2 valueForKey:@"selected"] forKey:@"selected"];

                [facetValuesArray addObject:facetValuesDictionary];
            }
        }

        if (hasData) {
            [facetInfo setObject:[d1 objectForKey:@"name"] forKey:@"name"]; // e.g Color
            [facetInfo setObject:facetInternalName forKey:@"internalName"]; // e.g Colour of product, 1766
            [facetInfo setObject:facetValuesArray forKey:@"facetValues"]; // eg. Black = black
            [facetInfo setObject:[d1 objectForKey:@"multiSelect"] forKey:@"multiSelect"];
            [facetInfo setObject:query forKey:@"query"];

            // Ignore ignored facets (set in settings.plist)
            if (![ignoredFacets containsObject:[facetInfo objectForKey:@"name"]]) {
                [objects addObject:[HYFacet objectWithInfo:facetInfo]];
            }
        }
    }

    return objects;
}


- (NSArray *)populateProductsForQuery:(HYQuery *)query withArray:(NSArray *)products {
    NSMutableArray *objects = [[NSMutableArray alloc] init];

    NSInteger i = [query.pageSize intValue] * [query.currentPage intValue];

    for (NSDictionary *product in products) {
        HYProduct *p = [HYProduct objectWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                product, @"product",
                query, @"query",
                nil]];
        p.sortRank = i++;
        [objects addObject:p];
    }

    return objects;
}


- (void)populateSortMethodsForQuery:(HYQuery *)query withArray:(NSArray *)sortMethods {
    @synchronized(query) {
        //remove all previous sort elements before adding new ones
        NSMutableArray *keepItems = [NSMutableArray array];

        NSArray *items = [NSArray arrayWithArray:query.items];
        for (HYItem *item in items) {
            if (![item isKindOfClass:[HYSort class]]) {
                [keepItems addObject:item];
            }
        }

        query.items = [NSMutableArray arrayWithArray:keepItems];

        for (NSDictionary *sortMethod in sortMethods) {
            NSMutableDictionary *mutableSort = [NSMutableDictionary dictionaryWithDictionary:sortMethod];
            [mutableSort setObject:query forKey:@"query"];
            [HYSort objectWithInfo:mutableSort];
        }
    }
}


- (void)populateQuery:(HYQuery *)query withInfo:(NSDictionary *)pagination {
    query.totalResults = [NSNumber numberWithInt:[[pagination valueForKey:@"totalResults"] intValue]];
    query.totalPages = [NSNumber numberWithInt:[[pagination valueForKey:@"totalPages"] intValue]];
    query.pageSize = [NSNumber numberWithInt:[[pagination valueForKey:@"pageSize"] intValue]];
    query.currentPage = [NSNumber numberWithInt:[[pagination valueForKey:@"currentPage"] intValue]];
    query.lastPopulated = [NSDate date];
}


#pragma mark - Helper methods

- (void)debug:(NSData *)data {
    logDebug(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}


- (NSString *)generateQueryTagFromDictionary:(NSDictionary *)tagDictionary {
    NSArray *facetKeys = [tagDictionary allKeys];
    NSString *generatedTag;

    for (NSString *key in facetKeys) {
        NSArray *facetValuesArray = [tagDictionary objectForKey:key];

        for (NSDictionary *facetValue in facetValuesArray) {
            if (generatedTag.length) {
                generatedTag = [generatedTag stringByAppendingFormat:@":%@:%@", key, [facetValue valueForKey:@"value"]];
            }
            else {
                generatedTag = [NSString stringWithFormat:@"%@:%@", key, [facetValue valueForKey:@"value"]];
            }
        }
    }

    return generatedTag;
}


- (NSString *)generateQueryTagFromQuery:(HYQuery *)query {
    NSString *facetTag;
    NSString *categoryTag;

    for (HYFacetValue *fv in query.selectedFacetValues) {
        if (facetTag.length) {
            facetTag = [facetTag stringByAppendingFormat:@":%@:%@", fv.facet.internalName, fv.value];
        }
        else {
            facetTag = [NSString stringWithFormat:@"%@:%@", fv.facet.internalName, fv.value];
        }
    }

    categoryTag = query.selectedCategory.searchTag;

    if (facetTag && categoryTag) {
        return [NSString stringWithFormat:@"%@:%@", facetTag, categoryTag];
    }

    if (facetTag) {
        return facetTag;
    }

    if (categoryTag) {
        return categoryTag;
    }

    return nil;
}


- (void)clientCredentialsTokenWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=client_credentials", HYAuthClientID, HYAuthClientSecret];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:[HYWebServiceAuthProvider tokenURL] httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *
            jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"access_token"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (NSString *)urlWithSearchString:(NSString *)searchString pageSize:(int)pageSize currentPage:(int)currentPage {
    NSString *url = [NSString stringWithFormat:@"%@%@products?query=%@&pageSize=%i&currentPage=%i",
        self.baseURL,
        self.siteURLSuffix,
        searchString,
        pageSize,
        currentPage];

    return url;
}


- (NSString *)urlForProducts {
    NSString *url = [NSString stringWithFormat:@"%@%@products/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlWithProductCode:(NSString *)productCode {
    NSString *url = [NSString stringWithFormat:@"%@%@products/%@",
        self.baseURL,
        self.siteURLSuffix,
        productCode];

    return url;
}


- (NSString *)urlForCart {
    NSString *url = [NSString stringWithFormat:@"%@%@cart/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCartEntry {
    NSString *url = [NSString stringWithFormat:@"%@%@cart/entry",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCartDeliveryModes {
    NSString *url = [NSString stringWithFormat:@"%@%@cart/deliverymodes",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCartDeliveryAddress {
    NSString *url = [NSString stringWithFormat:@"%@%@cart/address/delivery",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForOrders {
    NSString *url = [NSString stringWithFormat:@"%@%@orders/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCustomer {
    NSString *url = [NSString stringWithFormat:@"%@%@customers/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForLanguages {
    NSString *url = [NSString stringWithFormat:@"%@%@languages/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCurrencies {
    NSString *url = [NSString stringWithFormat:@"%@%@currencies/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForDeliveryCountries {
    NSString *url = [NSString stringWithFormat:@"%@%@deliverycountries/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForCardTypes {
    NSString *url = [NSString stringWithFormat:@"%@%@cardtypes/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForTitles {
    NSString *url = [NSString stringWithFormat:@"%@%@titles/",
        self.baseURL,
        self.siteURLSuffix];

    return url;
}


- (NSString *)urlForStores {
    NSString *url = [NSString stringWithFormat:@"%@%@stores/",
                     self.baseURL,
                     self.siteURLSuffix];
    
    return url;
}


#pragma mark - HYOCCProtocol

#pragma mark - Product methods

- (void)products:(HYQuery *)query completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    [self fetchItemsForQuery:query resetQuery:YES withCompletionBlock:completionBlock];
}


- (void)productWithCode:(NSString *)productCode options:(NSArray *)options completionBlock:(NSArrayNSErrorBlock)completionBlock {
    NSString *optionsString = [options componentsJoinedByString:@","];

    if (optionsString.length) {
        optionsString = [NSString stringWithFormat:@"?options=%@", optionsString];
    }
    else {
        optionsString = @"";
    }

    (void)[[HYWebServiceDataProvider alloc] initWithURL:[NSString stringWithFormat:@"%@%@", [self urlWithProductCode:productCode],
            optionsString] completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error:&jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    if ([dict objectForKey:@"code"]) {
                        [dict setObject:productCode forKey:@"code"];

                        __block NSMutableArray *objects = [[NSMutableArray alloc] init];

                        [objects addObject:[HYProduct objectWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                    dict, @"product",
                                    nil]
                            ]];

                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (objects, error);
                                });
                        }
                    }
                    else {
                        // No product found
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }

                        return;
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

#pragma mark - Cart methods

- (void)cartWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForCart] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:
                            NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    __block NSMutableArray *objects = [[NSMutableArray alloc] init];
                    [objects addObject:[Cart cartWithInfo:dict]];

                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (objects, error);
                            });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)addProductToCartWithCode:(NSString *)code quantity:(NSInteger)quantity completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"code=%@&qty=%i", code, quantity];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForCartEntry] httpMethod:@"POST" httpBody:(NSData *)postData completionBlock:^(NSData *
            jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"statusCode"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)addProductToCartWithCode:(NSString *)code completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    [self addProductToCartWithCode:code quantity:1 completionBlock:completionBlock];
}


- (void)updateProductInCartAtEntry:(NSInteger)entry quantity:(NSInteger)quantity completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[NSString stringWithFormat:@"%@/%i?qty=%i", [self urlForCartEntry], entry,
            quantity] httpMethod:@"PUT" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [[dict objectForKey:@"statusCode"] isEqualToString:@"success"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)deleteProductInCartAtEntry:(NSInteger)entry completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[NSString stringWithFormat:@"%@/%i", [self urlForCartEntry],
            entry] httpMethod:@"DELETE" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [[dict objectForKey:@"statusCode"] isEqualToString:@"success"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)setCartDeliveryAddressWithID:(NSString *)addressID completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] authorizedURL:[NSString stringWithFormat:@"%@/%@", [self urlForCartDeliveryAddress], addressID]
        httpMethod:@"PUT"
        httpBody:nil
        completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }
                    }

                    BOOL success = ([dict objectForKey:@"error"] || [dict objectForKey:@"class"]) ? NO:YES;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)deleteCartDeliveryAddressWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] authorizedURL:[self urlForCartDeliveryAddress]
        httpMethod:@"DELETE"
        httpBody:nil
        completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"error"] ? NO:YES;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)createCustomerPaymentInfoWithAccountHolderName:(NSString *)accountHolderName
                                            cardNumber:(NSString *)cardNumber
                                              cardType:(NSString *)cardType
                                           expiryMonth:(NSString *)expiryMonth
                                            expiryYear:(NSString *)expiryYear
                                                 saved:(BOOL)shouldSave
                                    defaultPaymentInfo:(BOOL)isDefaultPaymentInfo
                               billingAddressTitleCode:(NSString *)titleCode
                                             firstName:(NSString *)firstName
                                              lastName:(NSString *)lastName
                                          addressLine1:(NSString *)addressLine1
                                          addressLine2:(NSString *)addressLine2
                                              postCode:(NSString *)postCode
                                                  town:(NSString *)town
                                        countryISOCode:(NSString *)countryCode
                                       completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCart] stringByAppendingString:@"paymentinfo"];
    NSString *postBody =
        [[NSString stringWithFormat:
            @"accountHolderName=%@&cardNumber=%@&cardType=%@&expiryMonth=%@&expiryYear=%@&saved=%@&defaultPaymentInfo=%@&billingAddress.titleCode=%@&billingAddress.firstName=%@&billingAddress.lastName=%@&billingAddress.line1=%@&billingAddress.line2=%@&billingAddress.postalCode=%@&billingAddress.town=%@&billingAddress.country.isocode=%@",
            accountHolderName,
            cardNumber,
            cardType,
            expiryMonth,
            expiryYear,
            shouldSave ? @"true":@"false",
            isDefaultPaymentInfo ? @"true":@"false",
            titleCode,
            firstName,
            lastName,
            addressLine1,
            addressLine2,
            postCode,
            town,
            countryCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL
        httpMethod:@"POST"
        httpBody:postData
        completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"paymentInfo"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)setCartPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCart] stringByAppendingFormat:@"paymentinfo/%@", paymentInfoID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL httpMethod:@"PUT" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"paymentInfo"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }

                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)cartDeliveryModesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] authorizedURL:[self urlForCartDeliveryModes] httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData,
            NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"deliveryModes"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"deliveryModes"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)setCartDeliveryModeWithCode:(NSString *)code completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerAddressURL = [[self urlForCartDeliveryModes] stringByAppendingFormat:@"/%@", code];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerAddressURL httpMethod:@"PUT" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"deliveryMode"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)deleteCartDeliveryModesWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerAddressURL = [self urlForCartDeliveryModes];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerAddressURL httpMethod:@"DELETE" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"deliveryMode"] ? NO:YES;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)authorizeCreditCardPaymentWithSecurityCode:(NSString *)securityCode completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *authorizeURL = [[self urlForCart] stringByAppendingString:@"authorize"];
    NSString *postBody = [[NSString stringWithFormat:@"securityCode=%@", securityCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:authorizeURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"code"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)placeOrderForCartWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *plceOrderURL = [[self urlForCart] stringByAppendingString:@"placeorder"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:plceOrderURL httpMethod:@"POST" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (error) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                        return;
                    }

                    NSError *jsonError;

                    NSMutableDictionary *dict =
                        [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                            error
                            :&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"code"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else if (jsonData == nil && error == nil) {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (),
                            ^{ completionBlock  (nil,
                                    [NSError errorWithDomain:@"com.hybris" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            @"Webservice returned nil", @"message",
                                            nil]]);
                            });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)ordersWithOptions:(NSDictionary *)options completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSMutableString *queryString = [[NSMutableString alloc] init];

    for (NSString *aKey in options) {
        if (queryString.length == 0) {
            [queryString appendFormat:@"%@=%@", aKey, [options objectForKey:aKey]];
        }
        else {
            [queryString appendFormat:@"&%@=%@", aKey, [options objectForKey:aKey]];
        }
    }

    NSString *ordersURL = [[self urlForOrders] stringByAppendingFormat:@"?%@", queryString];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:ordersURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (jsonData) {
                if (completionBlock) {
                    if (completionBlock) {
                        if (error) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                                });
                            return;
                        }

                        NSError *jsonError;

                        NSDictionary *dict =
                            [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                                error:&
                                jsonError]
                            ];

                        if (jsonError) {
                            [self debug:jsonData];

                            if (completionBlock) {
                                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                    });
                            }

                            return;
                        }

                        BOOL success = [dict objectForKey:@"orders"] ? YES:NO;

                        if (completionBlock) {
                            if (success) {
                                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                    });
                            }
                            else {
                                dispatch_async (dispatch_get_main_queue (),
                                    ^{ completionBlock  (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                    });
                            }
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock  (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)orderDetailsWithID:(NSString *)orderID completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *ordersURL = [[self urlForOrders] stringByAppendingFormat:@"%@", orderID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:ordersURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]
                        ];

                    if (jsonError) {
                        [self debug:jsonData];

                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"code"] ? YES:NO;

                    if (completionBlock) {
                        if (success) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                        else {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
            }
            else {
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                }
            }
        }];
}

#pragma mark - Customer methods

- (void)loginWithUsername:(NSString *)userName password:(NSString *)password completionBlock:(NSErrorBlock)completionBlock {
    [[HYWebServiceDataProvider alloc] loginWithUsername:userName password:password completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }

                NSError *jsonError;

                NSDictionary *dict =
                    [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                        jsonError]];

                if (jsonError) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                        });
                    return;
                }

                BOOL success = [dict objectForKey:@"access_token"] ? YES:NO;

                if (success) {
                    [HYWebServiceAuthProvider saveTokensWithDictionary:dict];
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                }
                else {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                        });
                }
            }
        }];
}

- (void)logoutWithCompletionBlock:(NSErrorBlock)completionBlock {
    [[HYWebServiceDataProvider alloc] logoutWithCompletionBlock:^(NSData *jsonData, NSError *error) {
            // Clear the tokens and cookies clientside, whatever happens with the server
            [HYWebServiceAuthProvider clearAuthInformation];

            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }

                NSError *jsonError;

                NSDictionary *dict =
                    [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                        jsonError]];

                if (jsonError) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                        });
                    return;
                }

                BOOL success = [[dict objectForKey:@"success"] boolValue] ? YES:NO;

                if (success) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                }
                else {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                        });
                }
            }
        }];
}

- (void)registerCustomerWithFirstName:(NSString *)firstName
                             lastName:(NSString *)lastName
                            titleCode:(NSString *)titleCode
                                login:(NSString *)login
                             password:(NSString *)password
                      completionBlock:(NSErrorBlock)completionBlock {
    //Generate credentials auth_token
    [self clientCredentialsTokenWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }
            }

            NSString *tempAuthToken = [dict objectForKey:@"access_token"];
            NSString *postBody =
                [NSString stringWithFormat:@"login=%@&password=%@&firstName=%@&lastName=%@&titleCode=%@", login, password, firstName, lastName, titleCode];
            NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

            [[HYWebServiceDataProvider alloc] authorizedURL:[self urlForCustomer] clientCredentialsToken:tempAuthToken httpBody:postData completionBlock:^(
                    NSData *jsonData, NSError *error) {
                    if (jsonData) {
                        if (completionBlock) {
                            if (error) {
                                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                                    });
                                return;
                            }

                            NSError *jsonError;

                            NSDictionary *dict =
                                [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                                    error:&jsonError]
                                ];

                            if (jsonError) {
                                if (completionBlock) {
                                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                                        });
                                }

                                return;
                            }

                            if (completionBlock) {
                                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                    });
                            }
                        }
                        else {
                            if (completionBlock) {
                                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                                    });
                            }
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                                });
                        }
                    }
                }];
        }];
}

- (void)createCustomerAddressWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                              addressLine1:(NSString *)addressLine1
                              addressLine2:(NSString *)addressLine2
                                      town:(NSString *)town
                                  postCode:(NSString *)postCode
                            countryISOCode:(NSString *)countryISOCode
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *postBody = [[NSString stringWithFormat:@"titleCode=%@&firstName=%@&lastName=%@&line1=%@&line2=%@&town=%@&postalCode=%@&country.isocode=%@",
            titleCode,
            firstName,
            lastName,
            addressLine1,
            addressLine2,
            town,
            postCode,
            countryISOCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *addressURL = [[self urlForCustomer] stringByAppendingString:@"current/addresses"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:addressURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"id"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)setDefaultCustomerAddressWithID:(NSString *)addressID completionBlock:(NSErrorBlock)completionBlock {
    NSString *customerAddressURL = [[self urlForCustomer] stringByAppendingFormat:@"current/addresses/default/%@", addressID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerAddressURL httpMethod:@"PUT" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (error) {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                    });
                return;
            }

            // This method returns no data if successful
            if (jsonData) {
                if (completionBlock) {
                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:
                            nil]];
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                        });
                }
            }
            else {
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                }
            }
        }];
}

- (void)customerAddressesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    NSString *addressURL = [[self urlForCustomer] stringByAppendingFormat:@"current/addresses/"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:addressURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    NSArray *addresses = [dict objectForKey:@"addresses"];

                    if (addresses == nil) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (addresses, error);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)updateCustomerAddressWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                              addressLine1:(NSString *)addressLine1
                              addressLine2:(NSString *)addressLine2
                                      town:(NSString *)town
                                  postCode:(NSString *)postCode
                            countryISOCode:(NSString *)countryISOCode
                                 addressID:(NSString *)addressID
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *postBody = [[NSString stringWithFormat:@"titleCode=%@&firstName=%@&lastName=%@&line1=%@&line2=%@&town=%@&postalCode=%@&country.isocode=%@",
            titleCode,
            firstName,
            lastName,
            addressLine1,
            addressLine2,
            town,
            postCode,
            countryISOCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *addressURL = [[self urlForCustomer] stringByAppendingFormat:@"current/addresses/%@", addressID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:addressURL httpMethod:@"PUT" httpBody:postData completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"id"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)deleteCustomerAddressWithID:(NSString *)addressID completionBlock:(NSErrorBlock)completionBlock {
    NSString *customerAddressURL = [[self urlForCustomer] stringByAppendingFormat:@"current/addresses/%@", addressID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerAddressURL httpMethod:@"DELETE" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            // This method returns no data if successful
            if (jsonData) {
                if (completionBlock) {
                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:
                            nil]];
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                        });
                }
            }
            else {
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                }
            }
        }];
}

- (void)updateCustomerProfileWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                                  language:(NSString *)language
                                  currency:(NSString *)currency
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *postBody =
        [[NSString stringWithFormat:@"firstName=%@&lastName=%@&titleCode=%@&language=%@&currency=%@", firstName, lastName, titleCode, language,
            currency] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *customerProfileURL = [[self urlForCustomer] stringByAppendingString:@"current/profile"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerProfileURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"uid"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)customerProfileWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerAddressURL = [[self urlForCustomer] stringByAppendingString:@"current"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerAddressURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"uid"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)updateCustomerPasswordWithNewPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completionBlock:(NSErrorBlock)completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"old=%@&new=%@", oldPassword, newPassword];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *customerPasswordURL = [[self urlForCustomer] stringByAppendingString:@"current/password"];
    
    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPasswordURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData,
                                                                                                                                     NSError *error) {
        if (completionBlock) {
            if (error) {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                });
                return;
            }
            
            if (jsonData) {
                NSError *jsonError;
                
                if (jsonError) {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                        });
                    }
                    
                    return;
                }
                
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                    });
                }
            }
            else {
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                    });
                }
            }
        }
    }];
}

- (void)updateCustomerLoginWithNewLogin:(NSString *)newLogin password:(NSString *)password completionBlock:(NSErrorBlock)completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"newLogin=%@&password=%@", newLogin, password];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *customerURL = [[self urlForCustomer] stringByAppendingString:@"current/login"];
    
    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData,
                                                                                                                                     NSError *error) {
        if (completionBlock) {
            if (error) {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                });
                return;
            }
            
            if (jsonData) {
                NSError *jsonError;
                
                NSDictionary *dict =
                [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                                                        jsonError]];
                
                if (jsonError) {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                        });
                    }
                    
                    return;
                }
                
                BOOL success = [dict objectForKey:@"success"] ? YES:NO;
                
                if (success) {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                            });
                    }
                }
                
            }
            else {
                if (completionBlock) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                    });
                }
            }
        }
    }];
}

- (void)customerPaymentInfosWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCustomer] stringByAppendingString:@"current/paymentinfos"];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"paymentInfos"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"paymentInfos"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)customerPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCustomer] stringByAppendingFormat:@"current/paymentinfos/%@", paymentInfoID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL httpMethod:@"GET" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"id"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)deleteCustomerPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCustomer] stringByAppendingFormat:@"current/paymentinfos/%@", paymentInfoID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL httpMethod:@"DELETE" httpBody:nil completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                                });
                        }

                        return;
                    }

                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                            });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                            });
                    }
                }
            }
        }];
}

- (void)updateCustomerPaymentInfoWithAccountHolderName:(NSString *)accountHolderName
                                            cardNumber:(NSString *)cardNumber
                                              cardType:(NSString *)cardType
                                           expiryMonth:(NSString *)expiryMonth
                                            expiryYear:(NSString *)expiryYear
                                                 saved:(BOOL)shouldSave
                                    defaultPaymentInfo:(BOOL)isDefaultPaymentInfo
                                         paymentInfoID:(NSString *)paymentInfoID
                                       completionBlock:(NSErrorBlock)completionBlock {
    NSString *customerPaymentURL = [[self urlForCustomer] stringByAppendingFormat:@"current/paymentinfos/%@", paymentInfoID];
    NSString *postBody =
        [[NSString stringWithFormat:@"accountHolderName=%@&cardNumber=%@&cardType=%@&expiryMonth=%@&expiryYear=%@&saved=%@&defaultPaymentInfo=%@",
            accountHolderName,
            cardNumber,
            cardType,
            expiryMonth,
            expiryYear,
            shouldSave ? @"true":@"false",
            isDefaultPaymentInfo ? @"true":@"false"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:customerPaymentURL httpMethod:@"PUT" httpBody:postData completionBlock:^(NSData *jsonData, NSError *
            error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                                });
                        }

                        return;
                    }

                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                            });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                            });
                    }
                }
            }
        }];
}

- (void)updateCustomerPaymentInfoBillingAddresssWithFirstName:(NSString *)firstName
                                                     lastName:(NSString *)lastName
                                                    titleCode:(NSString *)titleCode
                                                 addressLine1:(NSString *)addressLine1
                                                 addressLine2:(NSString *)addressLine2
                                                         town:(NSString *)town
                                                     postCode:(NSString *)postCode
                                               countryISOCode:(NSString *)countryISOCode
                                           defaultPaymentInfo:(BOOL)isDefaultPaymentInfo
                                                paymentInfoID:(NSString *)paymentInfoID
                                              completionBlock:(NSErrorBlock)completionBlock {
    NSString *postBody =
        [[NSString stringWithFormat:@"titleCode=%@&firstName=%@&lastName=%@&line1=%@&line2=%@&town=%@&postalCode=%@&country.isocode=%@&defaultPaymentInfo=%@",
            titleCode,
            firstName,
            lastName,
            addressLine1,
            addressLine2,
            town,
            postCode,
            countryISOCode,
            isDefaultPaymentInfo ? @"true":@"false"]
        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *addressURL = [[self urlForCustomer] stringByAppendingFormat:@"current/paymentinfos/%@/address", paymentInfoID];

    (void)[[HYWebServiceDataProvider alloc] authorizedURL:addressURL httpMethod:@"POST" httpBody:postData completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                                });
                        }

                        return;
                    }

                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                            });
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                            });
                    }
                }
            }
        }];
}

#pragma mark - Misc methods
- (void)forgotPasswordWithLogin:(NSString *)login completionBlock:(NSErrorBlock)completionBlock {
    //Generate credentials auth_token
    [self clientCredentialsTokenWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (completionBlock) {
            if (error) {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);});
                return;
            }
        }
        NSString *tempAuthToken = [dict objectForKey:@"access_token"];
        
        NSString *postBody =
        [NSString stringWithFormat:@"login=%@", login];
        NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
        
        NSString *passwordURL = [[self urlForCustomer] stringByAppendingString:@"current/forgottenpassword"];
        
        [[HYWebServiceDataProvider alloc] authorizedURL:passwordURL clientCredentialsToken:tempAuthToken httpBody:postData completionBlock:^(NSData *data, NSError *error) {
            
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error);
                    });
                    return;
                }
                
                if (data) {
                    NSError *jsonError;
                    
                    NSDictionary *dict =
                    [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&
                                                            jsonError]];
                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (jsonError);
                            });
                        }
                        return;
                    }
                    BOOL success = [[dict objectForKey:@"success"] boolValue] ? YES:NO;
                    
                    if (success) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil);
                        });
                    }
                    else {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                        });
                    }
                    return;
                }
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([NSError errorWithDomain:@"com.hybris" code:1 userInfo:nil]);
                });
            }
        }];
    }];
    
}

- (void)languagesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForLanguages] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"languages"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"languages"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)currenciesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForCurrencies] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"currencies"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"currencies"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

// List all supported countries
- (void)countriesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForDeliveryCountries] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"countries"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"countries"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)cardTypesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForCardTypes] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"cardTypes"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"cardTypes"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)titlesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock {
    (void)[[HYWebServiceDataProvider alloc] initWithURL:[self urlForTitles] completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"titles"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock ([dict objectForKey:@"titles"], error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)suggestionsForQuery:(NSString *)query completionBlock:(NSArrayBlock)completionBlock {
    NSString *suggestionURL = [[self urlForProducts] stringByAppendingFormat:@"suggest?term=%@&max=10", query];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:suggestionURL completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil);
                                });
                        }

                        return;
                    }

                    NSMutableArray *results = [[NSMutableArray alloc] init];

                    for (NSDictionary *d in[dict objectForKey:@"suggestions"]) {
                        [results addObject:[d objectForKey:@"value"]];
                    }

                    BOOL success = results.count ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (results);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil);
                            });
                    }
                }
            }
        }];
}

- (void)storesAtLocation:(CLLocation *)location withCurrentPage:(NSInteger) currentPage  radius:(float)radius completionBlock:(NSDictionaryNSErrorBlock)completionBlock {
    float accuracy = 500;
    NSString *storeSearchURL = [[self urlForStores] stringByAppendingFormat:@"?longitude=%@&latitude=%@&radius=%@&accuracy=%@&options=HOURS&currentPage=%i",
                                [NSString stringWithFormat:@"%f", location.coordinate.longitude],
                                [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                                [NSString stringWithFormat:@"%f", radius],
                                [NSString stringWithFormat:@"%f", accuracy],
                                currentPage
        ];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:storeSearchURL completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"stores"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

- (void)storesWithQueryString:(NSString *)query withCurrentPage:(NSInteger) currentPage completionBlock:(NSDictionaryNSErrorBlock)completionBlock{
    NSString *storeSearchURL = [[self urlForStores] stringByAppendingFormat:@"?query=%@&options=HOURS&currentPage=%i", query,currentPage];

    (void)[[HYWebServiceDataProvider alloc] initWithURL:storeSearchURL completionBlock:^(NSData *jsonData, NSError *error) {
            if (completionBlock) {
                if (error) {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                        });
                    return;
                }

                if (jsonData) {
                    NSError *jsonError;

                    NSDictionary *dict =
                        [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&
                            jsonError]];

                    if (jsonError) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, jsonError);
                                });
                        }

                        return;
                    }

                    BOOL success = [dict objectForKey:@"stores"] ? YES:NO;

                    if (success) {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (dict, error);
                                });
                        }
                    }
                    else {
                        if (completionBlock) {
                            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, [NSError errorWithDomain:@"com.hybris" code:1 userInfo:dict]);
                                });
                        }
                    }
                }
                else {
                    if (completionBlock) {
                        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil, error);
                            });
                    }
                }
            }
        }];
}

@end
