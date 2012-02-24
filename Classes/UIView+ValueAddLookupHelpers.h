//
//  UIView+LookupHelpers.h
//
//  Created by Brian King on 11/29/11.
//

#import <UIKit/UIKit.h>


@interface UIView(ValueAddLookupHelpers)

/*
 * See if the presentation and model layer are equal
 */
- (BOOL)isAnimating;

/*
 * See if the frame in the window's coordinates is in the windows frame.
 */
- (BOOL)isOnScreen;

/*
 * See if the view is tappable from the windows point of view
 */
- (BOOL)isTappable;
/*
 * Return the view 'center' in the windows cooridinate
 */
- (NSString *)centerStringInWindow;

/*
 * Tap the screen at a given point
 */
- (void)tapAtPointX:(NSInteger)x y:(NSInteger)y;


@end

@interface NSObject(ValueAddLookupHelpers)
/*
 * Given a heirarchy, flatten the heirarchy represented by the key.
 *  - So [view flattenByKey:@"subviews"] or [layer flattenByKey:@"sublayers"]
 *  - Or [view flattenByKey:@"superview"] or [layer flattenByKey:@"superlayer"]
 */
- (NSArray *)flattenByKey:(NSString *)key;
- (id)flattenBy;

/*
 * Ask if this object isKindOfClass with the class with the specified class name
 */
- (BOOL)isKindOfClassByString:(NSString *)className;
@end

@interface NSArray(ValueAddLookupHelpers)

- (id)firstObject;

/*
 * Key Path helper for flattenByKey.   Allows you to write:
 * - [[UIApplication sharedApplication] valueAddKeyPath:@"windows.@flattenBy.subviews"]
 */
- (id)flattenBy;

@end
