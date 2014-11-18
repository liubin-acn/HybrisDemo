//
// HYProductCell.m
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


#import "HYProductCell.h"


@interface HYProductCell()

@property (nonatomic, strong) UIView *lineView;

@end



@implementation HYProductCell

@synthesize imageView;
@synthesize imageBorder;
@synthesize nameLabel = _nameLabel;
@synthesize brandLabel = _brandLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize priceLabel = _priceLabel;
@synthesize stockLevelLabel = _stockLevelLabel;

- (void)setFinalCell:(BOOL)finalCell {
        self.lineView.hidden = finalCell;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // Reset all fields to remove examples from storyboard
    [self.imageView setImage:[UIImage imageNamed:@"ProductCellPlaceholder.png"]];
    [self.imageBorder setBackgroundColor:UIColor_dividerBorderColor];

    // The only way to set the highlight is to set the background image as a solid color
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor_dividerBorderColor CGColor]);
    CGContextFillRect(context, rect);
    [self.imageBorder setHighlightedImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    self.nameLabel.text = @"";
    self.nameLabel.font = UIFont_bodyFont;
    self.brandLabel.text = @"";
    self.brandLabel.font = UIFont_smallFont;
    self.descriptionLabel.text = @"";
    self.descriptionLabel.font = UIFont_smallFont;
    self.priceLabel.text = @"";
    self.stockLevelLabel.text = @"";
    self.stockLevelLabel.font = UIFont_smallBoldFont;

    self.priceLabel.font = UIFont_priceFont;

    // Line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    lineView.backgroundColor = UIColor_dividerBorderColor;
    [self addSubview:lineView];
    self.lineView = lineView;
    
    // Selected state
    self.textLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    UIView *backgroundSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    backgroundSeparatorView.backgroundColor = UIColor_dividerBorderColor;
    [self.selectedBackgroundView addSubview:backgroundSeparatorView];

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
    [super setSelected:selected animated:NO];

    if (selected && animated) {
        [UIView animateWithDuration:0.5 animations:^() {
                self.backgroundView.alpha = 0.5;
            }];
    }

    if (!selected && animated) {
        [UIView animateWithDuration:0.5 animations:^() {
                self.backgroundView.alpha = 1.0;
            }];
    }
}

@end
