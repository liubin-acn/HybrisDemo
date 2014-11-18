//
// ModalViewControllerDelegate.h
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

#import <Foundation/Foundation.h>


/**
 *  A basic Modal View Controller protocol.
 *
 *  Implement this protocol to support basic modal view controller
 *  delegate functionality
 */
@protocol ModalViewControllerDelegate<NSObject>
@required


/**
 *  @required
 *  Request to be be dismissed by the delegate.
 */
- (void)requestDismissAnimated:(BOOL) animated sender:(id)sender;

@optional


/**
 *  @optional
 *  Use this method to pass data back to the delegate.
 */
- (void)modalViewDismissedWithInfo:(NSDictionary *)info animated:(BOOL) animated sender:(id)sender;

- (void)updateViewWithInfo:(NSDictionary *)object;

@end
