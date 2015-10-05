//
//  NSManagedObjectContext_queries.h
//  Roskilde
//
//  Created by Lukasz Margielewski on 21/03/2015.
//
//

#import <CoreData/CoreData.h>


@interface NSManagedObjectContext(queries)

- (NSManagedObject *)insertNewEntityWithName:(NSString *)name;

- (void)deleteManagedObjectsFromObjectContainingObjectID:(id)toDelete;
- (void)deleteManagedObjectsFromArrayContainingObjectIDs:(NSArray *)toDelete;


- (NSArray *)performPredicate:(NSPredicate *)predicate
                   entityName:(NSString *)entityName
                  sortedByKey:(NSString *)key
                     asceding:(BOOL)asceding
                 withObjectID:(BOOL)includeObjectID
               withProperties:(BOOL)includeProperties
                    properies:(NSArray *)propertiesToFetch
                   resultType:(NSFetchRequestResultType)resultType
                    batchSize:(NSUInteger)batchSize;

- (NSManagedObject *)getEntity:(NSString *)entityName withValue:(id)value forKey:(NSString *)key;

- (NSNumber *)minimumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate;

- (NSNumber *)maximumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate;

- (NSUInteger)countEntitities:(NSString *)entityName
                    predicate:(NSPredicate *)predicate;



- (BOOL)saveIfNeededAndReset:(BOOL)reset;

+ (void)displayValidationError:(NSError *)anError;
@end
