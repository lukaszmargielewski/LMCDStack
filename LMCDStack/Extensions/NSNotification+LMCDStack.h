//
//  NSNotification+LMCDStack.h
//  Zen
//
//  Created by Lukasz Margielewski on 01/03/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotification(LMCDStack)

+ (nullable NSDictionary *)changesFromChangeNotification:(nonnull NSNotification *)notification
                                        forObjectOfClass:(nonnull Class)className;

+ (BOOL)saveNotification:(nonnull NSNotification *)notification containsObjectOfClass:(nonnull Class)className;
+ (BOOL)saveNotification:(nonnull NSNotification *)notification containsObjectOfClasses:(nonnull NSArray *)classNamesArray;

@end
