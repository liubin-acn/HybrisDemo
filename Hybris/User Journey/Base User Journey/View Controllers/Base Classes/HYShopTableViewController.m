//
// HYShopTableViewController.m
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

#import "HYShopTableViewController.h"


@interface HYShopTableViewController ()

@property (nonatomic, strong) NSString *site;

/// Set to yes once the view has received a response
@property (nonatomic) BOOL hasData;


-(void)siteChanged:(NSNotification*)note;

- (void)fetchData;

@end


@implementation HYShopTableViewController


#pragma mark - View Lifecyle

- (void)awakeFromNib {
    self.site = [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addObservers];    
    [self siteChanged:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self removeObservers];
    
    [super viewWillDisappear:animated];
}



#pragma mark - Helper Methods

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)addObservers {    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteChanged:) name:HYSiteChangedNotification object:nil];
}


-(void)siteChanged:(NSNotification*)note {
    if (![self.site isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"]]) {
        if (self.site != nil) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            self.site = [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"];
            self.hasData = NO;
            [self fetchData];
        } else {
            self.site = [[NSUserDefaults standardUserDefaults] stringForKey:@"web_services_site_url_suffix_preference"];
        }
    }
}

- (void)fetchData {
}

@end
