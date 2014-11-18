//
// HYProductPromotionCell.m
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


#import "HYProductPromotionCell.h"


@implementation HYProductPromotionCell

- (void)setup {
    self.promotionView.text = @"";
    self.promotionView.font = UIFont_promotionFont;
    self.promotionView.textColor = UIColor_textColor;
    self.promotionView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.promotionView.delegate = self;

    self.promotionView.layer.cornerRadius = 8;
    
    // Set link attributes
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    self.promotionView.linkAttributes = linkAttributes;

    NSMutableDictionary *activeLinkAttributes = [NSMutableDictionary dictionary];
    [activeLinkAttributes setValue:(id)[UIColor_brandTextColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [activeLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    self.promotionView.linkAttributes = linkAttributes;
    self.promotionView.activeLinkAttributes = linkAttributes;
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.backgroundView.backgroundColor = UIColor_cellBackgroundColor;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
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


/// firedMessages > couldFireMessage > description
- (void)decorateCellWithProduct:(HYProduct *)product {
    [HYProduct decoratePromotionsView:self.promotionView forPromotionArray:product.potentialPromotions];
    
    CGSize stringSize = [self.promotionView.text sizeWithFont:self.promotionView.font
                                            constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH - (STANDARD_MARGIN * 4), CONSTRAINED_HEIGHT)
                                                lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRectSetHeight(self.frame, stringSize.height + STANDARD_MARGIN * 2.0);
    
    [self.promotionView setFrame:CGRectMake(STANDARD_MARGIN * 2.0,
                                            STANDARD_MARGIN,
                                            CONSTRAINED_WIDTH,
                                            stringSize.height + STANDARD_MARGIN * 2)];
    
    self.promotionView.textColor = UIColor_brandTextColor;
    self.promotionView.textInsets = UIEdgeInsetsMake(0.0, STANDARD_MARGIN * 2, 0.0, STANDARD_MARGIN * 2);
}


+ (CGFloat)heightForCellWithProduct:(HYProduct *)product {
    TTTAttributedLabel *promotionView = [[TTTAttributedLabel alloc] init];
    
    promotionView.font = UIFont_promotionFont;
    [HYProduct decoratePromotionsView:promotionView forPromotionArray:product.potentialPromotions];

    if ([promotionView.text isEmpty]) {
        return 0.0;
    }

    // Resize
    CGSize stringSize = [promotionView.text sizeWithFont:promotionView.font
        constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH - (STANDARD_MARGIN * 4), CONSTRAINED_HEIGHT)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    return stringSize.height + STANDARD_MARGIN + STANDARD_MARGIN;
}



#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}


@end
