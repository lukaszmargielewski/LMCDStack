//
//  NSManagedObjectContextProvider.h
//  LD
//
//  Created by Lukasz Margielewski on 09/07/15.
//  Copyright (c) 2015 appledevelop.pl. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol NSManagedObjectContextProvider <NSObject>

@property (nonatomic, strong, readonly, nonnull) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly, nonnull) NSManagedObjectContext *backgroundThreadContext;
@end
