//
//  CDSFlattener.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 16/12/2015.
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

#import "CDSFlattener.h"

@implementation CDSFlattener

@synthesize cds_updateDelegate;

- (CDSCountCache*) cache
{
    return self.dataSourceCaches.firstObject;
}

- (NSInteger) cds_numberOfSections
{
    return self.cache.sectionsObjectCounts.count > 0?1:0;
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    __block NSInteger count = 0;
    [self.cache.sectionsObjectCounts enumerateObjectsUsingBlock:^(NSNumber* _Nonnull sectionCount, NSUInteger idx, BOOL * _Nonnull stop) {
        count+= [sectionCount integerValue];
    }];
    return count;
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    __block NSInteger sectionIndex = NSNotFound;
    __block NSInteger rowIndex = indexPath.cds_objectIndex;
    
    [self.cache.sectionsObjectCounts enumerateObjectsUsingBlock:^(NSNumber* _Nonnull sectionCount, NSUInteger idx, BOOL * _Nonnull stop) {
        if (rowIndex < [sectionCount integerValue]) {
            sectionIndex = idx;
            *stop = YES;
        } else {
            rowIndex -= [sectionCount integerValue];
        }
    }];
    
    NSUInteger indexes[3];
    indexes[0] = 0;
    indexes[1] = sectionIndex;
    indexes[2] = rowIndex;
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath *)indexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    __block NSInteger rowIndex = 0;
    [self.cache.sectionsObjectCounts enumerateObjectsUsingBlock:^(NSNumber* _Nonnull sectionCount, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == indexPath.cds_sectionIndex) {
            rowIndex+=indexPath.cds_objectIndex;
            *stop = YES;
        } else {
            rowIndex+=[sectionCount integerValue];
        }
    }];
    return [NSIndexPath cds_indexPathForObject:rowIndex inSection:0];
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    return NSNotFound;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    return nil;
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    return self.sectionName;
}

@end
