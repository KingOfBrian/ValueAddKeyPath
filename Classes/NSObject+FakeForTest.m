//
//  NSDate+FakeTime.m
//  Saturn
//
//  Created by Brian King on 12/16/11.
//  Copyright 2011 AgaMatrix, Inc. All rights reserved.
//

#import "NSObject+FakeForTest.h"

static NSTimeInterval _global_time_offset = 0;

@implementation NSDate(FakeForTest)

+ (void)setDateOffsetForTimeInterval:(NSTimeInterval)timeInterval
{
    NSTimeInterval currentTimeInterval = CFAbsoluteTimeGetCurrent();
    
    _global_time_offset = currentTimeInterval - timeInterval;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationSignificantTimeChangeNotification
                                                        object:[UIApplication sharedApplication]
                                                      userInfo:nil];
}

+ (void)setDateOffsetForDate:(NSDate *)date
{
    [self setDateOffsetForTimeInterval:[date timeIntervalSinceReferenceDate]];
}

+ (NSDate *)date
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent() - _global_time_offset];
}

+ (void)setTimeInterval:(NSTimeInterval)timeInterval withTimeZone:(NSString *)abbreviation;
{
    NSDate *newTime = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:abbreviation];
    
    [self setDateOffsetForTimeInterval:timeInterval - [timeZone secondsFromGMTForDate:newTime]];
    
    [NSTimeZone setDefaultTimeZone:timeZone];
}

@end


@implementation NSTimeZone(FakeTimeZone)

+ (void)changeDefaultTimeZoneFromAbbreviation:(NSString *)abbreviation
{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:abbreviation];
    [self setDefaultTimeZone:timeZone];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationSignificantTimeChangeNotification
                                                        object:[UIApplication sharedApplication]
                                                      userInfo:nil];
}

@end


@implementation NSLocale(FakeForTest)

+ (void)setPreferredLanguages:(NSArray *)languages
{
    if (languages == nil || [languages isKindOfClass:[NSNull class]])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppleLanguages"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
}

@end

