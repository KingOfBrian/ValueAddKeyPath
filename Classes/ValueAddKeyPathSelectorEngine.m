//
//  WSViewPredicateSelectorEngine.m
//  Saturn
//
//  Created by Brian King on 11/29/11.
//  Copyright 2011 AgaMatrix, Inc. All rights reserved.
//

#import "ValueAddKeyPathSelectorEngine.h"
#import "UIView+ValueAddLookupHelpers.h"
#import "NSObject+ValueAddKeyPath.h"

@implementation ValueAddKeyPathSelectorEngine

+(void)load {
    ValueAddKeyPathSelectorEngine *registeredInstance = [[self alloc]init];
    [SelectorEngineRegistry registerSelectorEngine:registeredInstance WithName:@"filtered_keypath"];
    [registeredInstance release];
}

+ (NSArray *) objectsForKeyPath:(NSString *)keyPath
{
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    if ([paths count] < 2)
        return [NSArray array];
    
    NSString *className = [paths objectAtIndex:0];

    id base = NSClassFromString(className);
    id result = nil;

    if (base)
    {
        NSString *path = [[paths subarrayWithRange:NSMakeRange(1, [paths count] - 1)] componentsJoinedByString:@"."];
        result = [base valueAddKeyPath:path];
    }
    else
    {
        base = [UIApplication sharedApplication];
        result = [base valueAddKeyPath:keyPath];
    }

    if ([result isKindOfClass:[NSArray class]])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self != nil"];
        return [result filteredArrayUsingPredicate:predicate];
    }
    else if (result)
        return [NSArray arrayWithObject:result];
    else 
        return [NSArray array];
}

- (NSArray *) selectViewsWithSelector:(NSString *)selector {
    return [[self class] objectsForKeyPath:selector];
}

@end

