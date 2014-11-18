//
//  ESTBeaconDefinitions.h
//  EstimoteSDK
//
//  Version: 2.1.5
//  Created by Marcin Klimek on 9/26/13.
//  Copyright (c) 2013 Estimote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeaconFirmwareInfoVO.h"

#define ESTIMOTE_PROXIMITY_UUID             [[NSUUID alloc] initWithUUIDString:@"A77A1B68-49A7-4DBF-914C-760D07FBB87B"]
#define ESTIMOTE_MACBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"A77A1B68-49A7-4DBF-914C-760D07FBB87B"]
#define ESTIMOTE_IOSBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"A77A1B68-49A7-4DBF-914C-760D07FBB87B"]

#define SAVED_UUIDS_KEY @"SAVED_UUIDS_KEY"

////////////////////////////////////////////////////////////////////
// Type and class definitions


typedef NS_ENUM(char, ESTBeaconPower)
{
    ESTBeaconPowerLevel1 = -30,
    ESTBeaconPowerLevel2 = -20,
    ESTBeaconPowerLevel3 = -16,
    ESTBeaconPowerLevel4 = -12,
    ESTBeaconPowerLevel5 = -8,
    ESTBeaconPowerLevel6 = -4,
    ESTBeaconPowerLevel7 = 0,
    ESTBeaconPowerLevel8 = 4
};

typedef NS_ENUM(int, ESTBeaconBatteryType)
{
    ESTBeaconBatteryTypeUnknown = 0,
    ESTBeaconBatteryTypeCR2450,
    ESTBeaconBatteryTypeCR2477
};


typedef NS_ENUM(int, ESTBeaconFirmwareState)
{
    ESTBeaconFirmwareStateBoot,
    ESTBeaconFirmwareStateApp
};

typedef NS_ENUM(int, ESTBeaconColor)
{
    ESTBeaconColorUnknown = 0,
    ESTBeaconColorMint = 1,
    ESTBeaconColorIce,
    ESTBeaconColorBlueberry,
    ESTBeaconColorWhite,
    ESTBeaconColorTransparent
};

typedef NS_ENUM(int, ESTBeaconFirmwareUpdate)
{
    ESTBeaconFirmwareUpdateNone,
    ESTBeaconFirmwareUpdateAvailable,
    ESTBeaconFirmwareUpdateNotAvailable
};

typedef NS_ENUM(int, ESTBeaconConnectionStatus)
{
    ESTBeaconConnectionStatusConnecting,
    ESTBeaconConnectionStatusConnected,
    ESTBeaconConnectionStatusDisconnected
};

typedef NS_ENUM(int, ESTBeaconPowerSavingMode)
{
    ESTBeaconPowerSavingModeUnknown,
    ESTBeaconPowerSavingModeOn,
    ESTBeaconPowerSavingModeOff,
    ESTBeaconPowerSavingModeNotAvailable,
};

typedef void(^ESTCompletionBlock)(NSError* error);
typedef void(^ESTObjectCompletionBlock)(id result, NSError* error);
typedef void(^ESTDataCompletionBlock)(NSData* result, NSError* error);
typedef void(^ESTNumberCompletionBlock)(NSNumber* value, NSError* error);
typedef void(^ESTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^ESTPowerCompletionBlock)(ESTBeaconPower value, NSError* error);
typedef void(^ESTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^ESTStringCompletionBlock)(NSString* value, NSError* error);
typedef void(^ESTProgressBlock)(NSInteger value, NSString* description, NSError* error);
typedef void(^ESTArrayCompletionBlock)(NSArray* value, NSError* error);
typedef void(^ESTFirmwareInfoCompletionBlock)(ESTBeaconFirmwareInfoVO *result, NSError* error);
typedef void(^ESTCsRegisterCompletonBlock)(NSError* error);

////////////////////////////////////////////////////////////////////
// Interface definition

@interface ESTBeaconDefinitions : NSObject

@end
