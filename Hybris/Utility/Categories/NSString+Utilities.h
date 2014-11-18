//
//  NSString+Utilities.h
//  Hybris
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

/** 
 * Checks for a non-nil but empty string
 **/
- (BOOL)isEmpty;

/**
 * Returns a string with whitespace characters trimmed
 **/
- (NSString *)stringByTrimmingWhitespace;

@end
