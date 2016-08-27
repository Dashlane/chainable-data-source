//
//  CDSManualFilter.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 06/01/2016.
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

#import "CDSManualFilter.h"

@interface CDSManualFilter ()

@property (nonatomic, strong) NSMutableIndexSet* hiddenSectionIndexes;
@property (nonatomic, strong) NSMutableArray<NSMutableIndexSet*>* hiddenItemsIndexesBySourceSection;
@property (nonatomic, strong) CDSUpdateCache* currentUpdatesCache;
@property (nonatomic, assign) NSInteger nestedUpdatesCount;

@end

@implementation CDSManualFilter

/**************************************************************************/
#pragma mark CDSTransform overrides

- (void) reloadFromDataSource:(id<CDSDataSource>)dataSource
{
    [super reloadFromDataSource:dataSource];
    self.hiddenSectionIndexes = [NSMutableIndexSet indexSet];
    self.hiddenItemsIndexesBySourceSection = [NSMutableArray array];
    NSInteger sectionCount = [[[self cacheForDataSource:dataSource] sectionsObjectCounts] count];
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        [self.hiddenItemsIndexesBySourceSection addObject:[NSMutableIndexSet indexSet]];
    }
}

- (void) refreshFromDataSource:(id<CDSDataSource>)dataSource withSourceUpdateCache:(CDSUpdateCache*)updateCache
{
    //TODO implement delta update from our data source by shifting the hidden indexes accordingly to the update
    return [super refreshFromDataSource:dataSource withSourceUpdateCache:updateCache];
}

- (NSInteger) cds_numberOfSections
{
    return [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts] count] - [self.hiddenSectionIndexes count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    NSInteger sourceSection = [[self sourceSectionIndexPathForSectionIndex:section] indexAtPosition:1];
    return [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts][sourceSection] integerValue] - [self.hiddenItemsIndexesBySourceSection[sourceSection] count];
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sourceSection = [[self sourceSectionIndexPathForSectionIndex:indexPath.cds_sectionIndex] indexAtPosition:1];
    NSIndexSet* hiddenIndexes = self.hiddenItemsIndexesBySourceSection[sourceSection];
    NSInteger sourceIndexCount = [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts][sourceSection] integerValue];
    NSInteger row = indexPath.cds_objectIndex;
    NSInteger sourceRow = 0;
    for (NSInteger sourceRowIndex = 0; sourceRowIndex < sourceIndexCount; sourceRowIndex++) {
        if (![hiddenIndexes containsIndex:sourceRowIndex]) {
            if (row == 0) {
                return [NSIndexPath cds_indexPathForObject:sourceRow inSection:sourceSection inDataSource:0];
            } else {
                row--;
            }
        }
        sourceRow++;
    }
    return nil;
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSInteger sectionIndex = [self sectionIndexForSourceSectionIndex:sourceIndexPath.cds_sectionIndex inDataSource:sourceDataSource];
    if (sectionIndex == NSNotFound) {
        return nil;
    }
    NSIndexSet* hiddenIndexes = self.hiddenItemsIndexesBySourceSection[sourceIndexPath.cds_sectionIndex];
    if ([hiddenIndexes containsIndex:sourceIndexPath.cds_objectIndex]) {
        return nil;
    }
    NSInteger rowIndex = sourceIndexPath.cds_objectIndex - [hiddenIndexes countOfIndexesInRange:NSMakeRange(0, sourceIndexPath.cds_objectIndex)];
    return [NSIndexPath cds_indexPathForObject:rowIndex inSection:sectionIndex];
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    if ([self.hiddenSectionIndexes containsIndex:sourceSection]) {
        return NSNotFound;
    }
    return sourceSection - [self.hiddenSectionIndexes countOfIndexesInRange:NSMakeRange(0, sourceSection)];
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    NSInteger sourceSection = 0;
    NSInteger sourceSectionCount = [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts] count];
    for (NSInteger sourceSectionIndex = 0; sourceSectionIndex < sourceSectionCount; sourceSectionIndex++) {
        if (![self.hiddenSectionIndexes containsIndex:sourceSectionIndex]) {
            if (section == 0) {
                return [NSIndexPath cds_indexPathForSection:sourceSection inDataSource:0];
            } else {
                section--;
            }
        }
        sourceSection++;
    }
    return nil;
}

/**************************************************************************/
#pragma mark Filtering methods

- (void) updateHiddenObjectsWithUpdateCache:(CDSUpdateCache *)updateCache animated:(BOOL)animated
{
    if (self.currentUpdatesCache) {
        [self.currentUpdatesCache addUpdatesFromCache:updateCache];
        return;
    }
    
    if (animated) {
        [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
    }
    
    //remove from the updates any update that do not change the state
    [updateCache.deleteSectionsIndexes removeIndexes:self.hiddenSectionIndexes];
    [updateCache.insertSectionsIndexes removeIndexes:[self visibleSectionIndexes]];
    [self.hiddenItemsIndexesBySourceSection enumerateObjectsUsingBlock:^(NSMutableIndexSet * _Nonnull hiddenObjectIndexes, NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        NSInteger objectCount = [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts][sectionIndex] integerValue];
        for (NSInteger objectIndex = 0; objectIndex < objectCount; objectIndex++) {
            NSIndexPath* indexPath = [NSIndexPath cds_indexPathForObject:objectIndex inSection:sectionIndex];
            if ([hiddenObjectIndexes containsIndex:objectIndex]) {
                [updateCache.deleteIndexPaths removeObject:indexPath];
            } else {
                [updateCache.insertIndexPaths removeObject:indexPath];
            }
        }
    }];
    
    CDSUpdateCache* resultingUpdateCache = [CDSUpdateCache new];
    
    //compute the deleted indexes before the update
    [updateCache.deleteIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath* preUpdateIndexPath = [self indexPathForSourceIndexPath:obj inDataSource:self.dataSource];
        if (preUpdateIndexPath) {
            [resultingUpdateCache.deleteIndexPaths addObject:preUpdateIndexPath];
        }
    }];
    [updateCache.deleteSectionsIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger preUpdateSection = [self sectionIndexForSourceSectionIndex:idx inDataSource:self.dataSource];
        if (preUpdateSection != NSNotFound) {
            [resultingUpdateCache.deleteSectionsIndexes addIndex:preUpdateSection];
        }
    }];
    
    //Update our hidden indexes
    [updateCache.deleteIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.hiddenItemsIndexesBySourceSection[obj.cds_sectionIndex] addIndex:obj.cds_objectIndex];
    }];
    [self.hiddenSectionIndexes addIndexes:updateCache.deleteSectionsIndexes];
    [updateCache.insertIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.hiddenItemsIndexesBySourceSection[obj.cds_sectionIndex] removeIndex:obj.cds_objectIndex];
    }];
    [self.hiddenSectionIndexes removeIndexes:updateCache.insertSectionsIndexes];

    //compute the inserted indexes before the update
    [updateCache.insertSectionsIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger postUpdateSection = [self sectionIndexForSourceSectionIndex:idx inDataSource:self.dataSource];
        if (postUpdateSection != NSNotFound) {
            [resultingUpdateCache.insertSectionsIndexes addIndex:postUpdateSection];
        }
    }];
    [updateCache.insertIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath* postUpdateIndexPath = [self indexPathForSourceIndexPath:obj inDataSource:self.dataSource];
        if (postUpdateIndexPath) {
            [resultingUpdateCache.insertIndexPaths addObject:postUpdateIndexPath];
        }
    }];

    if (animated) {
        [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:resultingUpdateCache.deleteIndexPaths];
        [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:resultingUpdateCache.deleteSectionsIndexes];
        [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:resultingUpdateCache.insertIndexPaths];
        [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:resultingUpdateCache.insertSectionsIndexes];
        [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
    } else {
        [self.cds_updateDelegate cds_dataSourceDidReload:self];
    }
}

- (void) beginUpdates
{
    if (self.nestedUpdatesCount == 0) {
        NSAssert(self.currentUpdatesCache == nil, @"new update cache should have been created yet");
        self.currentUpdatesCache = [CDSUpdateCache new];
    }
    self.nestedUpdatesCount++;
}

- (void) endUpdatesAnimated:(BOOL)animated
{
    NSAssert(self.nestedUpdatesCount > 0, @"unbalanced beginUpdates and endUpdates calls");
    self.nestedUpdatesCount--;
    if (self.nestedUpdatesCount == 0) {
        NSAssert(self.currentUpdatesCache != nil, @"there should be an update cache");
        CDSUpdateCache* updates = self.currentUpdatesCache;
        self.currentUpdatesCache = nil;
        [self updateHiddenObjectsWithUpdateCache:updates animated:animated];
    }
}

- (void) setSectionHidden:(BOOL)hidden atSourceIndex:(NSInteger)sectionIndex
{
    [self beginUpdates];
    
    if (hidden) {
        [self.currentUpdatesCache.deleteSectionsIndexes addIndex:sectionIndex];
        [self.currentUpdatesCache.insertSectionsIndexes removeIndex:sectionIndex];
    } else {
        [self.currentUpdatesCache.insertSectionsIndexes addIndex:sectionIndex];
        [self.currentUpdatesCache.deleteSectionsIndexes removeIndex:sectionIndex];
    }

    [self endUpdatesAnimated:YES];
}

- (void) setObjectHidden:(BOOL)hidden atSourceIndexPath:(NSIndexPath*)indexPath
{
    [self beginUpdates];
    
    if (hidden) {
        [self.currentUpdatesCache.deleteIndexPaths addObject:indexPath];
        [self.currentUpdatesCache.insertIndexPaths removeObject:indexPath];
    } else {
        [self.currentUpdatesCache.insertIndexPaths addObject:indexPath];
        [self.currentUpdatesCache.deleteIndexPaths removeObject:indexPath];
    }

    [self endUpdatesAnimated:YES];
}

/**************************************************************************/
#pragma mark querying

- (BOOL) isSectionHiddenAtSourceIndex:(NSInteger)sectionIndex
{
    return [self.hiddenSectionIndexes containsIndex:sectionIndex];
}

- (BOOL) isObjectHiddenAtSourceIndexPath:(NSIndexPath*)indexPath
{
    return [self.hiddenItemsIndexesBySourceSection[indexPath.cds_sectionIndex] containsIndex:indexPath.cds_objectIndex];
}

- (NSIndexSet*) visibleSectionIndexes
{
    NSMutableIndexSet* visibleSectionIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts] count])];
    [visibleSectionIndexes removeIndexes:self.hiddenSectionIndexes];
    return visibleSectionIndexes;
}

@end
