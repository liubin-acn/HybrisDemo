//
// HYOrderListCell.m
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


#import "HYOrderListCell.h"


@implementation HYOrderListCell

@synthesize orderDate;
@synthesize orderNumber;
@synthesize orderStatus;


- (void)decorateCellLabels {    
    NSString *firstLineLabelText = [NSString stringWithFormat:@"%@ - %@ (%@)", NSLocalizedString(@"Order", @"Order for order list view"), orderDate, orderNumber];
    NSString *secondLineLabelText = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Status", @"status for order list view"), orderStatus];
    
    self.firstLine.textColor = UIColor_textColor;
    self.firstLine.font = UIFont_titleFont;
    
    [self.firstLine setText:firstLineLabelText afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange orderNumberRange = [firstLineLabelText rangeOfString:[NSString stringWithFormat:@"(%@)", orderNumber]];
        
        if (orderNumberRange.location != NSNotFound) {
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)UIFont_defaultFont.fontName, UIFont_defaultFont.pointSize, NULL);
            
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:orderNumberRange];
                CFRelease(font);
            }
        }
        
        return mutableAttributedString;
    }];
    
    self.secondLine.textColor = UIColor_textColor;
    self.secondLine.font = UIFont_defaultFont;
    
    [self.secondLine setText:secondLineLabelText afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange statusRange = [secondLineLabelText rangeOfString:orderStatus];
        
        if (statusRange.location != NSNotFound) {
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)UIColor_brandTextColor.CGColor range:statusRange];
        }
        
        return mutableAttributedString;
    }];
}

@end
