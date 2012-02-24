//
//  NSDate+FakeTime.h
//  Saturn
//
//  Created by Brian King on 12/16/11.
//  Copyright 2011 AgaMatrix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate(FakeForTest)

+ (void)setDateOffsetForTimeInterval:(NSTimeInterval)timeInterval;
+ (void)setDateOffsetForDate:(NSDate *)date;

+ (void)setTimeInterval:(NSTimeInterval)timeInterval withTimeZone:(NSString *)abbreviation;

+ (NSDate *)date;

@end


@interface NSTimeZone(FakeForTest)

+ (void)changeDefaultTimeZoneFromAbbreviation:(NSString *)abbreviation;

@end


@interface NSLocale(FakeForTest)

+ (void)setPreferredLanguages:(NSArray *)languages;

@end