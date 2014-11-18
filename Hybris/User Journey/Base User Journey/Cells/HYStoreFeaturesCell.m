//
// HYStoreFeaturesCell.m
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


#import "HYStoreFeaturesCell.h"


@implementation HYStoreFeaturesCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.title.font = UIFont_detailBoldFont;
    self.title.textColor = UIColor_textColor;
    self.features.font = UIFont_detailFont;
    self.features.textColor = UIColor_textColor;
}


+ (CGFloat)heightForCellWithProduct:(HYStoreSearchObject *)storeObject {
    NSMutableString * features = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < [storeObject.features count]; i++) {
        [features appendString:[storeObject.features objectAtIndex:i]];
        [features appendString:@"\n"];
    }
    
    CGSize stringSize = [features sizeWithFont:UIFont_detailFont
                             constrainedToSize:CGSizeMake(CONSTRAINED_WIDTH, CONSTRAINED_HEIGHT)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    return stringSize.height + STANDARD_MARGIN + STANDARD_MARGIN + 34;
    
}


@end
