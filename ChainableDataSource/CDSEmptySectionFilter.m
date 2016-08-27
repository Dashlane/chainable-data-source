//
//  CDSEmptySectionFilter.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 31/12/2015.
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

#import "CDSEmptySectionFilter.h"

@implementation CDSEmptySectionFilter

- (NSInteger) cds_numberOfSections
{
    __block NSInteger count = 0;
    [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts] enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull sectionCount, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([sectionCount integerValue] > 0) {
            count++;
        }
    }];
    return count;
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    NSInteger sectionIndex = [[self sourceSectionIndexPathForSectionIndex:section] indexAtPosition:1];
    return [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts][sectionIndex] integerValue];
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sectionIndex = [[self sourceSectionIndexPathForSectionIndex:indexPath.cds_sectionIndex] indexAtPosition:1];
    return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:sectionIndex inDataSource:0];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSInteger sectionIndex = [self sectionIndexForSourceSectionIndex:sourceIndexPath.cds_sectionIndex inDataSource:sourceDataSource];
    if (sectionIndex == NSNotFound) {
        return nil;
    }
    return [NSIndexPath cds_indexPathForObject:sourceIndexPath.cds_objectIndex inSection:sectionIndex];
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSArray<NSNumber*>* sectionCounts = [[self cacheForDataSource:self.dataSource] sectionsObjectCounts];
    if ([sectionCounts[sourceSection] integerValue] == 0) {
        return NSNotFound;
    }
    NSInteger sectionIndex = 0;
    for (NSInteger sourceIndex = 0; sourceIndex < sourceSection; sourceIndex++) {
        if ([sectionCounts[sourceIndex] integerValue] > 0) {
            sectionIndex++;
        }
    }
    return sectionIndex;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    NSArray<NSNumber*>* sectionCounts = [[self cacheForDataSource:self.dataSource] sectionsObjectCounts];
    for (NSInteger sourceIndex = 0; sourceIndex < [sectionCounts count]; sourceIndex++) {
        if ([sectionCounts[sourceIndex] integerValue] > 0) {
            if (section == 0) {
                return [NSIndexPath cds_indexPathForSection:sourceIndex inDataSource:0];
            } else {
                section--;
            }
        }
    }
    return nil;
}

- (void) preRefreshTranslateSourceUpdateCache:(CDSUpdateCache *)sourceUpdateCache
                               fromDataSource:(id<CDSDataSource>)dataSource
                                toUpdateCache:(CDSUpdateCache *)updateCache
{
    //perform the standard translate
    [super preRefreshTranslateSourceUpdateCache:sourceUpdateCache fromDataSource:dataSource toUpdateCache:updateCache];
    
    NSArray* sectionCountsPreRefresh = [[self cacheForDataSource:dataSource] sectionsObjectCounts];
    
    //add section deletes for any section that is now empty
    for (NSInteger sourceSection = 0; sourceSection < [sectionCountsPreRefresh count]; sourceSection++) {
        NSInteger sectionCountPreRefresh = [sectionCountsPreRefresh[sourceSection] integerValue];
        if (sectionCountPreRefresh == 0) {
            continue;
        }
        __block NSMutableSet* deletedIndexPathsInSection = [NSMutableSet set];
        [sourceUpdateCache.deleteIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.cds_sectionIndex == sourceSection) {
                [deletedIndexPathsInSection addObject:obj];
            }
        }];
        if (sectionCountPreRefresh == [deletedIndexPathsInSection count]) {
            [updateCache.deleteSectionsIndexes addIndex:[self sectionIndexForSourceSectionIndex:sourceSection inDataSource:dataSource]];
        }
    }
}

- (void) postRefreshTranslateSourceUpdateCache:(CDSUpdateCache *)sourceUpdateCache
                                fromDataSource:(id<CDSDataSource>)dataSource
                                 toUpdateCache:(CDSUpdateCache *)updateCache
{
    NSArray* sectionCountsPostRefresh = [[self cacheForDataSource:dataSource] sectionsObjectCounts];
    
    //add section inserts for any section that was previously empty
    for (NSInteger sourceSection = 0; sourceSection < [sectionCountsPostRefresh count]; sourceSection++) {
        NSInteger sectionCountPostRefresh = [sectionCountsPostRefresh[sourceSection] integerValue];
        if (sectionCountPostRefresh == 0) {
            continue;
        }

        __block NSMutableSet* insertedIndexPathsInSection = [NSMutableSet set];
        [sourceUpdateCache.insertIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.cds_sectionIndex == sourceSection) {
                [insertedIndexPathsInSection addObject:obj];
            }
        }];
        if (sectionCountPostRefresh == [insertedIndexPathsInSection count]) {
            [updateCache.insertSectionsIndexes addIndex:[self sectionIndexForSourceSectionIndex:sourceSection inDataSource:dataSource]];
        }
    }

    //perform the standard translate
    [super postRefreshTranslateSourceUpdateCache:sourceUpdateCache fromDataSource:dataSource toUpdateCache:updateCache];
    
}

@end
