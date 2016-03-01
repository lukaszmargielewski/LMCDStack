//
//  PersonViewController.h
//  iBook
//
//  Created by Lukasz Margielewski on 10-09-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

extern  NSString * _Nonnull const kLMCDStackDidSaveNotificationName;
extern  NSString * _Nonnull const kLMCDStackDidChangeNotificationName;


@interface LMCDStack : NSObject

@property (nonatomic, strong, readonly, nonnull)  NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly, nonnull)  NSManagedObjectContext          *mainThreadContext;
@property (nonatomic, strong, readonly, nullable) NSManagedObjectContext          *backgroundThreadContext;

@property (atomic, strong, readonly, nonnull) NSPersistentStoreCoordinator  *persistentStoreCoordinator;
@property (atomic, strong, readonly, nonnull) NSURL *persistentStorePath;

@property (nonatomic, strong, readonly, nonnull) NSString *name;
@property (nonatomic, strong, readonly, nonnull) NSString *storeType;

#pragma mark - Init:

- (nonnull instancetype)init NS_UNAVAILABLE;

- (nonnull instancetype)initWithName:(nonnull NSString *)name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                           storeType:(nonnull NSString *)storeType NS_DESIGNATED_INITIALIZER;

- (BOOL)saveIfNeededAndReset:(BOOL)reset;
- (BOOL)deletePersistedStoreData;

@end