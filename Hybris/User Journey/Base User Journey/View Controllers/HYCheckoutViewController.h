//
// HYCheckoutViewController.h
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

#import "HYTableViewController.h"
#import "ModalViewControllerDelegate.h"

@interface HYCheckoutViewController:HYTableViewController<ModalViewControllerDelegate>

typedef enum {
    
    DeliveryAddress = 0,
    DeliveryMode = 1,
    PaymentDetails = 2,
    Complete = 3,
    
} CheckoutMode;

@property (weak) id<ModalViewControllerDelegate>delegate;
@property (nonatomic) CheckoutMode checkOutMode;

- (IBAction)dismiss:(id)sender;

@end
