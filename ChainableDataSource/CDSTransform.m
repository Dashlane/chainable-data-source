//
//  CDSTransform.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 20/12/2015.
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

#import "CDSTransform.h"

@interface CDSTransform ()

@property (nonatomic, copy, readwrite) NSArray<CDSCountCache*>* dataSourceCaches;
@property (nonatomic, copy, readwrite) NSArray<CDSUpdateCache*>* dataSourceUpdateCaches;

@end

@implementation CDSTransform

@synthesize  cds_updateDelegate;

/**************************************************************************/
#pragma mark inint, dealloc

+ (instancetype) transformFromDataSources:(NSArray<id<CDSDataSource>>*)dataSources
{
    CDSTransform* ds = [self new];
    ds.dataSources = dataSources;
    return ds;
}

+ (instancetype) transformFromDataSource:(id<CDSDataSource>)dataSource
{
    return [self transformFromDataSources:@[dataSource]];
}


/**************************************************************************/
#pragma mark configuration

- (void) setDataSources:(NSArray<id<CDSDataSource>> *)dataSources
{
    [_dataSources enumerateObjectsUsingBlock:^(id<CDSDataSource> _Nonnull ds, NSUInteger idx, BOOL * _Nonnull stop) {
        ds.cds_updateDelegate = nil;
    }];
    
    _dataSources = [dataSources copy];

    NSMutableArray* caches = [NSMutableArray array];
    NSMutableArray* updateCaches = [NSMutableArray array];

    for (id<CDSDataSource> ds in _dataSources) {
        ds.cds_updateDelegate = self;
        CDSCountCache* cache = [CDSCountCache new];
        [caches addObject:cache];
        CDSUpdateCache* updateCache = [CDSUpdateCache new];
        [updateCaches addObject:updateCache];
    }
    
    self.dataSourceCaches = [caches copy];
    self.dataSourceUpdateCaches = [updateCaches copy];
    
    for (id<CDSDataSource> ds in _dataSources) {
        [self reloadFromDataSource:ds];
    }
    
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (void) setDataSource:(id<CDSDataSource>)dataSource
{
    self.dataSources = dataSource?@[dataSource]:nil;
}

- (id<CDSDataSource>) dataSource
{
    return self.dataSources.firstObject;
}

/**************************************************************************/
#pragma mark CDSDataSource

- (NSInteger) cds_numberOfSections
{
    return self.dataSourceCaches.firstObject.sectionsObjectCounts.count;
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    return [self.dataSourceCaches.firstObject.sectionsObjectCounts[section] integerValue];
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    if (!self.dataSourceCaches.firstObject) {
        return nil;
    }
    return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:indexPath.cds_sectionIndex inDataSource:0];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    return sourceIndexPath;
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    return sourceSection;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    return [NSIndexPath cds_indexPathForSection:section inDataSource:0];
}

- (id) cds_objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* fullIndexPath = [self sourceIndexPathForIndexPath:indexPath];
    NSUInteger dsIndex = [fullIndexPath indexAtPosition:0];
    NSIndexPath* dsIndexPath = [NSIndexPath cds_indexPathForObject:[fullIndexPath indexAtPosition:2] inSection:[fullIndexPath indexAtPosition:1]];
    return [self.dataSources[dsIndex]  cds_objectAtIndexPath:dsIndexPath];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    NSIndexPath* sourceIndexPath = [self sourceSectionIndexPathForSectionIndex:sectionIndex];
    if (sourceIndexPath) {
        return [self.dataSources[[sourceIndexPath indexAtPosition:0]] cds_nameOfSection:[sourceIndexPath indexAtPosition:1]];
    } else {
        return nil;
    }
}

/**************************************************************************/
#pragma mark caches

- (CDSCountCache*) cacheForDataSource:(id<CDSDataSource>)dataSource
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    return self.dataSourceCaches[dataSourceIndex];
}

- (void) reloadFromDataSource:(id<CDSDataSource>)dataSource
{
    CDSCountCache* cache = [self cacheForDataSource:dataSource];
    [cache refreshWithDataSource:dataSource];
}

/**************************************************************************/
#pragma mark updates

- (void) refreshFromDataSource:(id<CDSDataSource>)dataSource
                  withSourceUpdateCache:(CDSUpdateCache *)updateCache
{
    [self reloadFromDataSource:dataSource];
}

- (void) preRefreshTranslateSourceUpdateCache:(CDSUpdateCache*)sourceUpdateCache
                               fromDataSource:(id<CDSDataSource>)dataSource
                                toUpdateCache:(CDSUpdateCache*)updateCache
{
    //get the source cache
    CDSCountCache* sourceCache = [self cacheForDataSource:dataSource];

    NSMutableArray* deleteIndexPaths = updateCache.deleteIndexPaths;
    NSMutableIndexSet* deleteSections = updateCache.deleteSectionsIndexes;
    
    //Before we update our caches, compute the translated indexes for every delete
    [sourceUpdateCache.deleteSectionsIndexes enumerateIndexesUsingBlock:^(NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        //is the section 1:1 mapped on one of our sections ?
        NSInteger ownSectionIndex = [self sectionIndexForSourceSectionIndex:sectionIndex inDataSource:dataSource];
        if (ownSectionIndex == NSNotFound) {
            //if not, manually convert the section in the content index paths
            NSInteger sectionCount = [sourceCache.sectionsObjectCounts[sectionIndex] integerValue];
            
            for (NSInteger rowIndex = 0; rowIndex < sectionCount; rowIndex++) {
                NSIndexPath* sourceIndexPath = [NSIndexPath cds_indexPathForObject:rowIndex inSection:sectionIndex];
                NSIndexPath* ownIndexPath = [self indexPathForSourceIndexPath:sourceIndexPath inDataSource:dataSource];
                if (ownIndexPath) {
                    [deleteIndexPaths addObject:ownIndexPath];
                }
            }
        } else {
            //else just remove the section
            [deleteSections addIndex:ownSectionIndex];
        }
    }];
    
    [sourceUpdateCache.deleteIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath* dsIndexPath = [self indexPathForSourceIndexPath:indexPath inDataSource:dataSource];
        if (dsIndexPath) {
            [deleteIndexPaths addObject:dsIndexPath];
        }
    }];
}

- (void) postRefreshTranslateSourceUpdateCache:(CDSUpdateCache*)sourceUpdateCache
                                fromDataSource:(id<CDSDataSource>)dataSource
                                 toUpdateCache:(CDSUpdateCache*)updateCache
{
    //get the source cache
    CDSCountCache* sourceCache = [self cacheForDataSource:dataSource];

    NSMutableArray* insertIndexPaths = updateCache.insertIndexPaths;
    NSMutableIndexSet* insertSections = updateCache.insertSectionsIndexes;
    NSMutableArray* updateIndexPaths = updateCache.updateIndexPaths;
    
    [sourceUpdateCache.insertSectionsIndexes enumerateIndexesUsingBlock:^(NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        //is the section 1:1 mapped on one of our sections ?
        NSInteger ownSectionIndex = [self sectionIndexForSourceSectionIndex:sectionIndex inDataSource:dataSource];
        if (ownSectionIndex == NSNotFound) {
            //if not, manually convert the section in the content index paths
            NSInteger sectionCount = [sourceCache.sectionsObjectCounts[sectionIndex] integerValue];
            
            for (NSInteger rowIndex = 0; rowIndex < sectionCount; rowIndex++) {
                NSIndexPath* sourceIndexPath = [NSIndexPath cds_indexPathForObject:rowIndex inSection:sectionIndex];
                NSIndexPath* ownIndexPath = [self indexPathForSourceIndexPath:sourceIndexPath inDataSource:dataSource];
                if (ownIndexPath) {
                    [insertIndexPaths addObject:ownIndexPath];
                }
            }
        } else {
            //else just inert the section
            [insertSections addIndex:ownSectionIndex];
        }
    }];
    
    [sourceUpdateCache.insertIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath* dsIndexPath = [self indexPathForSourceIndexPath:indexPath inDataSource:dataSource];
        if (dsIndexPath) {
            [insertIndexPaths addObject:dsIndexPath];
        }
    }];
    
    
    [sourceUpdateCache.updateIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath* dsIndexPath = [self indexPathForSourceIndexPath:indexPath inDataSource:dataSource];
        if (dsIndexPath) {
            [updateIndexPaths addObject:dsIndexPath];
        }
    }];
}

/**************************************************************************/
#pragma mark CDSUpdateDelegate

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self reloadFromDataSource:dataSource];
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    //our cache and update cache should be up to date
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    [self.dataSourceUpdateCaches[dataSourceIndex].deleteSectionsIndexes addIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    [self.dataSourceUpdateCaches[dataSourceIndex].insertSectionsIndexes addIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    [self.dataSourceUpdateCaches[dataSourceIndex].deleteIndexPaths addObjectsFromArray:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    [self.dataSourceUpdateCaches[dataSourceIndex].insertIndexPaths addObjectsFromArray:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");
    [self.dataSourceUpdateCaches[dataSourceIndex].updateIndexPaths addObjectsFromArray:indexPaths];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    NSInteger dataSourceIndex = [self.dataSources indexOfObject:dataSource];
    NSAssert(dataSourceIndex != NSNotFound, @"dataSource not found in dataSources array");

    //get the source updates to apply
    CDSUpdateCache* sourceUpdateCache = self.dataSourceUpdateCaches[dataSourceIndex];
    
    //prepare the updates to apply to ourselves
    CDSUpdateCache* updateCache = [CDSUpdateCache new];
    
    //perform all the pre refresh translations (deletes)
    [self preRefreshTranslateSourceUpdateCache:sourceUpdateCache
                                fromDataSource:dataSource
                                 toUpdateCache:updateCache];
    
    //now that every delete is handled, refresh our cache object count to reflect the new state
    //and properly convert the inserted index paths
    [self refreshFromDataSource:dataSource withSourceUpdateCache:sourceUpdateCache];
    
    //perform all the post refresh translations (insert/updates)
    [self postRefreshTranslateSourceUpdateCache:sourceUpdateCache
                                 fromDataSource:dataSource
                                  toUpdateCache:updateCache];
    
    //notify our data source delegate
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
    [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:updateCache.deleteIndexPaths];
    [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:updateCache.deleteSectionsIndexes];
    [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:updateCache.insertIndexPaths];
    [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:updateCache.insertSectionsIndexes];
    [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:updateCache.updateIndexPaths];
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];

    [sourceUpdateCache reset];
}

@end

