//
// HYProductImageCell.m
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


#import "HYProductImageCell.h"


@implementation HYProductImageCell

@synthesize imageView;


- (void)setup {
    // Reset all fields to remove examples from storyboard
    [self.imageView setImage:[UIImage imageNamed:HYProductCellPlaceholderImage]];

    self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.backgroundView.backgroundColor = UIColor_backgroundColor;

    // Draw the lines
    UIView *separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 0.5)];
    separatorViewTop.backgroundColor = UIColor_dividerDarkColor;
    [self addSubview:separatorViewTop];
    UIView *separatorViewTopShadow = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.5, self.frame.size.width, 0.5)];
    separatorViewTopShadow.backgroundColor = UIColor_dividerLightColor;
    [self addSubview:separatorViewTopShadow];
    
    UIView *separatorViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
    separatorViewBottom.backgroundColor = UIColor_dividerDarkColor;
    [self addSubview:separatorViewBottom];
    UIView *separatorViewBottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 1.0, self.frame.size.width, 0.5)];
    separatorViewBottomShadow.backgroundColor = UIColor_dividerLightColor;
    [self addSubview:separatorViewBottomShadow];
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


- (IBAction)onPageControlValueChanged:(id)sender {
    ZZPageControl *pageControl = (ZZPageControl *)sender;

    [self.scrollingTileBar scrollToTile:pageControl.currentPage withAnimation:YES];
}


@end
