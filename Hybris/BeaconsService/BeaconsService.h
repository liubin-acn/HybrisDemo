//
//  BeaconsService.h
//  Hybris
//
//  Created by zhang xiaodong on 14-11-12.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESTBeacon.h"

@interface BeaconsService : NSObject

+ (id)sharedBeaconsService;

- (void)startRangingBeaconsWithUUID:(NSUUID *)uuid
                         identifier:(NSString *)identifier
          rangingBeaconsHandler:(void (^)(NSArray *beacons, NSError *error))handler;

- (void)stopRangingBeacons;

@end
