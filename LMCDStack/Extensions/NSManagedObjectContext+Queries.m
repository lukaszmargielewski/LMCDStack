//
//  NSManagedObjectContext_queries.m
//  Roskilde
//
//  Created by Lukasz Margielewski on 21/03/2015.
//
//

#import "LMCDStackCommon.h"
#import "NSManagedObjectContext+Queries.h"

#import <CoreData/CoreData.h>

@implementation NSManagedObjectContext(Queries)


#pragma mark - Delete:

- (void)deleteManagedObjectsFromObjectContainingObjectID:(id)toDelete{
    
        NSManagedObjectID *objectID = toDelete[@"objectID"];
        if (objectID) {
            
            NSError *error = nil;
            
            NSManagedObject *objectToDelete = [self existingObjectWithID:objectID error:&error];
            if (objectToDelete != nil) {
                [self deleteObject:objectToDelete];
            }else{
                
                CDLog(@"Error gettin object with ID: %@\nError: %@", objectID, error);
            }
        }
    
}
- (void)deleteManagedObjectsFromArrayContainingObjectIDs:(NSArray *)toDelete{
    
    for (NSDictionary *dict in toDelete) {
        
        NSManagedObjectID *objectID = dict[@"objectID"];
        if (objectID) {
            
            NSError *error = nil;
            
            NSManagedObject *objectToDelete = [self existingObjectWithID:objectID error:&error];
            if (objectToDelete != nil) {
                [self deleteObject:objectToDelete];
            }else{
                
                CDLog(@"Error getting object with ID: %@\nError: %@", objectID, error);
            }
            
            
            
        }
    }
    
}


#pragma mark - Predicates:

+(NSFetchRequest *)request1Result{
    
    static NSFetchRequest *r = NULL;
    
    if (r == NULL) {
        
        r = [[NSFetchRequest alloc] init];
        [r setFetchLimit:1];
        [r setIncludesSubentities:NO];
        
    }
    
    return r;
    
}


- (NSManagedObject *)getEntityWithName:(NSString *)entityName
                             withValue:(id)value
                                forKey:(NSString *)key {
    
    NSError *error = nil;
    NSFetchRequest *request = [NSManagedObjectContext request1Result];
    NSEntityDescription *es = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    [request setEntity:es];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    
    [request setPredicate:p];
    
    NSArray *array = [self executeFetchRequest:request error:&error];
    
    
    if(error){
        CDLog(@"Error during query: %@ database:%@", [error localizedDescription], p);
        error = nil;
    }
    
    if(array && [array count] > 0)return [array objectAtIndex:0];
    return nil;
    
}

- (NSManagedObject *)getEntity:(Class)entityClass
                     withValue:(id)value
                        forKey:(NSString *)key {

    return [self getEntityWithName:[NSManagedObjectContext entityNameForClass:entityClass]
                         withValue:value
                            forKey:key];
}

- (NSArray *)performPredicate:(NSPredicate *)predicate
                   entityName:(NSString *)entityName
                  sortedByKey:(NSString *)key
                     asceding:(BOOL)asceding
                 withObjectID:(BOOL)includeObjectID
               withProperties:(BOOL)includeProperties
                    properies:(NSArray *)propertiesToFetch
                   resultType:(NSFetchRequestResultType)resultType
                    batchSize:(NSUInteger)batchSize {
    
    NSAssert(entityName != nil, @"entityName must NO be nil");
    
    
    NSArray *results = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [request setIncludesSubentities:NO];
    [request setPredicate:predicate];
    [request setResultType:resultType];
    [request setIncludesPropertyValues:(includeProperties || includeObjectID)];
    
    if (resultType == NSDictionaryResultType && (includeObjectID || (includeProperties && propertiesToFetch))){
        
        
        if (includeObjectID) {
            
            NSMutableArray *finalProperties = (propertiesToFetch && propertiesToFetch.count) ? [NSMutableArray arrayWithCapacity:propertiesToFetch.count + 1] : [NSMutableArray arrayWithCapacity:1];
            
            NSExpressionDescription* objectIdDesc = [NSExpressionDescription new];
            objectIdDesc.name = @"objectID";
            objectIdDesc.expression = [NSExpression expressionForEvaluatedObject];
            objectIdDesc.expressionResultType = NSObjectIDAttributeType;
            
            [finalProperties addObject:objectIdDesc];
            if((propertiesToFetch && propertiesToFetch.count))[finalProperties addObjectsFromArray:propertiesToFetch];
            
            [request setPropertiesToFetch:finalProperties];
            
        }else{
            
            [request setPropertiesToFetch:propertiesToFetch];
            
        }
    };
    
    if (key) {
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:key ascending:asceding];
        [request setSortDescriptors:@[sort]];
        
    }
    
    
    NSError *error = nil;
    
    @try {
        
        results = [self executeFetchRequest:request error:&error];

    }
    
    @catch (NSException *exception) {
        CDLog(@"Exception fetching: %@", exception);
    }
    
    @finally{
    
        if (error) {
            
            CDLog(@"Error: %@ executing request: %@ with entity name: %@ predicate: %@", [error localizedDescription], request, entityName, predicate);
        }
    }
    
    
    return results;
    
}

- (NSArray *)performPredicate:(NSPredicate *)predicate
                       entity:(Class)entityClass
                  sortedByKey:(NSString *)key
                     asceding:(BOOL)asceding
                 withObjectID:(BOOL)includeObjectID
               withProperties:(BOOL)includeProperties
                    properies:(NSArray *)propertiesToFetch
                   resultType:(NSFetchRequestResultType)resultType
                    batchSize:(NSUInteger)batchSize {

    return [self performPredicate:predicate
                       entityName:[NSManagedObjectContext entityNameForClass:entityClass]
                      sortedByKey:key asceding:asceding
                     withObjectID:includeObjectID
                   withProperties:includeProperties
                        properies:propertiesToFetch
                       resultType:resultType
                        batchSize:batchSize];
    

}

+ (NSString *)entityNameForClass:(Class)class {

    return NSStringFromClass(class);
}
#pragma mark - Calculation helpers:

- (NSUInteger)countEntitiesWithName:(NSString *)entityName
                          predicate:(NSPredicate *)predicate{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *es = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    if (!es) {
        return 0;
    }
    [request setEntity:es];
    [request setPredicate:predicate];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    
    return count;
    
}

- (NSUInteger)countEntitities:(Class)entityClass
                    predicate:(NSPredicate *)predicate {

    return [self countEntitiesWithName:[NSManagedObjectContext entityNameForClass:entityClass] predicate:predicate];
    
}

- (NSNumber *)minimumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate{
    
    return [self valueForKey:idKey function:@"min:" entityName:entityName predicate:predicate];
}

- (NSNumber *)minimumValueForKey:(NSString *)idKey
                          entity:(Class)entityClass
                       predicate:(NSPredicate *)predicate {

    return [self minimumValueForKey:idKey
                         entityName:[NSManagedObjectContext entityNameForClass:entityClass]
                          predicate:predicate];
    
}

- (NSNumber *)maximumValueForKey:(NSString *)idKey
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate {


    return [self valueForKey:idKey function:@"max:" entityName:entityName predicate:predicate];
    
}

- (NSNumber *)maximumValueForKey:(NSString *)idKey
                          entity:(Class)entityClass
                       predicate:(NSPredicate *)predicate {

    return [self maximumValueForKey:idKey
                         entityName:[NSManagedObjectContext entityNameForClass:entityClass]
                          predicate:predicate];
}

- (NSNumber *)valueForKey:(NSString *)idKey
                 function:(NSString *)function
               entityName:(NSString *)entityName
                predicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    if (!entity) {
        return nil;
    }
    [request setEntity:entity];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    [request setIncludesPendingChanges:YES];
    
    if (predicate) {
        [request setPredicate:predicate];
    }
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:idKey];
    NSExpression *minExpression = [NSExpression expressionForFunction:function arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    NSString *expName = [NSString stringWithFormat:@"%@_%@", function, idKey];
    [expressionDescription setName:expName];
    [expressionDescription setExpression:minExpression];
    //[expressionDescription setExpressionResultType:NSDateAttributeType];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
    }
    else {
        if ([objects count] > 0) {
            id value = [[objects objectAtIndex:0] valueForKey:expName];
            return value;
        }
    }
    return nil;
}


#pragma mark - Save:

- (BOOL)saveIfNeededAndReset:(BOOL)reset{
    
    if([self hasChanges]){
        
        NSError *error = nil;
        BOOL success = NO;
        @try {
            success = [self save:&error];
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
        
        [self reset];
        
        return YES;
    }
    
    return NO;
}

+ (void)displayValidationError:(NSError *)anError{
    if (anError && [[anError domain] isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;
        
        // multiple errors?
        if ([anError code] == NSValidationMultipleErrorsError) {
            errors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        
        if (errors && [errors count] > 0) {
            NSString *messages = @"Reason(s):\n";
            
            for (NSError * error in errors) {
                NSString *entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString *attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
                NSString *msg;
                switch ([error code]) {
                    case NSManagedObjectValidationError:
                        msg = @"Generic validation error.";
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        msg = [NSString stringWithFormat:@"The attribute '%@' mustn't be empty.", attributeName];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' doesn't have enough entries.", attributeName];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' has too many entries.", attributeName];
                        break;
                    case NSValidationRelationshipDeniedDeleteError:
                        msg = [NSString stringWithFormat:@"To delete, the relationship '%@' must be empty.", attributeName];
                        break;
                    case NSValidationNumberTooLargeError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too large.", attributeName];
                        break;
                    case NSValidationNumberTooSmallError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too small.", attributeName];
                        break;
                    case NSValidationDateTooLateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too late.", attributeName];
                        break;
                    case NSValidationDateTooSoonError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too soon.", attributeName];
                        break;
                    case NSValidationInvalidDateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is invalid.", attributeName];
                        break;
                    case NSValidationStringTooLongError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too long.", attributeName];
                        break;
                    case NSValidationStringTooShortError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too short.", attributeName];
                        break;
                    case NSValidationStringPatternMatchingError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' doesn't match the required pattern.", attributeName];
                        break;
                    default:
                        msg = [NSString stringWithFormat:@"Unknown error (code %li).", (long)[error code]];
                        break;
                }
                
                messages = [messages stringByAppendingFormat:@"%@%@%@\nuserInfo: %@\n", (entityName?:@""),(entityName?@": ":@""),msg, [error userInfo]];
            }
            
            CDLog(@"Error description: %@", messages);
            
        }
    }
}

@end
