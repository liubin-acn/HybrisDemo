//
//  NSArray+Utilities.h
//  Hybris
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

/**
 * Sanitises and array or one-key doctionary into an array
 **/
+ (NSArray *)arrayFromCollection:(id)collection;


/** 
 * Write a plist to disk
 **/
- (BOOL)writeToPlistFile:(NSString *)filename;

/** 
 * Read a plist from disk
 **/
+ (NSArray *)readFromPlistFile:(NSString *)filename;

@end
