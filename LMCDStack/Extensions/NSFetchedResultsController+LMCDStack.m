//
//  NSFetchedResultsController+LMCDStack.m
//  Zen
//
//  Created by Lukasz Margielewski on 09/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import "NSFetchedResultsController+LMCDStack.h"

@interface LMCDStackSort()
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, assign, readwrite) BOOL ascending;
@end

@implementation LMCDStackSort

+ (instancetype)sort:(NSString *)key asc:(BOOL)ascending {
    
    LMCDStackSort *sort = [[LMCDStackSort alloc] init];
    sort.key = key;
    sort.ascending = ascending;
    
    return sort;
}

@end


@implementation NSFetchedResultsController(LMCDStack)

+ (instancetype)controllerForEntity:(Class)entityClass
                          predicate:(NSPredicate *)predicate
                            context:(NSManagedObjectContext *)context
              simpleSortDescriptors:(NSArray<LMCDStackSort *> *)sortDescriptors
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    
    NSMutableArray <NSSortDescriptor *>*_sortDescriptors = nil;
    
    if (sortDescriptors && sortDescriptors.count) {
        
        _sortDescriptors = [[NSMutableArray alloc] initWithCapacity:sortDescriptors.count];
        
        for (LMCDStackSort *sort in sortDescriptors) {
            NSSortDescriptor *sss = [[NSSortDescriptor alloc] initWithKey:sort.key ascending:sort.ascending];
            [_sortDescriptors addObject:sss];
        }
        
    }
    return [NSFetchedResultsController controllerForEntity:entityClass
                                                 predicate:predicate
                                                   context:context
                                           sortDescriptors:_sortDescriptors
                                               sectionName:sectionName
                                                 cacheName:cacheName
                                                 batchSize:batchSize
                                                  delegate:delegate];
}


+ (instancetype)controllerForEntity:(Class)entityClass
                          predicate:(NSPredicate *)predicate
                            context:(NSManagedObjectContext *)context
                    sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<NSFetchedResultsControllerDelegate>)delegate {

    
    NSString *entityName = NSStringFromClass(entityClass);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest * _fetchRequest = [[NSFetchRequest alloc] init];
    
    [_fetchRequest setPredicate:predicate]; // No predicate means all antries
    [_fetchRequest setEntity:entity];
    [_fetchRequest setSortDescriptors:sortDescriptors];
    [_fetchRequest setFetchBatchSize:batchSize];
    
    NSFetchedResultsController *_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:context sectionNameKeyPath:sectionName cacheName:cacheName];
    _fetchedResultsController.delegate = delegate;
    
    return _fetchedResultsController;

}
@end
