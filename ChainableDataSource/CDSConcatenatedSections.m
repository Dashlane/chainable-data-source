//
//  CDSConcatenatedSections.m
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

#import "CDSConcatenatedSections.h"

@implementation CDSConcatenatedSections

- (NSInteger) cds_numberOfSections
{
    __block NSInteger count = 0;
    [self.dataSourceCaches enumerateObjectsUsingBlock:^(CDSCountCache * _Nonnull cache, NSUInteger idx, BOOL * _Nonnull stop) {
        count+= cache.sectionsObjectCounts.count;
    }];
    return count;
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    for (CDSCountCache* cache in self.dataSourceCaches) {
        if (section < cache.sectionsObjectCounts.count) {
            return [cache.sectionsObjectCounts[section] integerValue];
        } else {
            section -= cache.sectionsObjectCounts.count;
        }
    }
    return 0;
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* sourceSectionIndexPath = [self sourceSectionIndexPathForSectionIndex:indexPath.cds_sectionIndex];
    if (!sourceSectionIndexPath) {
        return nil;
    }

    NSUInteger indexes[3];
    indexes[0] = sourceSectionIndexPath.cds_sectionIndex;
    indexes[1] = sourceSectionIndexPath.cds_objectIndex;
    indexes[2] = indexPath.cds_objectIndex;
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath *)indexPath inDataSource:(id<CDSDataSource>)dataSource
{
    NSInteger sectionIndex = [self sectionIndexForSourceSectionIndex:indexPath.cds_sectionIndex inDataSource:dataSource];
    return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:sectionIndex];
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:sourceDataSource];
    NSInteger sectionIndex = sourceSection;
    for (NSInteger dsIndex = 0; dsIndex < dataSourceIndex; dsIndex++) {
        sectionIndex += self.dataSourceCaches[dsIndex].sectionsObjectCounts.count;
    }
    return sectionIndex;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    __block NSInteger dsIndex = NSNotFound;
    __block NSInteger localSectionIndex = section;
    [self.dataSourceCaches enumerateObjectsUsingBlock:^(CDSCountCache*  _Nonnull cache, NSUInteger idx, BOOL * _Nonnull stop) {
        if (localSectionIndex < cache.sectionsObjectCounts.count) {
            dsIndex = idx;
            *stop = YES;
        } else {
            localSectionIndex -= cache.sectionsObjectCounts.count;
        }
    }];
    
    if (dsIndex == NSNotFound) {
        return nil;
    }
    
    return [NSIndexPath cds_indexPathForSection:localSectionIndex inDataSource:dsIndex];
}

@end
