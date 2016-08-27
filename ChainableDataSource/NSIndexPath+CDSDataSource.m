//
//  NSIndexPath+CDSDataSource.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 21/09/2016.
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

#import "NSIndexPath+CDSDataSource.h"

@implementation NSIndexPath (CDSDataSource)

+ (NSIndexPath*) cds_indexPathForObject:(NSInteger)objectIndex inSection:(NSInteger)sectionIndex
{
    NSUInteger indexes[2];
    indexes[0] = sectionIndex;
    indexes[1] = objectIndex;
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

+ (NSIndexPath*) cds_indexPathForObject:(NSInteger)objectIndex inSection:(NSInteger)sectionIndex inDataSource:(NSInteger)dataSourceIndex
{
    NSUInteger indexes[3];
    indexes[0] = dataSourceIndex;
    indexes[1] = sectionIndex;
    indexes[2] = objectIndex;
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

+ (NSIndexPath*) cds_indexPathForSection:(NSInteger)sectionIndex inDataSource:(NSInteger)dataSourceIndex
{
    NSUInteger indexes[2];
    indexes[0] = dataSourceIndex;
    indexes[1] = sectionIndex;
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (NSInteger) cds_dataSourceIndex
{
    return self.length == 3 ? [self indexAtPosition:0] : NSNotFound;
}

- (NSInteger) cds_sectionIndex
{
    return self.length <= 2 ? [self indexAtPosition:0] : [self indexAtPosition:1];
}

- (NSInteger) cds_objectIndex
{
    return self.length >= 2 ? (self.length == 2 ? [self indexAtPosition:1] : [self indexAtPosition:2]) : NSNotFound;
}

- (NSIndexPath*) cds_indexPathInDataSource
{
    return self.length == 3 ? [NSIndexPath cds_indexPathForObject:[self indexAtPosition:2] inSection:[self indexAtPosition:1]] : nil;
}

@end
