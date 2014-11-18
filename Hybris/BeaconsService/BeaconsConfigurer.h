//
//  BeaconConfigure.h
//  Hybris
//
//  Created by zhang xiaodong on 14-11-13.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeacon.h"

@class BeaconsConfigurer;

@protocol BeaconConfigureDelegate <NSObject>

- (id)beaconsConfigure:(BeaconsConfigurer *)beaconsConfigure dataForBeacon:(ESTBeacon *)beacon;

@end

@interface BeaconsConfigurer : NSObject

@property (assign, nonatomic) id <BeaconConfigureDelegate> delegate;

- (id)initWithDelegate:(id)delegate;

- (id)dataForBeacon:(ESTBeacon *)beacon;

@end
