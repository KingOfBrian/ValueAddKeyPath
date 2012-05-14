//
//  UIView+LookupHelpers.m
//
//  Created by Brian King on 11/29/11.
//

#import "UIView+ValueAddLookupHelpers.h"
#import <QuartzCore/QuartzCore.h>
//#import "KIFTestStep.h"

//#import "UITouch-KIFAdditions.h"
//#import <objc/runtime.h>


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

- (id)flattenBy
{
    return [[[VAKPLookupHelper alloc] initWithTarget:self forSelector:@selector(flattenByKey:)] autorelease];
}

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


- (BOOL)isKindOfClassByString:(NSString *)className
{
    return [self isKindOfClass:NSClassFromString(className)];
}


@end




@implementation UIView(ValueAddLookupHelpers)

- (BOOL)isAnimating
{
    BOOL animating = self.layer.animationKeys != nil;
    return animating;
}

- (BOOL)isOnScreen
{
    CGRect thisFrame = [self.window convertRect:self.frame fromView:[self superview]];
    return CGRectIntersectsRect(self.window.frame, thisFrame);
}

- (BOOL)isTappable
{
    CGPoint centerPoint = [self.window convertPoint:self.center fromView:[self superview]];
    UIView *underView = [self.window hitTest:centerPoint withEvent:nil];
    return [self isTappableWithHitTestResultView:underView];
}

- (NSString *)centerStringInWindow
{
    CGPoint centerPoint = [self.window convertPoint:self.center fromView:[self superview]];
    return NSStringFromCGPoint(centerPoint);
}

- (void)tapAtPointX:(NSInteger)x y:(NSInteger)y
{
    UIView *view = nil;
    CGPoint screenPoint = CGPointMake(x,y);
    for (UIWindow *window in [[[UIApplication sharedApplication] windows] reverseObjectEnumerator]) {
        CGPoint windowPoint = [window convertPoint:screenPoint fromView:nil];
        view = [window hitTest:windowPoint withEvent:nil];
        
        // If we hit the window itself, then skip it.
        if (view == window || view == nil) {
            continue;
        }
    }
    
    // This is mostly redundant of the test in _accessibilityElementWithLabel:
    CGPoint viewPoint = [view convertPoint:screenPoint fromView:nil];
    [view tapAtPoint:viewPoint];

}

@end


@implementation UIDatePicker(ValueAddLookupHelpers)

- (void)selectDateFromTimestamp:(NSTimeInterval)timestamp
{
    [self setDate:[NSDate dateWithTimeIntervalSince1970:timestamp] animated:YES];

    for (NSObject *target in [self allTargets])
    {
        for (NSString *actionName in [self actionsForTarget:target forControlEvent:UIControlEventValueChanged])
        {
            [target performSelector:NSSelectorFromString(actionName) withObject:self];
        }
    }
}

@end

@implementation UIPickerView(ValueAddLookupHelpers)
- (NSString*)selectedTitleInComponent:(NSUInteger)component
{
    return nil;
}

- (void)selectTitle:(NSString *)title inComponent:(NSUInteger)componentIndex
{
    
    NSInteger componentCount = [self.dataSource numberOfComponentsInPickerView:self];
    NSAssert(componentIndex < componentCount, @"Invalid component");
    NSAssert([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)], @"Can only selectTitle if it delegate responds to pickerView:titleForRow:forComponent:");
    
    NSInteger rowCount = [self.dataSource pickerView:self numberOfRowsInComponent:componentIndex];
    
    for (NSInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
        
        NSString *rowTitle = [self.delegate pickerView:self titleForRow:rowIndex forComponent:componentIndex];
        
        if ([rowTitle isEqual:title]) 
        {
            [self selectRow:rowIndex inComponent:componentIndex animated:NO];
            
            if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)])
            {
                [self.delegate pickerView:self didSelectRow:rowIndex inComponent:componentIndex];
            }
            
            return;
        }
    }
    
}

@end

@implementation UISegmentedControl(ValueAddLookupHelpers)

- (void)selectSegmentAtIndex:(NSUInteger)index
{
    // Note that this will not work with un-even segment widths
    
    CGPoint point = CGPointMake(0, self.bounds.size.height / 2);
    CGFloat defaultSegmentWidth = self.bounds.size.width / [self numberOfSegments];
    
    for (NSUInteger i = 0; i < index; i++)
    {
        point.x += defaultSegmentWidth;
    }

    point.x += defaultSegmentWidth / 2;
    
    [self tapAtPoint:point];
}

@end

@implementation UIScrollView(ValueAddLookupHelpers)
- (void)scrollToTop
{
    [self scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) animated:YES];
}

- (BOOL)scrollToNextPage
{
    CGPoint offset = self.contentOffset;
    offset.y += self.bounds.size.height;

    if (offset.y < self.contentSize.height)
        [self setContentOffset:offset animated:YES];

    // Return true if there's more to scroll
    return (offset.y < self.contentSize.height);
}

@end



