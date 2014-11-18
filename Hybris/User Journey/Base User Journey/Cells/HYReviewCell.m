//
// HYReviewCell.m
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


#import "HYReviewCell.h"
#import "Review.h"


@implementation HYReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title.text = @"";
    self.date.text = @"";
    self.details.text = @"";
    self.user.text = @"";

    self.title.font = UIFont_titleFont;
    self.date.font = UIFont_smallFont;
    self.user.font = UIFont_smallBoldFont;
    self.details.font = UIFont_defaultFont;

}


- (CGFloat)heightForReview:(Review *)review {
    self.starView.ratingValue = [review.rating intValue];
    self.title.text = review.headline;
    self.date.text = [review.date dateAsString];
    self.details.text = review.comment;
    self.user.text = review.principalName;
    
    // Resize the details
    float oldHeight = self.details.frame.size.height;
    CGRectSetHeight(self.details.frame, self.details.contentSize.height);
    float newHeight = self.details.frame.size.height;
    
    // Set cell height
    CGRectAddHeight(self.frame, (newHeight - oldHeight));
    
    return self.frame.size.height;
}


- (void)decorateCellWithReview:(Review *)review {
    self.starView.ratingValue = [review.rating intValue];
    self.title.text = review.headline;
    self.date.text = [review.date dateAsString];
    self.details.text = review.comment;
    self.user.text = review.principalName;
}


+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}


@end
