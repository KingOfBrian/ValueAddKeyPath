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
- (BOOL)isNotAnimating;

/*
 * See if the frame in the window's coordinates is in the windows frame.
 */
- (BOOL)isOnScreen;
   
@end

@interface NSObject(ValueAddLookupHelpers)
/*
 * Given a heirarchy, flatten the heirarchy represented by the key.
 *  - So [view flattenByKey:@"subviews"] or [layer flattenByKey:@"sublayers"]
 *  - Or [view flattenByKey:@"superview"] or [layer flattenByKey:@"superlayer"]
 */
- (NSArray *)flattenByKey:(NSString *)key;

@end

@interface NSArray(ValueAddLookupHelpers)

- (id)firstObject;

/*
 * Key Path helper for flattenByKey.   Allows you to write:
 * - [[UIApplication sharedApplication] valueAddKeyPath:@"windows.@flattenBy.subviews"]
 */
- (id)flattenBy;

@end
