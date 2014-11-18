//
// HYClassificationViewController.m
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

#import "HYClassificationViewController.h"
#import "HYProductClassificationView.h"
#import "HYProductClassificationEntry.h"

#define CONTAINER_VIEW_TAG 23

@interface HYClassificationViewController ()

@end

@implementation HYClassificationViewController

- (void)setProduct:(HYProduct *)product {
    _product = product;

    // Clear the view
    if (self.scrollView.subviews.count) {
        for (UIView *view in self.scrollView.subviews) {
            if (view.tag == CONTAINER_VIEW_TAG) {
                [view removeFromSuperview];
            }
        }
    }

    // Build the classifications
    float yOffset = 0;

    for (NSDictionary *dict in self.product.classifications) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, 44.0)];
        containerView.tag = CONTAINER_VIEW_TAG;

        HYProductClassificationView *classificationView =
            [[[NSBundle mainBundle] loadNibNamed:@"HYProductClassificationView" owner:self options:nil] objectAtIndex:0];
        classificationView.titleLabel.text = [dict objectForKey:@"name"];

        CGRectSetY(classificationView.frame, yOffset);
        logDebug(@"Heading at %f", yOffset);
        [containerView addSubview:classificationView];
        yOffset += (classificationView.frame.size.height + STANDARD_MARGIN);

        for (NSDictionary *featureDict in[dict objectForKey : @"features"]) {
            HYProductClassificationEntry *classificationEntry =
                (HYProductClassificationEntry *)[[[NSBundle mainBundle] loadNibNamed:@"HYProductClassificationEntry" owner:nil options:nil] objectAtIndex:0];

            classificationEntry.leftLabel.text = [featureDict objectForKey:@"name"];
            CGSize leftSize =
                [[featureDict objectForKey:@"name"] sizeWithFont:UIFont_smallFont constrainedToSize:CGSizeMake(150.0,
                    9999.0) lineBreakMode:NSLineBreakByWordWrapping];
            CGRectSetHeight(classificationEntry.leftLabel.frame, leftSize.height);

            NSString *trimmedString =
                [[[[featureDict objectForKey:@"featureValues"] objectAtIndex:0] objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet
                    whitespaceCharacterSet]];
            classificationEntry.rightLabel.text = trimmedString;
            CGSize rightSize = [trimmedString sizeWithFont:UIFont_smallFont constrainedToSize:CGSizeMake(150.0, 9999.0) lineBreakMode:NSLineBreakByWordWrapping];
            CGRectSetHeight(classificationEntry.rightLabel.frame, rightSize.height);

            CGRectSetHeight(classificationEntry.frame, STANDARD_MARGIN +
                MAX(classificationEntry.leftLabel.frame.size.height, classificationEntry.rightLabel.frame.size.height));
            CGRectSetY(classificationEntry.frame, yOffset);
            logDebug(@"Detail at %f", yOffset);
            [containerView addSubview:classificationEntry];

            yOffset += (classificationEntry.frame.size.height + STANDARD_MARGIN);
            [self.scrollView addSubview:containerView];
        }
    }

    self.scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, yOffset);
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}


@end
