//
//  Entity+CoreDataProperties.h
//  LMCoreDataStackExample
//
//  Created by Lukasz Margielewski on 05/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Entity.h"

NS_ASSUME_NONNULL_BEGIN

@interface Entity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *number;
@property (nullable, nonatomic, retain) NSString *text;

@end

NS_ASSUME_NONNULL_END
