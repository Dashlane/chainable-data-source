//
//  CDSCellDataSource.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 17/12/2015.
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

#import "CDSCellDataSource.h"

#import "CDSUpdateCache.h"
#import "CDSCellOperatorProtocol.h"

@interface CDSCellDataSource ()

@property (nonatomic, strong) CDSUpdateCache* updateCache;

@end

@implementation CDSCellDataSource

@synthesize dataSource = _dataSource, cds_updateDelegate = _cds_updateDelegate;


/**************************************************************************/
#pragma mark Properties

- (void) setDataSource:(id<CDSDataSource>)dataSource
{
    if ([_dataSource isEqual:dataSource]) {
        return;
    }
    _dataSource = dataSource;
    _dataSource.cds_updateDelegate = self;
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (id<CDSCellOperator>) cds_cellOperator
{
    return [self.cds_updateDelegate conformsToProtocol:@protocol(CDSCellOperator)]?(id<CDSCellOperator>)self.cds_updateDelegate:nil;
}

/**************************************************************************/
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self cds_numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self cds_numberOfObjectsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView* cell = [self cds_objectAtIndexPath:indexPath];
    return [cell isKindOfClass:[UITableViewCell class]]?(UITableViewCell*)cell:nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self cds_nameOfSection:section];
}

/**************************************************************************/
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self cds_numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self cds_numberOfObjectsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView* cell = [self cds_objectAtIndexPath:indexPath];
    return [cell isKindOfClass:[UICollectionViewCell class]]?(UICollectionViewCell *)cell:nil;
}

/**************************************************************************/
#pragma mark cell data source

- (UIView*) cellForObjectAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [self.dataSource cds_objectAtIndexPath:indexPath];
    NSString* identifier = self.cellIdentifierOverride?:[self cellIdentifierForObject:object];
    NSIndexPath* providerIndexPath = [self.cds_cellOperator cds_convertIndexPath:indexPath fromCellDataSource:self];
    UIView* cell = [self.cds_cellOperator cds_reusableCellWithIdentifier:identifier forIndexPath:providerIndexPath];
    [self configureCell:cell withObject:object];
    return cell;
}

- (NSString*) cellIdentifierForObject:(id)object
{
    return NSStringFromClass([object class]);
}

- (void) configureCell:(UIView*)cell withObject:(id)object
{
}

/**************************************************************************/
#pragma mark CDSDataSource

- (NSInteger) cds_numberOfSections
{
    return [self.dataSource cds_numberOfSections];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    return [self.dataSource cds_numberOfObjectsInSection:sectionIndex];
}

- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self cellForObjectAtIndexPath:indexPath];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    return [self.dataSource cds_nameOfSection:sectionIndex];
}

/**************************************************************************/
#pragma mark CDSUpdateDelegate

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    self.updateCache = [CDSUpdateCache new];
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    //reconfigure cells that were just updates
    for (NSIndexPath* updateIndexPath in self.updateCache.updateIndexPaths) {
        NSIndexPath* providerIndexPath = [self.cds_cellOperator cds_convertIndexPath:updateIndexPath fromCellDataSource:self];
        UIView* cell = [self.cds_cellOperator cds_existingCellAtIndexPath:providerIndexPath];
        if (cell) {
            [self configureCell:cell withObject:[self.dataSource cds_objectAtIndexPath:updateIndexPath]];
        }
    }
    self.updateCache = nil;
    
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    [self.updateCache.updateIndexPaths addObjectsFromArray:indexPaths];
}

@end

