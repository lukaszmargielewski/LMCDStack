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
- (NSManagedObject *)insertNewEntity:(Class)entityClass;

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

- (NSArray *)performPredicate:(NSPredicate *)predicate
                       entity:(Class)entityClass
                  sortedByKey:(NSString *)key
                     asceding:(BOOL)asceding
                 withObjectID:(BOOL)includeObjectID
               withProperties:(BOOL)includeProperties
                    properies:(NSArray *)propertiesToFetch
                   resultType:(NSFetchRequestResultType)resultType
                    batchSize:(NSUInteger)batchSize;


- (NSManagedObject *)getEntityWithName:(NSString *)entityName
                             withValue:(id)value
                                forKey:(NSString *)key;

- (NSManagedObject *)getEntity:(Class)entityClass
                     withValue:(id)value
                        forKey:(NSString *)key;

- (NSNumber *)minimumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate;

- (NSNumber *)minimumValueForKey:(NSString *)idKey
                          entity:(Class)entityClass
                       predicate:(NSPredicate *)predicate;

- (NSNumber *)maximumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate;

- (NSNumber *)maximumValueForKey:(NSString *)idKey
                          entity:(Class)entityClass
                       predicate:(NSPredicate *)predicate;

- (NSUInteger)countEntitiesWithName:(NSString *)entityName
                          predicate:(NSPredicate *)predicate;

- (NSUInteger)countEntitities:(Class)entityClass
                    predicate:(NSPredicate *)predicate;



- (BOOL)saveIfNeededAndReset:(BOOL)reset;

+ (void)displayValidationError:(NSError *)anError;

@end
