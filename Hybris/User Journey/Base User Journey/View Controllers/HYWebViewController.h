//
//  HYWebViewController.h
//  Hybris
//
//  Created by Accenture on 14-11-12.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYViewController.h"

@interface HYWebViewController : UIViewController

@property (nonatomic ,weak) IBOutlet UIWebView *qrWebView;

@property (nonatomic ,strong) NSString *urlString;

@end
