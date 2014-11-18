//
//  BeaconConfigure.m
//  Hybris
//
//  Created by zhang xiaodong on 14-11-13.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import "BeaconsConfigurer.h"

@implementation BeaconsConfigurer

- (id)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (id)dataForBeacon:(ESTBeacon *)beacon {
    if ([self.delegate respondsToSelector:@selector(beaconsConfigure:dataForBeacon:)]) {
        return [self.delegate beaconsConfigure:self dataForBeacon:beacon];
    }
    return nil;
}

@end
