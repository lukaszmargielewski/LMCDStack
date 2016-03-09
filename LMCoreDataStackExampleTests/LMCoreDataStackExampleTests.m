//
//  LMCoreDataStackExampleTests.m
//  LMCoreDataStackExampleTests
//
//  Created by Lukasz Margielewski on 05/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LMCDStack.h"
#import "Entity.h"

#define kTestEntityName @"Entity"

@interface LMCoreDataStackExampleTests : XCTestCase

@property (nonatomic, strong) LMCDStack *cdStack;

@end

@implementation LMCoreDataStackExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cdStack = [[LMCDStack alloc] initWithFileName:@"test.sqlite"];
    [self.cdStack deletePersistedStoreData];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSAssert(self.cdStack != nil, @"no cdStack failure");
    
    __weak LMCoreDataStackExampleTests *weakSelf = self;
    
    NSManagedObjectContext *writeContext = weakSelf.cdStack.backgroundThreadContext;

    [writeContext performBlock:^{
    
        Entity *newEntity = (Entity *)[writeContext insertNewEntityWithName:kTestEntityName];
        newEntity.number = @(1);
        newEntity.text = @"Text";
        NSAssert([writeContext saveIfNeededAndReset:YES], @"Fail saving");
        
        NSUInteger count = [writeContext countEntitities:@"Entity" predicate:nil];
        NSLog(@"Count: %i", count);
        NSAssert1(count == 1, @"Count = %i, expected 1", count);
        dispatch_sync(dispatch_get_main_queue(), ^{
        
        
            NSUInteger countMain = [weakSelf.cdStack.managedObjectContext countEntitities:kTestEntityName predicate:nil];
            
            NSAssert2(count == countMain, @"countMain = %i, expected %i", countMain, count);
            
        });
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
