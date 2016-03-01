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

@class LMCDStackFetchResultsController;

@protocol LMCDStackFetchResultsControllerDelegate <NSObject, UITableViewDataSource, UICollectionViewDataSource>

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

@property (nonatomic, assign, readonly) NSManagedObjectContext          *context;

@property (nonatomic, strong, readonly) NSFetchRequest                  *fetchRequest;
@property (nonatomic, strong, readonly) NSFetchedResultsController      *fetchedResultsController;
@property (nonatomic, strong, readonly) NSString                        *sectionName;
@property (nonatomic, strong, readonly) NSString                        *entityName;
@property (nonatomic, strong, readonly) NSArray                         *sortDescriptors;
@property (nonatomic, strong) NSPredicate                               *predicate;
@property (nonatomic, readonly) NSUInteger                              batchSize;


@property (nonatomic, assign) UICollectionView                          *collectionView;
@property (nonatomic, assign) UITableView                               *tableView;

@property (nonatomic, strong) NSString                                  *name;

-(void)fetchData;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initForEntityName:(NSString *)entityName
                          context:(NSManagedObjectContext *)context
                      sectionName:(NSString *)sectionName
                  sortDescriptors:(NSArray *)sortDescriptors
                        batchSize:(NSUInteger)batchSize
                         delegate:(id<LMCDStackFetchResultsControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

+ (instancetype)controllerForEntityName:(NSString *)entityName
                                context:(NSManagedObjectContext *)context
                            sectionName:(NSString *)sectionName
                        sortDescriptors:(NSArray *)sortDescriptors
                              batchSize:(NSUInteger)batchSize
                               delegate:(id<LMCDStackFetchResultsControllerDelegate>)delegate;


@end
