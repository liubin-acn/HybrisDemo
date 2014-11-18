//
// ViewFactory.m
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

@interface ViewFactory ()
@property (nonatomic, readonly, strong) NSDictionary *prototypeDictionary;
@end

@implementation ViewFactory

#pragma mark - Overridable Methods

PureSingleton(ViewFactory);

+ (NSDictionary *)prototypeDictionary {
    return [[ViewFactory shared] prototypeDictionary];
}


#pragma mark - Internal Methods

NSDictionary *__prototypeDictionary = nil;
- (NSDictionary *)prototypeDictionary {
    if (__prototypeDictionary == nil) {
        __prototypeDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                [HYButton class],
                [HYLabel class],
                [HYTextView class],
                [HYProgressView class],
                [HYSearchBar class],
                [HYSectionHeader class],
                [HYFooterView class],
                [HYSearchResultsHeaderView class],
                [HYExtendedFooterView class],
                [HYStarRatingView class],
                nil]
            forKeys:[NSArray arrayWithObjects:
                [HYButton class],
                [HYLabel class],
                [HYTextView class],
                [HYProgressView class],
                [HYSearchBar class],
                [HYSectionHeader class],
                [HYFooterView class],
                [HYSearchResultsHeaderView class],
                [HYExtendedFooterView class],
                [HYStarRatingView class],
                nil]];
    }

    return __prototypeDictionary;
}


+ (ViewFactory *)viewFactoryWithPrototypes:(NSDictionary *)prototypeDictionary {
    __prototypeDictionary = prototypeDictionary;
    return [ViewFactory shared];
}


- (id)make:(Class)className {
    if ([[self.prototypeDictionary objectForKey:className] instancesRespondToSelector:@selector(init)]) {
        UIView *v = [[[self.prototypeDictionary objectForKey:className] alloc] init];
        v.backgroundColor = [UIColor clearColor];
        return v;
    }

    return nil;
}


- (id)make:(Class)className withFrame:(CGRect)frame {
    //logDebug(@"%@", self.prototypeDictionary)
    if ([[self.prototypeDictionary objectForKey:className] instancesRespondToSelector:@selector(initWithFrame:)]) {
        return [[[self.prototypeDictionary objectForKey:className] alloc] initWithFrame:frame];
    }

    return nil;
}


@end
