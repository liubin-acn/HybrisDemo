//
// HYCheckoutDetailsCell.m
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

#import "HYCheckoutDetailsCell.h"


#define YOFFSET 22.0
#define XOFFSET 11.0

@interface HYCheckoutDetailsCell()
- (void)setup;
@end

@implementation HYCheckoutDetailsCell

- (void)setup {
    // Selected state
    self.textLabel.highlightedTextColor = UIColor_lightBlueTextTint;
    self.normalTextlabel.highlightedTextColor = UIColor_lightBlueTextTint;
    self.boldTextlabel.highlightedTextColor = UIColor_lightBlueTextTint;
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


- (void)decorateCellLabelWithContentsAndBoldTitle:(id)contents {
    NSString *labelText = @"";
    NSString *boldString = @"";
    
    self.normalTextlabel.font = UIFont_informationLabelFont;
    self.boldTextlabel.font = UIFont_titleFont;
    
    [self.contentView.layer setCornerRadius:7];
    [self.contentView.layer setBorderWidth:1.0f];

    if (contents && [contents isKindOfClass:[NSArray class]]) {
        for (id content in contents) {
            if (content && [content isKindOfClass:[NSArray class]]) {
                if ([labelText isEmpty]) {
                    if ([content objectAtIndex:0]) {
                        boldString = [content componentsJoinedByString:@" "];
                    }
                    else {
                        labelText = [content componentsJoinedByString:@" "];
                    }
                }
                else {
                    labelText = [NSString stringWithFormat:@"\n%@", [content componentsJoinedByString:@" "]];
                }
            }
            else if (content && [content isKindOfClass:[NSString class]]) {
                if ([labelText isEmpty]) {
                    labelText = [labelText stringByAppendingString:content];
                }
                else {
                    labelText = [labelText stringByAppendingFormat:@"\n%@", content];
                }
            }
        }
    }
    else if (contents && [contents isKindOfClass:[NSString class]]) {
        labelText = contents;
    }
    
    CGSize stringSize = [labelText sizeWithFont:UIFont_titleFont
                              constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH_GROUPED, CONSTRAINED_HEIGHT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    self.boldTextlabel.text = boldString;
    self.normalTextlabel.text = labelText;
    
    float yHeight;
    if (((NSArray *)contents).count <= 1 ) {
        self.image.hidden = YES;
        self.accessoryView.hidden = NO;
        yHeight = XOFFSET;
        [self.contentView.layer setBorderColor:UIColor_brandTextColor.CGColor];
    }
    else {
        self.image.hidden = NO;
        self.accessoryView.hidden = YES;
        yHeight = YOFFSET + 10;
        [self.boldTextlabel setFrame:CGRectMake(XOFFSET, XOFFSET, CONSTRAINED_WIDTH_GROUPED, 22)];
        [self.contentView.layer setBorderColor:UIColor_dividerBorderColor.CGColor];
    }
    

    [self.normalTextlabel setFrame:CGRectMake(XOFFSET, yHeight , CONSTRAINED_WIDTH_GROUPED, stringSize.height)];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // Keep the line hidden
    for (UIView *v in self.selectedBackgroundView.subviews) {
        v.hidden = YES;
    }
}


@end
