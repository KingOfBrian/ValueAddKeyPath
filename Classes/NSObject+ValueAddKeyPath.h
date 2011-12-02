//
//  NSObject+ValueAddKeyPath.h
//
//  Created by Brian King on 12/1/11.
//

#import <Foundation/Foundation.h>


@interface NSObject(ValueAddKeyPath)

- (id)valueAddKeyPath:(NSString *)advKeyPath;

// implement this to support NSPredicate Filtering on your collection objects
- (id)filteredValueAddUsingPredicate:(NSPredicate *)predicate;

@end

