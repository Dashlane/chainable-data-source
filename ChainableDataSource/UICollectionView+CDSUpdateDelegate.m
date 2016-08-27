//
//  UICollectionView+CDSUpdateDelegate.m
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

#import "UICollectionView+CDSUpdateDelegate.h"

#import <objc/runtime.h>

#import "CDSUpdateCache.h"

/**************************************************************************/
#pragma mark  UICollectionView (CDSUpdateDelegate)

@implementation UICollectionView (CDSUpdateDelegate)

- (CDSUpdateCache*) cds_updateCache
{
    CDSUpdateCache* cache = objc_getAssociatedObject(self, @selector(cds_updateCache));
    if (!cache) {
        cache = [CDSUpdateCache new];
        objc_setAssociatedObject(self, @selector(cds_updateCache), cache, OBJC_ASSOCIATION_RETAIN);
    }
    return cache;
}

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self reloadData];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    [[self cds_updateCache] reset];
    //make sure that reload data is called if necessary before starting a delta update, to be in sync with the data source
    [self layoutIfNeeded];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    [[[self cds_updateCache] deleteSectionsIndexes] addIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    [[[self cds_updateCache] insertSectionsIndexes] addIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [[[self cds_updateCache] deleteIndexPaths] addObjectsFromArray:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [[[self cds_updateCache] insertIndexPaths] addObjectsFromArray:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [[[self cds_updateCache] updateIndexPaths] addObjectsFromArray:indexPaths];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    [self performBatchUpdates:^{
        //reload
        if ([[[self cds_updateCache] updateIndexPaths] count] > 0) {
            [self reloadItemsAtIndexPaths:[[self cds_updateCache] updateIndexPaths]];
        }

        //delete
        if ([[[self cds_updateCache] deleteIndexPaths] count] > 0) {
            [self deleteItemsAtIndexPaths:[[self cds_updateCache] deleteIndexPaths]];
        }

        [self deleteSections:[[self cds_updateCache] deleteSectionsIndexes]];
        
        //insert
        [self insertSections:[[self cds_updateCache] insertSectionsIndexes]];

        if ([[[self cds_updateCache] insertIndexPaths] count] > 0) {
            [self insertItemsAtIndexPaths:[[self cds_updateCache] insertIndexPaths]];
        }
    } completion:nil];
    [[self cds_updateCache] reset];
}

@end

