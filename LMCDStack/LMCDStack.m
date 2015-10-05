////
//  PersonViewController.m
//  iBook
//
//  Created by Lukasz Margielewski on 10-09-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LMCDStack.h"
#import "LMCDStackConfig.h"

@interface LMCDStack ()

@end

@implementation LMCDStack{

    CFRunLoopObserverRef _runLoopObserver;

}

@synthesize mainThreadContext = _mainThreadContext, managedObjectModel = _managedObjectModel;
@synthesize backgroundThreadContext = _backgroundThreadContext;
@synthesize name = _name;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize persistentStorePath = _persistentStorePath;
@synthesize cacheDirectory = _cacheDirectory, documentsDirectory = _documentsDirectory;
@synthesize storeType = _storeType;
@synthesize version = _version;

- (void)dealloc {
	
    [self cleanBackgroundThreadContext];
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopDefaultMode);
    
}

- (instancetype)initWithName:(NSString *)name
                   storeType:(NSString *)storeType
                     version:(NSString *)version{
    
    self = [super init];
    
	if (self) {
		
        _name = name;
        _storeType = storeType ? storeType : NSSQLiteStoreType;
        _version = version;
        
        /*
        __weak CDdb *weakSelf = self;
        
        _runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL, (kCFRunLoopEntry | kCFRunLoopExit), YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity){
            
            [weakSelf runLoopEventWithObserver:observer activity:activity];
            
            });
        
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopDefaultMode);
        
        */

	}
	return self;
}


#pragma mark - Core Data Stack for Main Thread:


- (NSManagedObjectModel *)managedObjectModel {
    
    @synchronized(self){
    
        if (_managedObjectModel != nil)return _managedObjectModel;
        
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
        return _managedObjectModel;
    }
}
- (NSManagedObjectContext *)mainThreadContext{
    
    NSAssert([NSThread isMainThread], @"Trying to access main moc from NOT main thread");
    
    
    if (!_mainThreadContext) {
        
        _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainThreadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMocDidSave:) name:NSManagedObjectContextDidSaveNotification object:_mainThreadContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMocDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_mainThreadContext];
    }
    return _mainThreadContext;
    
    
    
    
    return nil;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    
    @synchronized(self) {
        
        if (_persistentStoreCoordinator == nil) {
            
            // Support lightweight datamodel migration:
            // From Core Data Migration Guide:
            
            // http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmLightweight.html#//apple_ref/doc/uid/TP40008426-SW1
            
            
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            
            
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
            
            
            NSError *error = nil;
            
            NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:_storeType configuration:nil URL:self.persistentStorePath options:options error:&error];
            
            if (error) {
                
                CDLog(@"error adding persistent store: %@", [error localizedDescription]);
                CDLog(@"tryng to hanlde error by recreating (deleteing) database file with uncompatbl version...");
                
                [self deleteDatabaseFile];
                
                persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:_storeType configuration:nil URL:self.persistentStorePath options:options error:&error];
                
                NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
                
            }
            
        }
        
        return _persistentStoreCoordinator;
        
    }
    
}


- (NSURL *)persistentStorePath {
    
    @synchronized(self){
        
        if (_persistentStorePath == nil) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            
            NSString *extension = @"sqlite";
            
            if ([_storeType isEqualToString:NSInMemoryStoreType]) {
                extension = @"memeory";
            }else if ([_storeType isEqualToString:NSBinaryStoreType]) {
                extension = @"binary";
            }
            
            
            NSString *path_in_sandbox   = [[self.documentsDirectory stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:extension];
            
            // Check if to delete database file in sandbox:
            if ([fileManager fileExistsAtPath:path_in_sandbox]) {
                
                // *info = [[NSBundle mainBundle] infoDictionary];
                NSString *defaults_key = [NSString stringWithFormat:@"DATABASE_VERSION_%@", self.name];
                NSString *storedVersion = [[NSUserDefaults standardUserDefaults] valueForKey:defaults_key];
                
                NSString *actualVersion = _version;
                
                if (![storedVersion isEqualToString:actualVersion]) {
                    
                    CDLog(@"Database version differs (%@)!!!!! -> stored version: %@ bundle version: (%@) = delete database file...", defaults_key,  storedVersion, actualVersion);
                    
                    NSError *err = nil;
                    // 1. Database main file:
                    
                    [fileManager removeItemAtPath:path_in_sandbox error:&err];
                    
                    if (err) {
                        
                        CDLog(@"Error deleting database file: %@", [err localizedDescription]);
                        
                    }else{
                        
                        CDLog(@"Database file removed successfully: %@", path_in_sandbox);
                        
                        [[NSUserDefaults standardUserDefaults] setValue:actualVersion forKey:defaults_key];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                }
            }
            
            _persistentStorePath = [NSURL fileURLWithPath:path_in_sandbox];
            
        }
        
        return _persistentStorePath;
    }
}


#pragma mark - Write Context:
- (void)cleanBackgroundThreadContext{

    if (_backgroundThreadContext) {
    
        [[NSNotificationCenter defaultCenter] removeObserver:_backgroundThreadContext];
        _backgroundThreadContext = nil;
    }
    
}
- (NSManagedObjectContext *)backgroundThreadContext{
    
    if (_backgroundThreadContext)return _backgroundThreadContext;
    
            _backgroundThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_backgroundThreadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [_backgroundThreadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mwmocDidSave:) name:NSManagedObjectContextDidSaveNotification object:_backgroundThreadContext];
            [_backgroundThreadContext setUndoManager:nil];
            
    
        return _backgroundThreadContext;

}

- (BOOL)deleteDatabaseFile{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *err = nil;
    
    // 1. Database main file:
    [fileManager removeItemAtURL:self.persistentStorePath error:&err];
    
    if (err) {
        
        CDLog(@"Error deleting database file: %@", [err localizedDescription]);
        return NO;
        
    }else{
        
        CDLog(@"Database file removed successfully: %@", path_in_sandbox);
        _persistentStorePath = nil;
    }
    
    return YES;
    
}


#pragma mark - Core Data stack MY / Multithreading support:


- (void)mwmocDidSave:(NSNotification *)saveNotification {
  
    
    
    id saveInfo = [saveNotification userInfo];
    
    
#ifdef DEBUG
    
    NSMutableDictionary *dddd = [[NSMutableDictionary alloc] init];
    
    NSSet *inserted = [saveInfo valueForKey:NSInsertedObjectsKey];
    NSSet *deleted = [saveInfo valueForKey:NSDeletedObjectsKey];
    NSSet *updated = [saveInfo valueForKey:NSUpdatedObjectsKey];
    NSSet *refreshed = [saveInfo valueForKey:NSRefreshedObjectsKey];
    NSSet *invalidated = [saveInfo valueForKey:NSInvalidatedObjectsKey];
    
    [self addStatsForSet:inserted       toDict:dddd operationKey:@"inserted"];
    [self addStatsForSet:deleted        toDict:dddd operationKey:@"deleted"];
    [self addStatsForSet:updated        toDict:dddd operationKey:@"updated"];
    [self addStatsForSet:refreshed      toDict:dddd operationKey:@"refreshed"];
    [self addStatsForSet:invalidated    toDict:dddd operationKey:@"invalidated"];
    
    BOOL anythingChanged = (inserted.count > 0 || deleted.count > 0 || updated.count > 0);
    
    CDLog(@"CDdb - mWmoc didsave - merging changes stats: %@", dddd);
#endif
    
    if (anythingChanged) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            CDLog(@"    CDdb - mWmoc didsave - about to merge changes with main moc");
            [self.mainThreadContext mergeChangesFromContextDidSaveNotification:saveNotification];
            
            CDLog(@"    CDdb - mWmoc didsave - merged changes with main moc");
        });
    }
    

    
}
- (void)mainMocDidSave:(NSNotification *)saveNotification {
    
    
    //CDLog(@"CDdb - main moc didSave - NO merging with anything: %@", saveNotification);

    [[NSNotificationCenter defaultCenter] postNotificationName:DATABASE_SAVED object:saveNotification];
}
- (void)mainMocDidChange:(NSNotification *)saveNotification {
    
    
    //CDLog(@"CDdb - main moc did CHANGED: %@", saveNotification);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DATABASE_CONTENT_CHANGED object:self userInfo:[saveNotification userInfo]];
    
}


#pragma mark - Save & Change notification Analytics:

+ (NSDictionary *)changesFromChangeNotification:(NSNotification *)notification forObjectOfClass:(Class)className{
    
    
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


#pragma mark - Directories:

- (NSString *)cacheDirectory {
	
	if (!_cacheDirectory) {
		
		_cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	}
	
	return _cacheDirectory;
}
- (NSString *)documentsDirectory {
	
	if (!_documentsDirectory) {
		
		_documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	}
	
	return _documentsDirectory;
}


#pragma mark - Debug:

- (void)addStatsForSet:(NSSet *)set toDict:(NSMutableDictionary *)statsDict operationKey:(NSString *)operationKey{
    
    for (NSManagedObject *mob in set) {
        
        NSString *className = NSStringFromClass([mob class]);
        
        
        NSMutableDictionary *classDict = statsDict[className];
        if (!classDict) {
            classDict = [[NSMutableDictionary alloc] initWithCapacity:5];
            statsDict[className] = classDict;
        }
        
        NSNumber *operationCount = classDict[operationKey];
        
        if (!operationCount) {
            operationCount = @(1);
        }else{
            
            operationCount = @([operationCount integerValue] + 1);
        }
        
        classDict[operationKey] = operationCount;
        
        // totals:
        NSMutableDictionary *totalsDict = statsDict[@"TOTALS"];
        if (!totalsDict) {
            totalsDict = [[NSMutableDictionary alloc] initWithCapacity:5];
            statsDict[@"TOTALS"] = totalsDict;
            
        }
        operationCount = totalsDict[operationKey];
        
        if (!operationCount) {
            operationCount = @(1);
        }else{
            
            operationCount = @([operationCount integerValue] + 1);
        }
        
        totalsDict[operationKey] = operationCount;
    }
    
}

- (BOOL)saveIfNeededAndReset:(BOOL)reset{
    
    NSAssert([NSThread isMainThread], @"Trying to save main moc from NOT main thread");
    
    
    if(_mainThreadContext && [_mainThreadContext hasChanges]){
        
        NSError *error = nil;
        BOOL success = NO;
        @try {
            success = [_mainThreadContext save:&error];
            ////CDLog(@"SAVED MAIN MOC WITH SUCCESS: %i", success);
            
            if (error) {
                [NSManagedObjectContext displayValidationError:error];
            }
        }
        @catch (NSException *exception) {
            
            CDLog(@"ERROR - Exception SAVING Core Data database: %@", exception);
            
        }
        @finally {
            
        }
        
        if (reset) {
        
            [_mainThreadContext reset];
        }
        
        
        return YES;
    }
    
    return NO;
}
@end
