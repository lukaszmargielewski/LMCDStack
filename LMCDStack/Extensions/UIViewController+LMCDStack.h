//
//  UIViewController+LMCDStack.h
//  LMCDStack
//
//  Created by Lukasz Margielewski on 27/02/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMCDStack.h"

@interface UIViewController(LMCDStack)

@property (nonatomic, assign, nullable) LMCDStack *coreDataStack;

+ (void)setDefaultCoreDataStack:(nonnull LMCDStack *)defaultCoreDataStack;

@end
