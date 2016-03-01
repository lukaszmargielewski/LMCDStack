//
//  LMCDStack+Debug.m
//  Zen
//
//  Created by Lukasz Margielewski on 01/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import "LMCDStack+Debug.h"

@implementation LMCDStack(Debug)

- (void)addStatsForSet:(NSSet *)set toDict:(NSMutableDictionary *)statsDict operationKey:(NSString *)operationKey {
    
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

@end
