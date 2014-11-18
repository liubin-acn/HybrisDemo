//
// HYStoreDetailViewController.h
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

#import "HYViewController.h"
#import "HYStoreSearchObject.h"
#import "HYTableViewController.h"

@interface HYStoreDetailViewController:HYTableViewController

@property (nonatomic, retain) IBOutlet UITableViewCell *titleCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *addressCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *telephoneCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mapCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *openingCell;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *addressLabel;
@property (nonatomic, retain) IBOutlet UITextView *phoneNumberLabel;
@property (nonatomic, retain) IBOutlet UIView *phoneDisclosure;
@property (nonatomic, retain) IBOutlet UILabel *openingLabel;

@end
