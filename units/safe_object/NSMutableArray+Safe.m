//
//  NSMutableArray+Safe.m
//
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)safe_addObject:(id)anObject
{
    if (!anObject) {
        return;
    }
    
    [self addObject:anObject];
}

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (!anObject) {
        return;
    }
    
    if (index > self.count) {
        [self addObject:anObject];
    } else {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)safe_removeLastObject
{
    if (self.count > 0) {
        [self removeLastObject];
    }
}

- (void)safe_removeObjectAtIndex:(NSUInteger)index
{
    if (index > self.count) {
        return;
    }
    
    [self removeObjectAtIndex:index];
}

- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (!anObject) {
        return;
    }
    
    if (index > self.count) {
        return;
    }
    
    [self replaceObjectAtIndex:index withObject:anObject];
}

@end
