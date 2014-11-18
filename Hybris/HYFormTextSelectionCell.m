//
// HYFormTextSelectionCell.m
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


#import "HYFormTextSelectionCell.h"


@implementation HYFormTextSelectionCell

@synthesize titleLabel, currentSelectionLabel;
@synthesize values = _values;


- (void)setup {
    self.currentSelectionLabel.text = @"";
    self.titleLabel.text = @"";
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
