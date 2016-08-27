//
//  ChainableDataSourceTests.m
//  ChainableDataSourceTests
//
//  Created by Amadour Griffais on 27/08/2016.
//  Copyright 2016 Dashlane
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>

#import <ChainableDataSource/ChainableDataSource.h>

@interface ChainableDataSourceTests : XCTestCase

@end

@implementation ChainableDataSourceTests

- (void)testArrayDataSource {
    NSArray* array = @[@1, @2, @3, @4];
    XCTAssert([array cds_numberOfSections] == 1, @"");
    XCTAssert([array cds_numberOfObjectsInSection:0] == 4, @"");
    for (NSInteger i = 0; i < array.count; i++) {
        XCTAssertEqualObjects(array[i], [array cds_objectAtIndexPath:[NSIndexPath cds_indexPathForObject:i inSection:0]]);
    }

    NSArray* emptyArray = @[];
    XCTAssert([emptyArray cds_numberOfSections] == 1, @"");
    XCTAssert([emptyArray cds_numberOfObjectsInSection:0] == 0, @"");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
