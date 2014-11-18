//
// HYURLSchemeControllerError.m
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

#import "HYURLSchemeControllerError.h"


@implementation HYURLSchemeControllerError

#pragma mark - Init

- (id)initWithErrorTitle:(NSString *)errorTitle andErrorMessage:(NSString *)errorMessage {
    if (self = [super init]) {
        self.errorTitle = errorTitle;
        self.errorMessage = errorMessage;
    }
    
    return self;
}

@end
