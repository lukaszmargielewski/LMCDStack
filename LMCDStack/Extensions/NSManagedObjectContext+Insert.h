//
//  NSManagedObjectContext+Insert.h
//  Zen
//
//  Created by Lukasz Margielewski on 02/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext(Insert)

- (NSManagedObject *)insertNewEntityWithName:(NSString *)name;
- (NSManagedObject *)insertNewEntity:(Class)entityClass;

@end
