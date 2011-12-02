//
//  UIView+LookupHelpers.m
//
//  Created by Brian King on 11/29/11.
//

#import "UIView+ValueAddLookupHelpers.h"
#import <QuartzCore/QuartzCore.h>

@interface VAKPLookupHelper : NSObject
{
    id _target;
    SEL _selector;
}

- (id)initWithTarget:(id)target forSelector:(SEL)selector;

@end

@implementation VAKPLookupHelper

- (id)initWithTarget:(id)target forSelector:(SEL)selector
{
    self = [super init];
    if (self)
    {
        _target = [target retain];
        _selector = selector;
    }
    return self;
}

- (id)valueForKey:(NSString *)key
{
    return [_target performSelector:_selector withObject:key];
}

- (void)dealloc
{
    [_target release];
    [super dealloc];
}

@end

@implementation NSArray(ValueAddLookupHelpers)

- (id)firstObject
{
    if ([self count] == 0)
        return nil;

    return [self objectAtIndex:0];
}

- (id)flattenBy
{
    return [[[VAKPLookupHelper alloc] initWithTarget:self forSelector:@selector(flattenByKey:)] autorelease];
}

- (NSArray *)flattenByKey:(NSString *)key
{
    NSParameterAssert(key);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSObject *obj in self)
        [array addObjectsFromArray:[obj flattenByKey:key]];

    return array;
}


@end

@implementation NSObject(ValueAddLookupHelpers)

- (NSArray *)flattenByKey:(NSString *)key
{
    NSParameterAssert(key);
    id keyValue = [self valueForKey:key];
    NSMutableArray *results = [NSMutableArray arrayWithObject:self];

    if ([keyValue conformsToProtocol:@protocol(NSFastEnumeration)])
    {
        for (NSObject *obj in (id<NSFastEnumeration>)keyValue)
            [results addObjectsFromArray:[obj flattenByKey:key]];
        
    }
    else if (keyValue)
        [results addObjectsFromArray:[keyValue flattenByKey:key]];

    return results;
}

@end




@implementation UIView(ValueAddLookupHelpers)

- (BOOL)isNotAnimating
{
    // This could transiently become true durring an odd animation, but the chances are low
    return CGRectEqualToRect([self.layer frame], [[self.layer presentationLayer] frame]);
}

- (BOOL)isOnScreen
{
    CGRect thisFrame = [self.window convertRect:self.frame fromView:self];
    return CGRectContainsRect(self.window.frame, thisFrame);
}

@end
