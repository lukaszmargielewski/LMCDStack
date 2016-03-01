//
//  LMCDStack+Debug.h
//  Zen
//
//  Created by Lukasz Margielewski on 01/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMCDStack.h"

@interface LMCDStack(Debug)

- (void)addStatsForSet:(NSSet *)set
                toDict:(NSMutableDictionary *)statsDict
          operationKey:(NSString *)operationKey;

@end
