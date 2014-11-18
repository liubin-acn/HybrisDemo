//
// HYCheckoutNormalCell.m
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

#import "HYCheckoutNormalCell.h"

@interface HYCheckoutNormalCell ()
@property (nonatomic, weak) IBOutlet UIImageView *pencilIndicator;

@end

@implementation HYCheckoutNormalCell

- (void)setup {
    [super setup];
    self.label.font = UIFont_informationLabelFont;
    
    // Selected state
    self.textLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    UIView *backgroundSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    backgroundSeparatorView.backgroundColor = UIColor_dividerBorderColor;
    [self.selectedBackgroundView addSubview:backgroundSeparatorView];
    
    // Indicator
//    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"] highlightedImage:[UIImage imageNamed:@"disclosure-on.png"]];
    
    // Hide lines
    self.separatorLine.hidden = YES;
    self.highlightedSeparatorLine.hidden = YES;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id) init {
    
    [self setup];
    
    return [super init];
}

- (void) decorateCellLabelWithContents:(id)contents {
    [super decorateCellLabelWithContents:contents];
    
    [self.contentView.layer setCornerRadius:7];
    [self.contentView.layer setBorderWidth:1.0f];

    if (((NSArray *)contents).count > 1) {
        self.pencilIndicator.hidden = NO;
        self.accessoryView.hidden = YES;
        [self.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
    }
    else {
        self.pencilIndicator.hidden = YES;
        self.accessoryView.hidden = NO;
        [self.contentView.layer setBorderColor:UIColor_brandTextColor.CGColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // Keep the line hidden
    for (UIView *v in self.selectedBackgroundView.subviews) {
        v.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
