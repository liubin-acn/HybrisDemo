//
//  BeaconsService.m
//  Hybris
//
//  Created by zhang xiaodong on 14-11-12.
//  Copyright (c) 2014年 Red Ant. All rights reserved.
//

#import "BeaconsService.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"

@interface BeaconsService() <ESTBeaconManagerDelegate, CBCentralManagerDelegate> {
    BOOL _isStarted;
}

@property (strong, nonatomic) ESTBeaconManager *beaconManager;
@property (strong, nonatomic) ESTBeaconRegion *beaconRegion;

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (copy, nonatomic) void (^rangingBeaconsHandler)(NSArray *beacons, NSError *error);

@end

@implementation BeaconsService

+ (id)sharedBeaconsService {
    static BeaconsService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[BeaconsService alloc] init];
        service.beaconManager = [[ESTBeaconManager alloc] init];
        service.beaconManager.delegate = service;
        service.centralManager = [[CBCentralManager alloc] initWithDelegate:service queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    });
    
    return service;
}

- (void)startRangingBeaconsWithUUID:(NSUUID *)uuid identifier:(NSString *)identifier rangingBeaconsHandler:(void (^)(NSArray *, NSError *))handler {
    if (_isStarted) {
        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    self.rangingBeaconsHandler = handler;
    
    [self startRangingBeacons];
}

-(void)startRangingBeacons
{
    _isStarted = YES;
    
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            [self.beaconManager requestAlwaysAuthorization];
        }
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else
    {
        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
        
        if (self.rangingBeaconsHandler) {
            NSError *error = [NSError errorWithDomain:@"You have denied access to location services. Change this in app settings." code:-1 userInfo:nil];
            self.rangingBeaconsHandler(nil, error);
        }
    }
//    else i f([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
//    {
//        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
//        
//        if (self.rangingBeaconsHandler) {
//            NSError *error = [NSError errorWithDomain:@"You have no access to location services." code:-2 userInfo:nil];
//            self.rangingBeaconsHandler(nil, error);
//        }
//    }
}

- (void)stopRangingBeacons {
    _isStarted = NO;
    
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self setRangingBeaconsHandler:nil];
    [self setBeaconRegion:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (_isStarted) {
        if (self.centralManager.state == CBCentralManagerStatePoweredOn || self.centralManager.state == CBCentralManagerStateUnauthorized) {
            [self startRangingBeacons];
        } else {
            [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
        }
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self startRangingBeacons];
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    if (self.rangingBeaconsHandler) {
        self.rangingBeaconsHandler(beacons, nil);
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    if (self.rangingBeaconsHandler) {
        self.rangingBeaconsHandler(beacons, nil);
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    if (self.rangingBeaconsHandler) {
        self.rangingBeaconsHandler(nil, error);
    }
}

@end
