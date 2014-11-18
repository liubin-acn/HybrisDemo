//
// NSDate+Utilities.m
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

#include <xlocale.h>

#define ISO8601_MAX_LEN 25

@implementation NSDate (Utilities)

- (BOOL)isToday {
    return [self isSameDayAsDate:[NSDate date]];
}


- (BOOL)isYesterday {
    return [self isSameDayAsDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24]];
}


- (BOOL)isSameDayAsDate:(NSDate *)date {
    const NSUInteger dateFlags = NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    const NSCalendar *const calendar = [NSCalendar currentCalendar];

    const NSDateComponents *const selfDateComp = [calendar components:dateFlags fromDate:self];
    const NSDateComponents *const dateDateComp = [calendar components:dateFlags fromDate:date];

    return [selfDateComp day] == [dateDateComp day]
           && [selfDateComp month] == [dateDateComp month]
           && [selfDateComp year] == [dateDateComp year];
}


- (NSString *)timeAsString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:self];
}


- (NSString *)dateAsString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];

    return [formatter stringFromDate:self];
}


- (NSString *)dateAndTimeAsString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:self];
}


- (NSString *)wordedDurationSince:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
        NSSecondCalendarUnit | NSMinuteCalendarUnit |
        NSHourCalendarUnit | NSDayCalendarUnit |
        NSMonthCalendarUnit | NSYearCalendarUnit
        fromDate:date
        toDate:self
        options:0];

    NSString *duration;

    if (components.year > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.year, NSLocalizedString(@"years", @"")];
    }
    else if (components.year > 0) {
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"year", @"")];
    }
    else if (components.month > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.month, NSLocalizedString(@"months", @"")];
    }
    else if (components.month > 0) {
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"month", @"")];
    }
    else if (components.day > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.day, NSLocalizedString(@"days", @"")];
    }
    else if (components.day > 0) {
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"day", @"")];
    }
    else if (components.hour > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.hour, NSLocalizedString(@"hours", @"")];
    }
    else if (components.hour > 0) {
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"hour", @"")];
    }
    else if (components.minute > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.minute, NSLocalizedString(@"mins", @"")];
    }
    else if (components.minute > 0) {
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"min", @"")];
    }
    else if (components.second > 1) {
        duration = [NSString stringWithFormat:@"%i %@", components.second, NSLocalizedString(@"secs", @"")];
    }
    else{
        duration = [NSString stringWithFormat:@"%i %@", 1, NSLocalizedString(@"sec", @"")];
    }

    return duration;
}


+ (NSDate *)dateFromISO8601String:(NSString *)iso8601 {
    if (!iso8601) {
        return nil;
    }

    const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
    char newStr[ISO8601_MAX_LEN];
    bzero(newStr, ISO8601_MAX_LEN);

    size_t len = strlen(str);

    if (len == 0) {
        return nil;
    }

    // UTC dates ending with Z
    if (len == 20 && str[len - 1] == 'Z') {
        memcpy(newStr, str, len - 1);
        strncpy(newStr + len - 1, "+0000\0", 6);
    }

    // Timezone includes a semicolon (not supported by strptime)
    else if (len == 25 && str[22] == ':') {
        memcpy(newStr, str, 22);
        memcpy(newStr + 22, str + 23, 2);
    }

    // Fallback: date was already well-formatted OR any other case (bad-formatted)
    else {
        memcpy(newStr, str, len > ISO8601_MAX_LEN - 1 ? ISO8601_MAX_LEN - 1 : len);
    }

    // Add null terminator
    newStr[sizeof(newStr) - 1] = 0;

    struct tm tm = {
        .tm_sec = 0,
        .tm_min = 0,
        .tm_hour = 0,
        .tm_mday = 0,
        .tm_mon = 0,
        .tm_year = 0,
        .tm_wday = 0,
        .tm_yday = 0,
        .tm_isdst = -1,
    };

    if (strptime_l(newStr, "%FT%T%z", &tm, NULL) == NULL) {
        return nil;
    }

    return [NSDate dateWithTimeIntervalSince1970:mktime(&tm)];
}


@end
