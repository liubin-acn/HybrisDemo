//
//  HYWebViewController.m
//  Hybris
//
//  Created by Accenture on 14-11-12.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import "HYWebViewController.h"

@interface HYWebViewController ()

@end

@implementation HYWebViewController

static NSString *JSHandler;

+ (void)initialize {
    JSHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ajax_handler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Product";
    
    [self loadWebPageWithString:self.urlString];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebPageWithString:(NSString *)urlString
{
    // test url start
    NSMutableString *urlR = [NSMutableString stringWithString:urlString];
    [urlR replaceCharactersInRange:NSMakeRange(7, 14) withString:@"4f7c5445.ngrok.com"];
    [urlR appendString:@"?site=electronics&clear=true"];
    // test url end
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlR]];
    [self.qrWebView loadRequest:request];
}

- (void)addToCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HYItemAddedToCart object:nil];
}

- (void)updateCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HYItemRemovedFromCart object:nil];
}

#pragma --mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [request.URL absoluteString];
    
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 2 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"addtocartapp"])
    {
        [self addToCart];
        
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self waitViewShow:YES];
    [webView stringByEvaluatingJavaScriptFromString:JSHandler];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self waitViewShow:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self waitViewShow:NO];
    
    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alterview show];
}

#pragma --mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
