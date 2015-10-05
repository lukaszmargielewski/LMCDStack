//
//  PersonViewController.h
//  iBook
//
//  Created by Lukasz Margielewski on 10-09-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

#import "NSManagedObjectContext+Queries.h"

#define DATABASE_SAVED @"CoreDataSavedWithChanges"
#define DATABASE_CONTENT_CHANGED @"CoreDataChangedInMainMoc"

@interface LMCDStack : NSObject{


}

@property (nonatomic, strong, readonly) NSString *cacheDirectory, *documentsDirectory;


#pragma mark - Core Data Stack:

@property (nonatomic, strong, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext          *mainThreadContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext          *backgroundThreadContext;

@property (atomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (atomic, strong, readonly) NSURL *persistentStorePath;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *storeType;

#pragma mark - Init:

- (instancetype)initWithName:(NSString *)name
                   storeType:(NSString *)storeType
                     version:(NSString *)version;

- (BOOL)saveIfNeededAndReset:(BOOL)reset;
- (BOOL)deleteDatabaseFile;


#pragma mark - Write Context Cleaning:

- (void)cleanBackgroundThreadContext;


#pragma mark - Save & Change notification Analytics:

+ (NSDictionary *)changesFromChangeNotification:(NSNotification *)notification
                               forObjectOfClass:(Class)className;

+ (BOOL)saveNotification:(NSNotification *)notification containsObjectOfClass:(Class)className;
+ (BOOL)saveNotification:(NSNotification *)notification containsObjectOfClasses:(NSArray *)classNamesArray;

@end