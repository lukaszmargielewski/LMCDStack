//
//  HITCalendarMonthFetchController.m
//  HIT
//
//  Created by Lukasz Margielewski on 21/01/14.
//
//

#if  DEBUG
#define DLog(format, ...) NSLog((@"%s [Line %d]: " format), __PRETTY_FUNCTION__, __LINE__,## __VA_ARGS__)
#else
#define DLog(format, ...) while(0){}
#endif


#import "LMCDStackFetchResultsController.h"

@implementation LMCDStackFetchResultsController{
    
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
    __block BOOL updated, downloaded, fetching, initial_fetch_attampted;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize fetchRequest = _fetchRequest;
@synthesize entityName = _entityName;
@synthesize sectionName = _sectionName;
@synthesize context = _context;
@synthesize sortDescriptors = _sortDescriptors;

#pragma mark - Init & setup:

-(void)setCollectionView:(UICollectionView *)collectionView{

    _collectionView = collectionView;
    _collectionView.dataSource = self;
}
- (void)setTableView:(UITableView *)tableView{

    _tableView = tableView;
    _tableView.dataSource = self;
}

#pragma mark - Fetch Results Controller:


+ (instancetype)controllerForEntityName:(NSString *)entityName
                                context:(NSManagedObjectContext *)context
                            sectionName:(NSString *)sectionName
                        sortDescriptors:(NSArray *)sortDescriptors
                              batchSize:(NSUInteger)batchSize
                               delegate:(id<LMCDStackFetchResultsControllerDelegate>)delegate{

    LMCDStackFetchResultsController *ccc = [[LMCDStackFetchResultsController alloc] initForEntityName:entityName
                                                                                              context:context
                                                                                          sectionName:sectionName
                                                                                      sortDescriptors:sortDescriptors
                                                                                            batchSize:batchSize
                                                                                             delegate:delegate];
    return ccc;
}

- (instancetype)initForEntityName:(NSString *)entityName
                          context:(NSManagedObjectContext *)context
                      sectionName:(NSString *)sectionName
                  sortDescriptors:(NSArray *)sortDescriptors
                        batchSize:(NSUInteger)batchSize
                         delegate:(id<LMCDStackFetchResultsControllerDelegate>)delegate{

    
    self = [super init];
    
    if (self) {
        

        _objectChanges  = [NSMutableArray array];
        _sectionChanges = [NSMutableArray array];
        
        _entityName     = entityName;
        _context        = context;
        _sectionName    = sectionName;
        _sortDescriptors = sortDescriptors;
        _batchSize      = batchSize;
        _delegate       = delegate;
        
    }
    
    return self;
    
}

-(NSFetchRequest *)fetchRequest{

    if (!_fetchRequest) {

        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.context];
        
        _fetchRequest = [[NSFetchRequest alloc] init];

        if (_sortDescriptors && _sortDescriptors.count) {
            _fetchRequest.sortDescriptors = _sortDescriptors;
        }
        [_fetchRequest setPredicate:self.predicate]; // No predicate means all antries
        [_fetchRequest setEntity:entity];
        [_fetchRequest setFetchBatchSize:_batchSize];
    }
    
    return _fetchRequest;
}
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.context sectionNameKeyPath:_sectionName cacheName:self.name];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}


#pragma mark - Fetching:

-(void)prepeareFetchRequst{
    

}
-(void)didFetchData{
    
    
    if (self.collectionView) {
        
            [_collectionView reloadData];
            
        }
    
    if (self.tableView) {
        
            [_tableView reloadData];
        }
    
    if (_delegate && [_delegate respondsToSelector:@selector(LMCDStackFetchResultsControllerDidFetchData:)]) {
        
        [_delegate LMCDStackFetchResultsControllerDidFetchData:self];
        
    }
}
-(void)performFetch{

    NSError *error = nil;
    
    [self prepeareFetchRequst];
    
    @try {
        
        if (self.fetchedResultsController && ![self.fetchedResultsController performFetch:&error]) {
            
            DLog(@"Unresolved error in fetchData %@", error);
        }
        
    }
    @catch (NSException *exception) {
        DLog(@"Fetching exception: %@", exception);
    }
    @finally {
        
    }
    if (!initial_fetch_attampted)initial_fetch_attampted = YES;
    fetching = NO;
    
    [self didFetchData];
}
-(void)fetchData{
    
    if (fetching)return;
    fetching = YES;
    [self performFetch];
    
    
}


#pragma mark -  UICollectionView & UITableView Data Source:

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self.fetchedResultsController sections] count];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if(_delegate && [_delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
    
        return [_delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    
    return nil;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        
        return [_delegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
        
    }
    return nil;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
        return [self.fetchedResultsController sections].count;
 
}
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];

}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString *sectionTitle = [sectionInfo name];
    return sectionTitle;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.fetchedResultsController.sections count]];
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
        NSString *sectionTitle = [sectionInfo name];
        
        if (sectionTitle) {
            [array addObject:sectionTitle];
        }
        
    }
    return array;
    
    return [self.fetchedResultsController sectionIndexTitles];
}
- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    // tell table which section corresponds to section title/index (e.g. "B",1))
    
    if ([title isEqualToString:@"Æ"]) {
        title = @"\u2206";
    } else if ([title isEqualToString:@"Ø"]) {
        title = @"\u0178";
    } else if ([title isEqualToString:@"Å"]) {
        title = @"\u2248";
    }
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        
        [_delegate tableView:tableView cellForRowAtIndexPath:indexPath];
        
    }
    return nil;

}
#pragma mark - Fetch controller delegate:


- (void)willChangeContent:(NSFetchedResultsController *)controller {

	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    UITableView *tableView = self.tableView;
	if(tableView)[tableView beginUpdates];
    
    if (_delegate && [_delegate respondsToSelector:@selector(LMCDStackFetchResultsController:willChangeContent:)]) {
        
        [_delegate LMCDStackFetchResultsController:self willChangeContent:self.fetchedResultsController];
    }
    
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            change[@(type)] = @(sectionIndex);
            if(tableView)[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            change[@(type)] = @(sectionIndex);
            if(tableView)[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            // Nothing to do here (?)....
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            // Nothing to do here (?)....
        }
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            change[@(type)] = newIndexPath;
            
            if(tableView)[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            change[@(type)] = indexPath;
            
            if(tableView)[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            change[@(type)] = indexPath;
            
            if(tableView)[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            change[@(type)] = @[indexPath, newIndexPath];
            
            if(tableView)[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if(tableView)[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
    [_objectChanges addObject:change];
}

- (void)didChangeContent:(NSFetchedResultsController *)controller{
    
    UITableView *tableView = self.tableView;
    if(tableView)[tableView endUpdates];
   
    if (self.collectionView) {

        if ([_sectionChanges count] > 0)
        {
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _sectionChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeMove:
                            {
                                // Nothing to do here....
                            }
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
        
        if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
        {
            
            if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                [self.collectionView reloadData];
                
            } else {
                
                [self.collectionView performBatchUpdates:^{
                    
                    for (NSDictionary *change in _objectChanges)
                    {
                        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                            
                            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                            switch (type)
                            {
                                case NSFetchedResultsChangeInsert:
                                    [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeDelete:
                                    [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeUpdate:
                                    [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeMove:
                                    [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                    break;
                            }
                        }];
                    }
                } completion:nil];
            }
        }

    }
    
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
    
    if (_delegate && [_delegate respondsToSelector:@selector(LMCDStackFetchResultsController:didChangeContent:)]) {

        [_delegate LMCDStackFetchResultsController:self didChangeContent:self.fetchedResultsController];
    }
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end


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
                        sectionName:(NSString *)sectionName
                          cacheName:(NSString *)cacheName
                    sortDescriptors:(NSArray<LMCDStackSort *> *)sortDescriptors
                          batchSize:(NSUInteger)batchSize
                           delegate:(id<NSFetchedResultsControllerDelegate>)delegate {

    NSString *entityName = NSStringFromClass(entityClass);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest * _fetchRequest = [[NSFetchRequest alloc] init];
    
    if (sortDescriptors && sortDescriptors.count) {
        
        NSMutableArray <NSSortDescriptor *>*_sortDescriptors = [[NSMutableArray alloc] initWithCapacity:sortDescriptors.count];
        
        for (LMCDStackSort *sort in sortDescriptors) {
            NSSortDescriptor *sss = [[NSSortDescriptor alloc] initWithKey:sort.key ascending:sort.ascending];
            [_sortDescriptors addObject:sss];
        }
        
        _fetchRequest.sortDescriptors = _sortDescriptors;
    }
    [_fetchRequest setPredicate:predicate]; // No predicate means all antries
    [_fetchRequest setEntity:entity];
    [_fetchRequest setFetchBatchSize:batchSize];
    
    NSFetchedResultsController *_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:context sectionNameKeyPath:sectionName cacheName:cacheName];
    _fetchedResultsController.delegate = delegate;
    
    return _fetchedResultsController;
    
}
@end
