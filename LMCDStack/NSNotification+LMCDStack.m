//
//  NSNotification+LMCDStack.m
//  Zen
//
//  Created by Lukasz Margielewski on 01/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import "NSNotification+LMCDStack.h"
#import <CoreData/CoreData.h>

@implementation NSNotification(LMCDStack)

#pragma mark - Save & Change notification Analytics:

+ (NSDictionary *)changesFromChangeNotification:(NSNotification *)notification
                               forObjectOfClass:(Class)className{
    
    
    NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:3];
    BOOL found_anything = NO;
    
    id saveInfo = [notification userInfo];
    
    NSSet *inserted = [saveInfo valueForKey:NSInsertedObjectsKey];
    NSSet *deleted = [saveInfo valueForKey:NSDeletedObjectsKey];
    NSSet *updated = [saveInfo valueForKey:NSUpdatedObjectsKey];
    NSSet *refreshed = [saveInfo valueForKey:NSRefreshedObjectsKey];
    
    NSMutableSet *items = nil;
    
    for (id object in inserted) {
        if ([object isKindOfClass:className]) {
            
            
            if (![changes valueForKey:NSInsertedObjectsKey]) {
                items = [NSMutableSet setWithCapacity:inserted.count];
                changes[NSInsertedObjectsKey] = items;
            }
            found_anything = YES;
            [items addObject:object];
        }
    }
    for (id object in deleted) {
        if ([object isKindOfClass:className]) {
            if (![changes valueForKey:NSDeletedObjectsKey]) {
                items = [NSMutableSet setWithCapacity:inserted.count];
                changes[NSDeletedObjectsKey] = items;
            }
            found_anything = YES;
            [items addObject:object];
        }
    }
    for (id object in updated) {
        if ([object isKindOfClass:className]) {
            
            if (![changes valueForKey:NSUpdatedObjectsKey]) {
                items = [NSMutableSet setWithCapacity:inserted.count];
                changes[NSUpdatedObjectsKey] = items;
            }
            found_anything = YES;
            [items addObject:object];
        }
    }
    
    for (id object in refreshed) {
        if ([object isKindOfClass:className]) {
            
            if (![changes valueForKey:NSRefreshedObjectsKey]) {
                items = [NSMutableSet setWithCapacity:inserted.count];
                changes[NSRefreshedObjectsKey] = items;
            }
            found_anything = YES;
            [items addObject:object];
        }
    }
    
    return (found_anything) ? changes : nil;
}
+ (BOOL)saveNotification:(NSNotification *)notification containsObjectOfClasses:(NSArray *)classNamesArray{
    
    for (Class className in classNamesArray) {
        BOOL contains = [self saveNotification:notification containsObjectOfClass:className];
        if (contains) {
            return YES;
        }
    }
    
    return NO;
}
+ (BOOL)saveNotification:(NSNotification *)notification containsObjectOfClass:(Class)className{
    
    
    id saveInfo = [notification userInfo];
    
    id inserted = [saveInfo valueForKey:NSInsertedObjectsKey];
    id deleted = [saveInfo valueForKey:NSDeletedObjectsKey];
    id updated = [saveInfo valueForKey:NSUpdatedObjectsKey];
    id refreshed = [saveInfo valueForKey:NSRefreshedObjectsKey];
    
    for (id object in inserted) {
        if ([object isKindOfClass:className]) {
            return YES;
        }
    }
    for (id object in deleted) {
        if ([object isKindOfClass:className]) {
            return YES;
        }
    }
    for (id object in updated) {
        if ([object isKindOfClass:className]) {
            return YES;
        }
    }
    
    for (id object in refreshed) {
        if ([object isKindOfClass:className]) {
            return YES;
        }
    }
    return NO;
}

@end
