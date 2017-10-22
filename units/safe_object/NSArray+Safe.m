//
//  NSArray+Safe.m
//
//

#import "NSArray+Safe.h"

#import <objc/runtime.h>

@implementation NSArray (Safe)

+ (void)load
{
//    Method originalMethod = class_getInstanceMethod(self, @selector(objectAtIndex:));
//    Method swizzledMethod = class_getInstanceMethod(self, @selector(safe_objectAtIndex:));
//    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (id)safe_objectAtIndex:(NSUInteger)index
{
    return index > self.count ? nil: [self objectAtIndex:index];
}




@end
