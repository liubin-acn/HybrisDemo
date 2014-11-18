#import <Foundation/Foundation.h>

/**
 * Plist Serialization Helper Class
 **/
@interface PListSerialisation:NSObject {
}

/** 
 * Retrieve data from a bundled plist
 **/
+ (id)dataFromBundledPlistNamed:(NSString *)filename;


/**
 * Retrieve data from a plist at a path
 **/
+ (id)dataFromPlistAtPath:(NSURL *)filePath;


/**
 * Create a plist from a string representation
 **/
+ (id)propertyListFromString:(NSString *)response;

@end
