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

extern  NSString * _Nonnull const kLMCDStackDidSaveNotificationName;
extern  NSString * _Nonnull const kLMCDStackDidChangeNotificationName;


@interface LMCDStack : NSObject

@property (nonatomic, strong, readonly, nonnull)  NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly, nonnull)  NSManagedObjectContext          *mainThreadContext;
@property (nonatomic, strong, readonly, nullable) NSManagedObjectContext          *backgroundThreadContext;

@property (nonatomic, strong, readonly, nonnull) NSPersistentStoreCoordinator  *persistentStoreCoordinator;
@property (nonatomic, strong, readonly, nonnull) NSURL *persistentStorePath;

@property (nonatomic, strong, readonly, nonnull) NSString *fileName;
@property (nonatomic, strong, readonly, nonnull) NSString *storeType;

#pragma mark - Init:

- (nonnull instancetype)init NS_UNAVAILABLE;

- (nonnull instancetype)initWithFileName:(nonnull NSString *)fileName;

- (nonnull instancetype)initWithFileName:(nonnull NSString *)fileName
                               storeType:(nonnull NSString *)storeType NS_DESIGNATED_INITIALIZER;

- (BOOL)saveIfNeededAndReset:(BOOL)reset;
- (BOOL)deletePersistedStoreData;

@end