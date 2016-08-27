//
//  CDSPlaceholder.m
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

#import "CDSPlaceholder.h"

@interface CDSPlaceholder()

@property (nonatomic, assign) NSInteger numberOfSectionsInMainDataSourceBeforeUpdate;
@property (nonatomic, assign) NSInteger numberOfSectionsInCDSPlaceholderBeforeUpdate;
@property (nonatomic, assign) BOOL isTogglingPlaceholder;

@end

@implementation CDSPlaceholder

- (BOOL) shouldDisplayPlaceholder
{
    return self.dataSourceCaches.count > 1 && [self.dataSourceCaches.firstObject objectCount] == 0;
}

- (id<CDSDataSource>) mainDataSource {
    return self.dataSources.firstObject;
}

- (id<CDSDataSource>) placeholderDataSource {
    return self.dataSourceCaches.count > 1 ? self.dataSources[1] : nil;
}

- (id<CDSDataSource>) displayedDataSource
{
    return [self shouldDisplayPlaceholder] ? self.dataSources[1] : self.dataSources.firstObject;
}

/**************************************************************************/
#pragma mark forward implementation

- (NSInteger) cds_numberOfSections
{
    return [[[self cacheForDataSource:[self displayedDataSource]]  sectionsObjectCounts] count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section
{
    return [[[self cacheForDataSource:[self displayedDataSource]]  sectionsObjectCounts][section] integerValue];
}
- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger dataSourceIndex = [self shouldDisplayPlaceholder]? 1 : 0;
    return [NSIndexPath cds_indexPathForObject:indexPath.cds_objectIndex inSection:indexPath.cds_sectionIndex inDataSource:dataSourceIndex];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    BOOL isDisplaying = sourceDataSource == [self displayedDataSource];
    return isDisplaying ? sourceIndexPath : nil;
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    BOOL isDisplaying = sourceDataSource == [self displayedDataSource];
    return isDisplaying ? sourceSection : NSNotFound;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    NSInteger dataSourceIndex = [self shouldDisplayPlaceholder]? 1 : 0;
    return [NSIndexPath cds_indexPathForSection:section inDataSource:dataSourceIndex];
}

/**************************************************************************/
#pragma mark backward (updates) implementation

- (void) refreshFromDataSource:(id<CDSDataSource>)dataSource withSourceUpdateCache:(CDSUpdateCache *)updateCache
{
    self.numberOfSectionsInMainDataSourceBeforeUpdate = [[[self cacheForDataSource:[self mainDataSource]] sectionsObjectCounts] count];
    self.numberOfSectionsInCDSPlaceholderBeforeUpdate = [[[self cacheForDataSource:[self placeholderDataSource]] sectionsObjectCounts] count];
    BOOL wasDisplayingPlaceholder = [self shouldDisplayPlaceholder];
    [super refreshFromDataSource:dataSource withSourceUpdateCache:updateCache];
    BOOL isDisplayingPlaceholder = [self shouldDisplayPlaceholder];
    self.isTogglingPlaceholder = wasDisplayingPlaceholder != isDisplayingPlaceholder;
}

- (void) postRefreshTranslateSourceUpdateCache:(CDSUpdateCache *)sourceUpdateCache fromDataSource:(id<CDSDataSource>)dataSource toUpdateCache:(CDSUpdateCache *)updateCache
{
    if (self.isTogglingPlaceholder) {
        [updateCache reset];
        if ([self shouldDisplayPlaceholder]) {
            [updateCache.deleteSectionsIndexes addIndexesInRange:NSMakeRange(0, self.numberOfSectionsInMainDataSourceBeforeUpdate)];
            [updateCache.insertSectionsIndexes addIndexesInRange:NSMakeRange(0, [[[self cacheForDataSource:[self placeholderDataSource]] sectionsObjectCounts] count])];
        } else {
            [updateCache.deleteSectionsIndexes addIndexesInRange:NSMakeRange(0, self.numberOfSectionsInCDSPlaceholderBeforeUpdate)];
            [updateCache.insertSectionsIndexes addIndexesInRange:NSMakeRange(0, [[[self cacheForDataSource:[self mainDataSource]] sectionsObjectCounts] count])];
        }
    } else {
        [super postRefreshTranslateSourceUpdateCache:sourceUpdateCache fromDataSource:dataSource toUpdateCache:updateCache];
    }
}

@end
