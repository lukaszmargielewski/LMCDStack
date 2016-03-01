////
//  PersonViewController.m
//  iBook
//
//  Created by Lukasz Margielewski on 10-09-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LMCDStack.h"
#import "LMCDStackConfig.h"
#import "NSManagedObjectContext+Queries.h"

#ifdef DEBUG
    #import "LMCDStack+Debug.h"
#endif

NSString * const kLMCDStackDidSaveNotificationName = @"kLMCDStackDidSaveNotificationName";
NSString * const kLMCDStackDidChangeNotificationName = @"kLMCDStackDidChangeNotificationName";

@interface LMCDStack ()

@property (nonatomic, strong, readonly) NSString *cacheDirectory;
@property (nonatomic, strong, readonly) NSString *documentsDirectory;

@end

@implementation LMCDStack

@synthesize mainThreadContext = _mainThreadContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize backgroundThreadContext = _backgroundThreadContext;
@synthesize name = _name;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize persistentStorePath = _persistentStorePath;
@synthesize cacheDirectory = _cacheDirectory, documentsDirectory = _documentsDirectory;
@synthesize storeType = _storeType;

- (void)dealloc {
	
    [self cleanBackgroundThreadContext];
}

- (instancetype)initWithName:(NSString *)name {

    return [self initWithName:name storeType:NSSQLiteStoreType];
}

- (instancetype)initWithName:(NSString *)name
                   storeType:(NSString *)storeType {
    
    self = [super init];
    
	if (self) {
		
        _name = name;
        _storeType = storeType ? storeType : NSSQLiteStoreType;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_mainThreadContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_mainThreadContext];
    }
    return _mainThreadContext;
    
    
    
    
    return nil;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
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
                
                [self deletePersistedStoreData];
                
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
        
            NSString *extension = @"sqlite";
            
            if ([_storeType isEqualToString:NSInMemoryStoreType]) {
                extension = @"memory";
            }else if ([_storeType isEqualToString:NSBinaryStoreType]) {
                extension = @"binary";
            }
            
            NSString *path_in_sandbox   = [[self.documentsDirectory stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:extension];
            _persistentStorePath = [NSURL fileURLWithPath:path_in_sandbox];
            
        }
        
        return _persistentStorePath;
    }
}

- (BOOL)deletePersistedStoreData {
    
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


#pragma mark - Background Context:

- (NSManagedObjectContext *)backgroundThreadContext {
    
    if (_backgroundThreadContext)return _backgroundThreadContext;
    
            _backgroundThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_backgroundThreadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [_backgroundThreadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_backgroundThreadContext];
            [_backgroundThreadContext setUndoManager:nil];
    
        return _backgroundThreadContext;
}

- (void)cleanBackgroundThreadContext {
    
    if (_backgroundThreadContext) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:_backgroundThreadContext];
        _backgroundThreadContext = nil;
    }
}

#pragma mark - Multithreading support & merging with main thread context;:

- (void)backgroundContextDidSave:(NSNotification *)saveNotification {
  
    
    id saveInfo = [saveNotification userInfo];
    

    
    NSMutableDictionary *dddd = [[NSMutableDictionary alloc] init];
    
    NSSet *inserted = [saveInfo valueForKey:NSInsertedObjectsKey];
    NSSet *deleted = [saveInfo valueForKey:NSDeletedObjectsKey];
    NSSet *updated = [saveInfo valueForKey:NSUpdatedObjectsKey];
    NSSet *refreshed = [saveInfo valueForKey:NSRefreshedObjectsKey];
    NSSet *invalidated = [saveInfo valueForKey:NSInvalidatedObjectsKey];
  
    BOOL anythingChanged = (inserted.count > 0 || deleted.count > 0 || updated.count > 0);
    
#ifdef DEBUG
    
    [self addStatsForSet:inserted       toDict:dddd operationKey:@"inserted"];
    [self addStatsForSet:deleted        toDict:dddd operationKey:@"deleted"];
    [self addStatsForSet:updated        toDict:dddd operationKey:@"updated"];
    [self addStatsForSet:refreshed      toDict:dddd operationKey:@"refreshed"];
    [self addStatsForSet:invalidated    toDict:dddd operationKey:@"invalidated"];
    
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

#pragma mark - Save & Changed notifications support:

- (void)mainContextDidSave:(NSNotification *)saveNotification {
    
    
    //CDLog(@"CDdb - main moc didSave - NO merging with anything: %@", saveNotification);

    [[NSNotificationCenter defaultCenter] postNotificationName:kLMCDStackDidSaveNotificationName object:saveNotification];
}
- (void)mainContextDidChange:(NSNotification *)saveNotification {
    
    
    //CDLog(@"CDdb - main moc did CHANGED: %@", saveNotification);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLMCDStackDidChangeNotificationName object:self userInfo:[saveNotification userInfo]];
    
}


#pragma mark - Save:

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


#pragma mark - Directories:

- (NSString *)cacheDirectory {
	
	if (!_cacheDirectory) {
		
		_cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
	}
	
	return _cacheDirectory;
}
- (NSString *)documentsDirectory {
	
	if (!_documentsDirectory) {
		
		_documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	}
	
	return _documentsDirectory;
}

@end
