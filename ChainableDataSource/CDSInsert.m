//
//  CDSInsert.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 04/09/2016.
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

#import "CDSInsert.h"
#import "NSIndexPath+CDSDataSource.h"

@interface CDSInsert ()

@property (nonatomic, assign) BOOL shouldRefreshInsertion;
@property (nonatomic, strong) NSArray<NSIndexPath*>* insertedIndexPathsBeforeUpdate;

@end

@implementation CDSInsert

- (id<CDSDataSource>) mainDataSource
{
    return self.dataSources.firstObject;
}

- (id<CDSDataSource>) insertedDataSource
{
    return self.dataSources.count > 0 ? self.dataSources[1] : nil;
}

- (NSIndexPath*) effectiveInsertIndexPath
{
    //insert if the target index path exists in the main data source, or insertAtEndIfNeeded is set
    if (!(self.insertionIndexPath != nil && [self mainDataSource] && [self insertedDataSource])) {
        return nil;
    }
    
    NSInteger targetSection = self.insertionIndexPath.cds_sectionIndex;
    NSInteger targetRow = self.insertionIndexPath.cds_objectIndex;
    NSInteger effectiveSection = NSNotFound;
    NSInteger effectiveRow = NSNotFound;
    CDSCountCache* cache = [self cacheForDataSource:[self mainDataSource]];
    if (targetSection > (NSInteger)[[cache sectionsObjectCounts] count] - 1 ) {
        if (self.insertAtEndIfNeeded && [[cache sectionsObjectCounts] count] >0) {
            effectiveSection = [[cache sectionsObjectCounts] count] - 1;
        } else {
            return nil;
        }
    } else {
        effectiveSection = targetSection;
    }
    
    if (targetRow > (NSInteger)[[cache sectionsObjectCounts][effectiveSection] integerValue]) {
        if (self.insertAtEndIfNeeded) {
            effectiveRow = [[cache sectionsObjectCounts][effectiveSection] integerValue];
        } else {
            return nil;
        }
    } else {
        effectiveRow =  targetRow;
    }
    
    return [NSIndexPath cds_indexPathForObject:effectiveRow inSection:effectiveSection];
}

- (BOOL) isInserting
{
    return [self effectiveInsertIndexPath] != nil;
}

- (NSInteger) cds_numberOfSections
{
    //we never add a section: always return our main data source values
    return [[[self cacheForDataSource:[self mainDataSource]] sectionsObjectCounts] count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    NSInteger mainSectionCount = [[[self cacheForDataSource:[self mainDataSource]] sectionsObjectCounts][section] integerValue];
    NSIndexPath* iip = [self effectiveInsertIndexPath];
    if (!iip || section != iip.cds_sectionIndex) {
        return mainSectionCount;
    } else {
        NSInteger insertSectionCount = [[[self cacheForDataSource:[self insertedDataSource]] sectionsObjectCounts].firstObject integerValue];
        return mainSectionCount+insertSectionCount;
    }
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* iip = [self effectiveInsertIndexPath];
    //is this the insert sections?
    if (!iip || indexPath.cds_sectionIndex != iip.cds_sectionIndex) {
        return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:indexPath.cds_sectionIndex inDataSource:0];
    } else {
        //is the index path part of the inserted objects
        NSInteger insertedCount = [[[self cacheForDataSource:[self insertedDataSource]] sectionsObjectCounts].firstObject integerValue];
        if (indexPath.cds_objectIndex < iip.cds_objectIndex) {
            return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:indexPath.cds_sectionIndex inDataSource:0];
        } else if (indexPath.cds_objectIndex < iip.cds_objectIndex + insertedCount) { //inderted object
            return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex - iip.cds_objectIndex inSection:0 inDataSource:1];
        } else { //after inserted objects
            return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex - insertedCount inSection:indexPath.cds_sectionIndex inDataSource:0];
        }
    }
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSIndexPath* iip = [self effectiveInsertIndexPath];
    
    if (sourceDataSource == [self mainDataSource]) {
        //is this not the insert sections?
        if (!iip || sourceIndexPath.cds_sectionIndex != iip.cds_sectionIndex) {
            return sourceIndexPath;
        } else {
            //is the index path part of the inserted objects
            NSInteger insertedCount = [[[self cacheForDataSource:[self insertedDataSource]] sectionsObjectCounts].firstObject integerValue];
            if (sourceIndexPath.cds_objectIndex < iip.cds_objectIndex) {
                return sourceIndexPath;
            } else  { //after inderted objects
                return [NSIndexPath cds_indexPathForObject:sourceIndexPath.cds_objectIndex + insertedCount inSection:0];
            }
        }
    } else if (sourceDataSource == [self insertedDataSource]) {
        if (!iip || sourceIndexPath.cds_sectionIndex != 0) {
            return nil;
        } else {
            return [NSIndexPath cds_indexPathForObject:iip.cds_objectIndex + sourceIndexPath.cds_objectIndex inSection:iip.cds_sectionIndex];
        }
    } else {
        return nil;
    }
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    //if this is the insert data source it's got no mapping
    if (sourceDataSource == [self insertedDataSource]) {
        return NSNotFound;
    } else {
        return sourceSection;
    }
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    return [NSIndexPath cds_indexPathForSection:section inDataSource:0];
}

/**************************************************************************/
#pragma mark methods to override for backward (update) support

- (NSArray<NSIndexPath*>*) currentlyInsertedIndexPaths
{
    NSIndexPath* iip = [self effectiveInsertIndexPath];
    if (!iip) {
        return nil;
    }
    NSMutableArray* insertedIndexPaths = [NSMutableArray array];
    NSInteger insertedCount = [[[self cacheForDataSource:[self insertedDataSource]] sectionsObjectCounts].firstObject integerValue];
    for (NSInteger i = iip.cds_objectIndex; i < iip.cds_objectIndex+insertedCount; i++) {
        [insertedIndexPaths addObject:[NSIndexPath cds_indexPathForObject:i inSection:iip.cds_sectionIndex]];
    }
    return insertedIndexPaths;
}

- (void) preRefreshTranslateSourceUpdateCache:(CDSUpdateCache *)sourceUpdateCache fromDataSource:(id<CDSDataSource>)dataSource toUpdateCache:(CDSUpdateCache *)updateCache
{
    [super preRefreshTranslateSourceUpdateCache:sourceUpdateCache fromDataSource:dataSource toUpdateCache:updateCache];
    if (dataSource == [self mainDataSource]) {
        NSIndexPath* iip = self.insertionIndexPath;
        //if any section / indexPath before our effective index path was added/removed, we need to refresh
        self.shouldRefreshInsertion = NO;
        for (NSInteger i = 0; i <= iip.cds_sectionIndex; i++) {
            if ([sourceUpdateCache.deleteSectionsIndexes containsIndex:i]) {
                self.shouldRefreshInsertion = YES;
                break;
            } else if ([sourceUpdateCache.insertSectionsIndexes containsIndex:i]) {
                self.shouldRefreshInsertion = YES;
                break;
            }
        }
        if (!self.shouldRefreshInsertion) {
            for (NSInteger i = 0; i < iip.cds_objectIndex; i++) {
                NSIndexPath* ip = [NSIndexPath cds_indexPathForObject:i inSection:iip.cds_sectionIndex];
                if ([sourceUpdateCache.deleteIndexPaths containsObject:ip]) {
                    self.shouldRefreshInsertion = YES;
                    break;
                } else if ([sourceUpdateCache.insertIndexPaths containsObject:ip]) {
                    self.shouldRefreshInsertion = YES;
                    break;
                }
            }
        }
        if (self.shouldRefreshInsertion) {
            [updateCache.deleteIndexPaths addObjectsFromArray:[self currentlyInsertedIndexPaths]];
        }
    }
    
}

//convert source update cache to our own update cache (post-refresh) exceptionally reimplement, you should very probably call super
- (void) postRefreshTranslateSourceUpdateCache:(CDSUpdateCache*)sourceUpdateCache
                                fromDataSource:(id<CDSDataSource>)dataSource
                                 toUpdateCache:(CDSUpdateCache*)updateCache
{
    [super postRefreshTranslateSourceUpdateCache:sourceUpdateCache fromDataSource:dataSource toUpdateCache:updateCache];
    if (dataSource == [self mainDataSource]) {
        if (self.shouldRefreshInsertion) {
            [updateCache.insertIndexPaths addObjectsFromArray:[self currentlyInsertedIndexPaths]];
        }
    }
}

@end
