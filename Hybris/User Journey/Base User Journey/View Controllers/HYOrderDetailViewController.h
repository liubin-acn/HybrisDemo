//
// HYOrderDetailViewController.h
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


@interface HYOrderDetailViewController : HYTableViewController

@property (weak) id<ModalViewControllerDelegate>delegate;
@property (nonatomic, strong) NSString *orderDetailID;
@property (nonatomic, strong) NSDictionary *orderDetails;

@property (weak, nonatomic) IBOutlet UIView *orderStatusView;
@property (weak, nonatomic) IBOutlet HYLabel *confirmationLabel;
@property (weak, nonatomic) IBOutlet HYLabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet HYLabel *orderStatusHeaderLabel;

@end
