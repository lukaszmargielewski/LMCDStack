//
//  NSFetchedResultsController+LMCDStack.h
//  Zen
//
//  Created by Lukasz Margielewski on 09/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LMCDStackSort : NSObject

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, assign, readonly) BOOL ascending;

+ (instancetype)sort:(NSString *)key
                 asc:(BOOL)ascending;

@end

@interface NSFetchedResultsController(LMCDStack)

+ (instancetype)controllerForEntity:(Class)entityClass
                          predicate:(NSPredicate *)predicate
                            context:(NSManagedObjectContext *)context
                    sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

+ (instancetype)controllerForEntity:(Class)entityClass
                          predicate:(NSPredicate *)predicate
                            context:(NSManagedObjectContext *)context
              simpleSortDescriptors:(NSArray<LMCDStackSort *> *)sortDescriptors
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

@end

