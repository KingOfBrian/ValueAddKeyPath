//
//  NSObject+ValueAddKeyPath.m
//
//  Created by Brian King on 12/1/11.
//

#import "NSObject+ValueAddKeyPath.h"


@implementation NSObject(ValueAddKeyPath)

- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate
{
    [NSException raise:NSInvalidArgumentException format:@"Can not filer classes of type", [self class]];
    return nil;
}

- (id)valueAddKeyPath:(NSString *)advKeyPath
{
    NSScanner *scanner = [NSScanner scannerWithString:advKeyPath];
    NSString *thisKey = nil;
    NSString *remainingKeyPath = nil;
    BOOL isOperation = [scanner scanString:@"@" intoString:NULL];
    
    NSString *predicateString = nil;
    id result = nil;
    
    [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&thisKey];

    if ([scanner scanString:@"[[" intoString:NULL])
    {
        BOOL ok = [scanner scanUpToString:@"]]" intoString:&predicateString];
        if (!ok)
            [NSException raise:NSInvalidArgumentException format:@"Predicate Not Closed %@ (%@)", advKeyPath, thisKey];
        
        [scanner scanString:@"]]" intoString:NULL];

        if (![scanner isAtEnd])
        {
            // Gobble the . if it exists, ok if it does not.
            [scanner scanString:@"." intoString:NULL];
            remainingKeyPath = [[scanner string] substringFromIndex:[scanner scanLocation]];
        }
    } 
    else if ([scanner scanString:@"." intoString:NULL])
    {
        if ([scanner isAtEnd])
            [NSException raise:NSInvalidArgumentException format:@"Path can not end with a ."];

        remainingKeyPath = [[scanner string] substringFromIndex:[scanner scanLocation]];
    }
    
    if (isOperation)
    {
        SEL selector = NSSelectorFromString(thisKey);
        if (![self respondsToSelector:selector])
            [NSException raise:NSInvalidArgumentException format:@"%@ does not respond to %@", self, thisKey];
        
        result = [self performSelector:selector];
    }
    else
        result = [self valueForKey:thisKey];
    
    if (predicateString)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        result = [result filteredValueAddUsingPredicate:predicate];
    }

    if (remainingKeyPath)
        return [result valueAddKeyPath:remainingKeyPath];
    else
        return result;
}

@end

@implementation NSArray(ValueAddKeyPath)

- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate
{
    return [self filteredArrayUsingPredicate:predicate];
}

@end

@implementation NSSet(ValueAddKeyPath)

- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate
{
    return [self filteredSetUsingPredicate:predicate];
}



@end


