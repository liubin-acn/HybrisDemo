//
// HYAllReviewsCell.m
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

#import "HYAllReviewsCell.h"

@implementation HYAllReviewsCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.showReviewsLabel.text = @"";
    self.showReviewsLabel.font = UIFont_detailFont;
    self.showReviewsLabel.textColor = UIColor_textColor;
    self.showReviewsLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    
    self.averageRatingsLabel.text = @"";
    self.averageRatingsLabel.font = UIFont_detailMediumFont;
    self.averageRatingsLabel.textColor = UIColor_textColor;
    self.averageRatingsLabel.highlightedTextColor = UIColor_lightBlueTextTint;

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];

    // Indicator
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        // Initialization code
    }

    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // Re-set the background color of the line
    for (UIView *v in self.selectedBackgroundView.subviews) {
        v.backgroundColor = UIColor_dividerBorderColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)decorateCellWithProduct:(HYProduct *)product {
    self.starView.ratingValue = [product.averageRating intValue];
    int averageRating = [product.averageRating intValue];
    self.averageRatingsLabel.text = [NSString stringWithFormat:@"%i/5", averageRating];
    self.showReviewsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Show Customer Reviews", @"Show customer reviews in product detail view.")];
}


@end
