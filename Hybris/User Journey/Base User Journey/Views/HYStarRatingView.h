//
// HYStarRatingView.h
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

#import <UIKit/UIKit.h>

@interface HYStarRatingView:UIView
@property (nonatomic, strong) UIImage *starImage;
@property (nonatomic, strong) UIImage *inactiveStarImage;

@property (nonatomic) float starSpacing;
@property (nonatomic) float nonStarAlpha;

@property (nonatomic) float ratingValue;
@property (nonatomic) int maxStars;

@end
