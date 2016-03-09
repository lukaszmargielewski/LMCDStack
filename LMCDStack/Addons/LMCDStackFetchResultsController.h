//
//  LMCDStackFetchResultsController.h
//  HIT
//
//  Created by Lukasz Margielewski on 21/01/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "NSFetchedResultsController+LMCDStack.h"

@class LMCDStackFetchResultsController;

@protocol LMCDStackFetchResultsControllerDelegate <NSObject, UITableViewDataSource, UICollectionViewDataSource>
@optional
-(void)LMCDStackFetchResultsControllerDidFetchData:(LMCDStackFetchResultsController *)lmcdStackController;

-(void)LMCDStackFetchResultsController:(LMCDStackFetchResultsController *)lmcdStackController
                     willChangeContent:(NSFetchedResultsController *)controller;

-(void)LMCDStackFetchResultsController:(LMCDStackFetchResultsController *)lmcdStackController
                            controller:(NSFetchedResultsController *)controller
                       didChangeObject:(id)anObject
                           atIndexPath:(NSIndexPath *)indexPath
                         forChangeType:(NSFetchedResultsChangeType)type
                          newIndexPath:(NSIndexPath *)newIndexPath;

-(void)LMCDStackFetchResultsController:(LMCDStackFetchResultsController *)lmcdStackController
                            controller:(NSFetchedResultsController *)controller
                      didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
                               atIndex:(NSUInteger)sectionIndex
                         forChangeType:(NSFetchedResultsChangeType)type;

-(void)LMCDStackFetchResultsController:(LMCDStackFetchResultsController *)lmcdStackController
                      didChangeContent:(NSFetchedResultsController *)controller;

@end

@interface LMCDStackFetchResultsController : NSObject<NSFetchedResultsControllerDelegate, UITableViewDataSource, UICollectionViewDataSource>

@property (nonatomic, assign) id<LMCDStackFetchResultsControllerDelegate>delegate;

@property (nonatomic, strong, readonly) NSFetchedResultsController      *fetchedResultsController;
@property (nonatomic, assign) UICollectionView                          *collectionView;
@property (nonatomic, assign) UITableView                               *tableView;

- (void)fetchData;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)controllerForEntity:(Class)entityClass
                          predicate:(NSPredicate *)predicate
                            context:(NSManagedObjectContext *)context
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                    sortDescriptors:(NSArray<LMCDStackSort *> *)sortDescriptors
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<LMCDStackFetchResultsControllerDelegate>)delegate;


@end
