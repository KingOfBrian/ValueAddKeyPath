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
- (id)valueAddKeyPaths:(NSArray *)advKeyPaths
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[advKeyPaths count]];
    for (NSString *subKeyPath in advKeyPaths)
    {
        id subValue = [self valueAddKeyPath:subKeyPath];
        if (subValue)
            [results addObject:subValue];
    }
    return results;
}


- (id)valueAddKeyPath:(NSString *)advKeyPath
{
    NSScanner *scanner = [NSScanner scannerWithString:advKeyPath];
    NSString *thisKey = nil;
    NSString *remainingKeyPath = nil;
    BOOL isOperation = [scanner scanString:@"@" intoString:NULL];
    
    NSString *predicateString = nil;
    NSString *groupString = nil;
    id result = nil;
    
    if ([scanner scanString:@"{" intoString:NULL])
    {
        BOOL ok = [scanner scanUpToString:@"}" intoString:&groupString];
        if (!ok)
            [NSException raise:NSInvalidArgumentException format:@"Key Value Group Not Closed %@ (%@)", advKeyPath, thisKey];
        
        NSArray *components = [groupString componentsSeparatedByString:@","];
        return [self valueAddKeyPaths:components];
    }
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

- (id)valueAddKeyPath:(NSString *)advKeyPath
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:[self count]] autorelease];
    for (id subResult in self)
    {
        id newResult = [subResult valueAddKeyPath:advKeyPath];
        if (newResult)
            [array addObject:newResult];
    }
    return array;
}

- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate
{
    NSArray *result = [self filteredArrayUsingPredicate:predicate];
    if ([result count] == 0)
        return nil;
    return result;
}

@end

@implementation NSSet(ValueAddKeyPath)

- (id)valueAddKeyPath:(NSString *)advKeyPath
{
    NSMutableSet *set = [[[NSMutableSet alloc] initWithCapacity:[self count]] autorelease];
    for (id subResult in self)
    {
        id newResult = [subResult valueAddKeyPath:advKeyPath];
        if (newResult)
            [set addObject:newResult];
    }
    return set;
}


- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate
{
    NSSet *result = [self filteredSetUsingPredicate:predicate];
    if ([result count] == 0)
        return nil;
    return result;
}



@end


