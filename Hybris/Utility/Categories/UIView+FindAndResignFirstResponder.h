//
// UIView+FindAndResignFirstResponder.h
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

#import <UIKit/UIKit.h>

@interface UIView (FindAndResignFirstResponder)

/** 
 * Searches a view's subviews to find and resign the first responder
 **/
- (BOOL)findAndResignFirstResponder;

@end
