//
//  HYScannerViewController.m
//  Hybris
//
//  Created by Accenture on 14-11-10.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import "HYScannerViewController.h"
#import "HYWebViewController.h"

@interface HYScannerViewController ()

@property (strong, nonatomic) QRScanView *qrView;

@end

@implementation HYScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Scan";
    
    [self initQRView];
    
    [self initBackButton];
    
    // test url start
//    HYWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
//    webViewController.urlString = @"http://electronics.local:9001/bncstorefront/electronics/en/USD/Open-Catalogue/Cameras/Digital-Cameras/Digital-SLR/EOS-40D-body/p/1225694";
//    [self.navigationController pushViewController:webViewController animated:YES];
    // test url end
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    
    if (!titleView) {
        titleView = [[ViewFactory shared] make:[HYLabel class]];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.font = UIFont_navigationBarFont;
        titleView.textColor = UIColor_inverseTextColor;
        self.navigationItem.titleView = titleView;
    }
    
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.qrView restartCamera];
}

- (void)initQRView
{
    _qrView = [[QRScanView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_qrView];
    _qrView.delegate = self;
    [_qrView setupCamera];
}

- (void)initBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonOnClick:)];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)backButtonOnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -- mark QRScanViewDelegate
- (void)scanQRDidFinish:(NSString *)qrcode
{
    if ([qrcode hasPrefix:@"http://"] || [qrcode hasPrefix:@"https://"])
    {
        HYWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webViewController.urlString = qrcode;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:qrcode delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma -- mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.qrView restartCamera];
}


@end
