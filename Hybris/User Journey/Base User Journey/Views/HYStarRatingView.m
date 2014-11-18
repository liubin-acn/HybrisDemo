//
// HYStarRatingView.m
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

@implementation HYStarRatingView

#pragma mark - Custom Accessors

- (void)setMaxStars:(int)maxStars {
    _maxStars = maxStars;
    [self setNeedsDisplay];
}


- (void)setRatingValue:(float)ratingValue {
    if ((int)ratingValue > self.maxStars) {
        _ratingValue = (float)self.maxStars;
    }
    else {
        _ratingValue = ratingValue;
    }

    [self setNeedsDisplay];
}


#pragma mark - View Lifecycle

- (void)setup {
    self.starImage = [UIImage imageNamed:@"star-gold.png"];
    self.inactiveStarImage = [UIImage imageNamed:@"star-inactive.png"];
    self.starSpacing = 1.5;
    self.nonStarAlpha = 0.1;
    self.ratingValue = 3.6;
    self.maxStars = 5;
}


- (void)awakeFromNib {
    [self setup];
}


- (HYStarRatingView *)init {
    self = [super init];

    if (self) {
        [self setup];
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    
    int xPos = rect.origin.x;
    int yPos = rect.origin.y;
    
    for (int i = 1; i <= self.maxStars; i++)
    {
        if (floorf(self.ratingValue) >= i)
        {
            [self.starImage drawAtPoint:CGPointMake(xPos,yPos)];
        }
        else if (ceilf(self.ratingValue) == i)
        {
            float onWidth = self.starImage.size.width * (self.ratingValue - floorf(self.ratingValue));
            
            
            CGRect onRect = CGRectMake(xPos, yPos,onWidth, self.starImage.size.height);
            
            if (self.inactiveStarImage)
                [self.inactiveStarImage drawAtPoint:CGPointMake(xPos,yPos) blendMode:kCGBlendModeNormal alpha:1.0f];
            else
                [self.starImage drawAtPoint:CGPointMake(xPos,yPos) blendMode:kCGBlendModeNormal alpha:self.nonStarAlpha];
            
            UIGraphicsBeginImageContext(onRect.size);
            
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeXOR);
            
            [self.starImage drawAtPoint:CGPointMake(0, 0)];
            
            UIImage * halfStar = UIGraphicsGetImageFromCurrentImageContext() ;
            
            UIGraphicsEndImageContext();
            
            [halfStar drawAtPoint:CGPointMake(xPos, yPos)];
            
        }
        else
        {
            if (self.inactiveStarImage)
                [self.inactiveStarImage drawAtPoint:CGPointMake(xPos,yPos) blendMode:kCGBlendModeNormal alpha:1.0f];
            else
                [self.starImage drawAtPoint:CGPointMake(xPos,yPos) blendMode:kCGBlendModeNormal alpha:self.nonStarAlpha];
        }
        
        xPos += self.starImage.size.width + self.starSpacing;
    }
}

@end
