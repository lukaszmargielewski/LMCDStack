//
//  NSManagedObjectContext+Insert.m
//  Zen
//
//  Created by Lukasz Margielewski on 02/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import "NSManagedObjectContext+Insert.h"

@implementation NSManagedObjectContext(Insert)

- (NSManagedObject *) insertNewEntityWithName:(NSString *)name{
    NSManagedObject *object = nil;
    @try {
        object = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return object;
}
- (NSManagedObject *)insertNewEntity:(Class)entityClass {
    
    return [self insertNewEntityWithName:NSStringFromClass(entityClass)];
}


@end
