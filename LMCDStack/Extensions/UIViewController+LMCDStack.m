//
//  UIViewController+LMCDStack.m
//  LMCDStack
//
//  Created by Lukasz Margielewski on 27/02/16.
//  Copyright © 2016 Lukasz Margielewski. All rights reserved.
//

#import "UIViewController+LMCDStack.h"
#import <objc/runtime.h>

@implementation UIViewController(LMCDStack)

@dynamic coreDataStack;

static LMCDStack *_defaultCoreDataStack = nil;

static char UIB_PROPERTY_KEY_CORE_DATA_STACK;

+ (void)setDefaultCoreDataStack:(nonnull LMCDStack *)defaultCoreDataStack {

    @synchronized(self) {
        _defaultCoreDataStack = defaultCoreDataStack;
    }
}

- (void)setCoreDataStack:(LMCDStack *)coreDataStack {
    
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_CORE_DATA_STACK, coreDataStack, OBJC_ASSOCIATION_ASSIGN);
}
- (LMCDStack *)coreDataStack {
    
    LMCDStack *stack = objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_CORE_DATA_STACK);
    
    if (!stack) {
        
        stack = _defaultCoreDataStack;
        self.coreDataStack = stack;
    }
    
    return stack;
}

@end
