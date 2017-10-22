//
//  NSMutableArray+Safe.h
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)

- (void)safe_addObject:(id)anObject;
- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)safe_removeLastObject;
- (void)safe_removeObjectAtIndex:(NSUInteger)index;
- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end
