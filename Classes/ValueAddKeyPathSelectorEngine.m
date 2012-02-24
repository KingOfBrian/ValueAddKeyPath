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

+ (void)squashValue:(id)value intoArray:(NSMutableArray *)results
{
    if ([value conformsToProtocol:@protocol(NSFastEnumeration)])
        for (id subValue in value)
        {
            [self squashValue:subValue intoArray:results];
        }
    else if (value)
        [results addObject:value];
}

+ (NSArray *) objectsForKeyPath:(NSString *)keyPath
{
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    if ([paths count] < 1)
        return [NSArray array];
    
    NSString *className = [paths objectAtIndex:0];

    id base = NSClassFromString(className);
    id result = nil;

    if (base)
    {
        if ([paths count] == 1)
            result = base;
        else
        {
            NSString *path = [[paths subarrayWithRange:NSMakeRange(1, [paths count] - 1)] componentsJoinedByString:@"."];
            result = [base valueAddKeyPath:path];
        }
    }
    else
    {
        base = [UIApplication sharedApplication];
        result = [base valueAddKeyPath:keyPath];
    }

    NSMutableArray *results = [NSMutableArray array];

    [self squashValue:result intoArray:results];

    return results;
}

- (NSArray *) selectViewsWithSelector:(NSString *)selector {
    return [[self class] objectsForKeyPath:selector];
}

@end

