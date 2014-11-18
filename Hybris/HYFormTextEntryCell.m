//
// HYFormTextEntryCell.m
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


#import "HYFormTextEntryCell.h"


@implementation HYFormTextEntryCell

@synthesize textField = _textField;


- (void)setup {
    self.textField.text = @"";
    self.messageField.text = @"";
    self.messageField.font = UIFont_smallFont;
    self.messageField.textColor = UIColor_warningTextColor;
    self.messageField.hidden = YES;
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
