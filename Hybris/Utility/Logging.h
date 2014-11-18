#ifndef __LOGGING__
#define __LOGGING__

#ifdef TRACE
        #define logTrace(fmt, ...) NSLog((@ "TRACE:%s%d:" fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
    #define logTrace(fmt, ...)
#endif

#ifdef DEBUG
    #define logDebug(fmt, ...) NSLog((@ "DEBUG:%s%d:" fmt), __FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
    #define logTrace(fmt, ...)
    #define logDebug(fmt, ...)
#endif

#define logInfo(fmt, ...) NSLog((@ "INFO:%s%d:" fmt), __FUNCTION__, __LINE__, ## __VA_ARGS__);
#define logWarning(fmt, ...) NSLog((@ "WARNING:%s%d:" fmt), __FUNCTION__, __LINE__, ## __VA_ARGS__);
#define logInfo2(fmt, ...) NSLog(fmt, ## __VA_ARGS__);

// In development all errors throw an assertion and crash the app.
#ifdef DEBUG

#define logError(fmt, ...) \
    NSLog((@ "ERROR:%s%d:" fmt), __FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
// otherwise log  error
#define logError(fmt, ...) NSLog((@ "ERROR:%s%d:" fmt), __FUNCTION__, __LINE__, ## __VA_ARGS__);

#endif

#define logFrameAsDebug(frame) \
    logDebug(@ "%@", [NSDictionary dictionaryWithObjectsAndKeys: \
            [NSNumber numberWithFloat: frame.origin.x], @ "x", \
            [NSNumber numberWithFloat: frame.origin.y], @ "y", \
            [NSNumber numberWithFloat: frame.size.width], @ "width", \
            [NSNumber numberWithFloat: frame.size.height], @ "height", \
            nil]);

#define logSizeAsDebug(size) \
    logDebug(@ "%@", [NSDictionary dictionaryWithObjectsAndKeys: \
            [NSNumber numberWithFloat: size.width], @ "width", \
            [NSNumber numberWithFloat: size.height], @ "height", \
            nil]);

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#define logAlert(fmt, ...) \
    if ([NSThread isMainThread]) { \
        UIAlertView *alert = [[UIAlertView alloc] \
            initWithTitle:NSLocalizedString(@ "Error", @ "Validation alert title") \
            message:[NSString stringWithFormat:fmt,   ## __VA_ARGS__] \
            delegate:self cancelButtonTitle:NSLocalizedString(@ "OK", @ "OK Message") otherButtonTitles: nil]; \
        [alert show]; \
        [alert release]; } \


#define logErrorWithAlert(alertMsg, fmt, ...) \
    logAlert(alertMsg); \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{ logError(fmt, ## __VA_ARGS__); });

#endif

#endif
