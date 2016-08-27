//
//  CDSPredicateFilter.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 06/12/2015.
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

#import "CDSPredicateFilter.h"

@interface CDSPredicateFilter ()

//this is the value of the 
@property (nonatomic, strong) NSMutableArray<NSMutableIndexSet*>* matchingSourceIndexesBySourceSection;
@property (nonatomic, strong) NSTimer* filterTextTimer;

@end

@implementation CDSPredicateFilter

/**************************************************************************/
#pragma mark factory

+ (instancetype) filterDataSourceWithPredicate:(NSPredicate*)predicate dataSource:(id<CDSDataSource>)dataSource
{
    CDSPredicateFilter* instance = [self new];
    instance.dataSource = dataSource;
    instance.filterPredicate = predicate;
    return instance;
}

/**************************************************************************/
#pragma mark CDSDataSource

- (NSInteger) cds_numberOfSections
{
    return [[[self cacheForDataSource:self.dataSource] sectionsObjectCounts] count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    NSInteger sourceSection = [[self sourceSectionIndexPathForSectionIndex:sectionIndex] indexAtPosition:1];
    return [self.matchingSourceIndexesBySourceSection[sourceSection] count];
}

- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sourceSection = [[self sourceSectionIndexPathForSectionIndex:indexPath.cds_sectionIndex] indexAtPosition:1];
    NSIndexSet* matchingIndexes = self.matchingSourceIndexesBySourceSection[sourceSection];
    NSInteger row = indexPath.cds_objectIndex;
    NSInteger sourceRow = [matchingIndexes firstIndex];
    while (row > 0) {
        if (sourceRow == NSNotFound) {
            return nil;
        }
        sourceRow = [matchingIndexes indexGreaterThanIndex:sourceRow];
        row--;
    }
    return [NSIndexPath cds_indexPathForObject:sourceRow inSection:sourceSection inDataSource:0];
}

- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource
{
    NSIndexSet* matchingIndexes = self.matchingSourceIndexesBySourceSection[sourceIndexPath.cds_sectionIndex];
    if (![matchingIndexes containsIndex:sourceIndexPath.cds_objectIndex]) {
        return nil;
    }

    NSInteger section = [self sectionIndexForSourceSectionIndex:sourceIndexPath.cds_sectionIndex inDataSource:sourceDataSource];
    NSInteger row = [matchingIndexes countOfIndexesInRange:NSMakeRange(0, sourceIndexPath.cds_objectIndex)];
    return [NSIndexPath cds_indexPathForObject:row inSection:section];
}

- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource
{
    return sourceSection;
}

- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section
{
    return [NSIndexPath cds_indexPathForSection:section inDataSource:0];
}

/**************************************************************************/
#pragma mark Properties

- (void) setFilterPredicate:(NSPredicate *)filterPredicate
{
    _filterPredicate = filterPredicate;
    [self reload];
}

- (void) setFilterText:(NSString *)filterText
{
    _filterText = [filterText copy];
    if (self.filterTextDelay > 0) {
        [self resetFilterTextTimer:self.filterTextDelay];
    } else {
        [self reload];
    }
}

- (void) resetFilterTextTimer:(NSTimeInterval)delay
{
    [self.filterTextTimer invalidate];
    self.filterTextTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(reload) userInfo:nil repeats:NO];
}


- (void) reload
{
    [self reloadFromDataSource:self.dataSource];
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (void) reloadFromDataSource:(id<CDSDataSource>)dataSource
{
    [super reloadFromDataSource:dataSource];
    [self reloadFilterResults];
}

- (void) refreshFromDataSource:(id<CDSDataSource>)dataSource withSourceUpdateCache:(CDSUpdateCache *)updateCache
{
    [self reloadFromDataSource:dataSource];
}

/**************************************************************************/
#pragma mark filtering

- (void) reloadFilterResults
{
    CDSCountCache* dataSourceCache = [self cacheForDataSource:self.dataSource];
    NSInteger sectionCount = [[dataSourceCache sectionsObjectCounts] count];
    NSMutableArray* sections = [NSMutableArray array];
    for (NSInteger section = 0; section < sectionCount; section++) {
        [sections addObject:[NSMutableIndexSet indexSet]];
    }
    self.matchingSourceIndexesBySourceSection = sections;
    for (NSInteger section = 0; section < sectionCount; section++) {
        [self reloadFilteredIndexesForSourceSection:section];
    }
}

- (void) reloadFilteredIndexesForSourceSection:(NSInteger)sectionIndex
{
    CDSCountCache* dataSourceCache = [self cacheForDataSource:self.dataSource];
    NSInteger rowCount = [[dataSourceCache sectionsObjectCounts][sectionIndex] integerValue];
    NSMutableIndexSet* indexes = self.matchingSourceIndexesBySourceSection[sectionIndex];
    [indexes removeAllIndexes];
    for (NSInteger row = 0; row < rowCount; row++) {
        if ([self isSourceObjectAtIndexPathMatchingFilter:[NSIndexPath cds_indexPathForObject:row inSection:sectionIndex]]) {
            [indexes addIndex:row];
        }
    }
}

- (BOOL) isSourceObjectAtIndexPathMatchingFilter:(NSIndexPath*)indexPath
{
    id sourceObject = [self.dataSource cds_objectAtIndexPath:indexPath];
    
    NSDictionary* variables = self.filterText ? @{@"filterText":self.filterText} : @{@"filterText":[NSNull null]};
    
    return !self.filterPredicate || [self.filterPredicate evaluateWithObject:sourceObject
                                                       substitutionVariables:variables];
}

@end
