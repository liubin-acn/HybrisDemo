//
// HYFacet+Factory.m
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

@implementation HYFacet (Factory)

- (BOOL)multiSelectEnabled {
    return [self.multiSelect boolValue];
}


+ (HYFacet *)objectWithInfo:(NSDictionary *)facetInfo  {
    HYFacet *facet;

    HYQuery *query = [facetInfo objectForKey:@"query"];

    @synchronized(query) {
        if (query && query.items) {
            for (id obj in query.items) {
                if ([obj isKindOfClass:[HYFacet class]] && [((HYFacet *)obj).name isEqualToString:[facetInfo objectForKey:@"name"]]) {
                    facet = obj;
                    break;
                }
            }
        }
    }
    
    if (facet == nil) {
        facet = [[HYFacet alloc] init];
        facet.creationTime = [NSDate date];
        facet.internalClass = NSStringFromClass([HYFacet class]);
        [facet setValuesForKeysWithDictionary:facetInfo];

        facet.multiSelect = [NSNumber numberWithBool:[[facetInfo valueForKey:@"multiSelect"] boolValue]];
        facet.lastPopulated = [NSDate date];

        // Make a HYFacetValue for each value
        NSMutableArray *facetValues = [NSMutableArray array];

        for (NSDictionary *facetValueDictionary in[facetInfo valueForKey : @"facetValues"]) {
            HYFacetValue *facetValue = [HYFacetValue objectWithInfo:facetValueDictionary];

            facetValue.facet = facet;

            if (query) {
                facetValue.query = query;
            }

            [facetValues addObject:facetValue];
        }

        facet.facetValues = facetValues;
    }

    return facet;
}


@end
