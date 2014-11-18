//
// HYProductShareCell.m
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


#import "HYProductShareCell.h"


@implementation HYProductShareCell

@synthesize tweetButton;
@synthesize facebookPostButton;
@synthesize mailButton;


- (void)setup {
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColor_standardTint;
    
    // Localized strings for button titles
    [self.tweetButton setTitle:NSLocalizedStringWithDefaultValue(@"Twitter", nil, [NSBundle mainBundle], @"Twitter",
                                                                 @"Twitter button title") forState:UIControlStateNormal];
    [self.facebookPostButton setTitle:NSLocalizedStringWithDefaultValue(@"Facebook", nil, [NSBundle mainBundle], @"Facebook",
                                                                        @"Facebook button title") forState:UIControlStateNormal];
    [self.mailButton setTitle:NSLocalizedStringWithDefaultValue(@"Mail", nil, [NSBundle mainBundle], @"Mail",
                                                                @"Mail button title") forState:UIControlStateNormal];
    
    
    [self.tweetButton setTitleColor:UIColor_textColor forState:UIControlStateNormal];
    [self.facebookPostButton setTitleColor:UIColor_textColor forState:UIControlStateNormal];
    [self.mailButton setTitleColor:UIColor_textColor forState:UIControlStateNormal];
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


@end
