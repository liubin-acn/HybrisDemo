//
// HYBasicAttributedCell.m
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


#import "HYBasicAttributedCell.h"

#define YOFFSET 11.0
#define XOFFSET 10.0


@interface HYBasicAttributedCell ()

+ (NSString *)cellLabelTextFromContents:(id)contents;

@end


@implementation HYBasicAttributedCell

- (void)setup {
    self.label.text = @"";
    self.label.font = UIFont_defaultFont;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.numberOfLines = 0;
    self.label.highlightedTextColor = UIColor_lightBlueTextTint;
    
    // Add the separator line but turn off by default
    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    _separatorLine.backgroundColor = UIColor_dividerBorderColor;
    [self addSubview:_separatorLine];
    _separatorLine.hidden = YES;
        
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    UIView *backgroundSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, self.frame.size.height - 1.0, self.frame.size.width - 20.0, 1.0)];
    backgroundSeparatorView.backgroundColor = UIColor_dividerBorderColor;
    [self.selectedBackgroundView addSubview:backgroundSeparatorView];
    _highlightedSeparatorLine = backgroundSeparatorView;
    _highlightedSeparatorLine.hidden = YES;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setup];
    }
    
    return self;
}


- (void)decorateCellLabelWithContents:(id)contents {
    NSString *labelText = [HYBasicAttributedCell cellLabelTextFromContents:contents];    
    CGSize stringSize = [labelText sizeWithFont:UIFont_titleFont
                              constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH_GROUPED, CONSTRAINED_HEIGHT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    self.label.text = labelText;
    [self.label setFrame:CGRectMake(XOFFSET, YOFFSET, CONSTRAINED_WIDTH_GROUPED, stringSize.height)];
}


+ (CGFloat)heightForCellWithContents:(id)contents {    
    return [[HYBasicAttributedCell cellLabelTextFromContents:contents] sizeWithFont:UIFont_titleFont
                 constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH_GROUPED, CONSTRAINED_HEIGHT)
                     lineBreakMode:NSLineBreakByWordWrapping].height + (YOFFSET*2);
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



#pragma mark - private methods

+ (NSString *)cellLabelTextFromContents:(id)contents {
    NSString *labelText = @"";
    
    if (contents && [contents isKindOfClass:[NSArray class]]) {
        for (id content in contents) {
            if (content && [content isKindOfClass:[NSArray class]]) {
                if ([labelText isEmpty]) {
                    labelText = [content componentsJoinedByString:@" "];
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

    return labelText;
}


@end
