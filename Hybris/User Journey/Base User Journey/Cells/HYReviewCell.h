//
// HYReviewCell.h
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
#import "HYTableViewCell.h"


@interface HYReviewCell : HYTableViewCell

@property (weak, nonatomic) IBOutlet HYStarRatingView *starView;
@property (weak, nonatomic) IBOutlet HYLabel *title;
@property (weak, nonatomic) IBOutlet HYLabel *date;
@property (weak, nonatomic) IBOutlet HYTextView *details;
@property (weak, nonatomic) IBOutlet HYLabel *user;

- (void)decorateCellWithReview:(Review *)review;
- (CGFloat)heightForReview:(Review *)review;

+ (NSString *)cellIdentifier;

@end
