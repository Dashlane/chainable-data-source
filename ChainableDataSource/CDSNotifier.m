//
//  CDSNotifier.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 07/03/2016.
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

#import "CDSNotifier.h"

NSString* CDSNotifierDidUpdateNotification = @"CDSNotifierDidUpdateNotification";
NSString* CDSNotifierDidReloadNotification = @"CDSNotifierDidReloadNotification";

@implementation CDSNotifier

@synthesize cds_updateDelegate;

+ (instancetype) notifierFromDataSource:(id<CDSDataSource>)dataSource
{
    return [[self alloc] initWithDataSource:dataSource];
}

- (instancetype) initWithDataSource:(id<CDSDataSource>)dataSource
{
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
    }
    return self;
}

/**************************************************************************/
#pragma mark properties

- (void) setDataSource:(id<CDSDataSource>)dataSource
{
    _dataSource = dataSource;
    _dataSource.cds_updateDelegate = self;
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDSNotifierDidReloadNotification object:self];
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
    return [self.dataSource cds_objectAtIndexPath:indexPath];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CDSNotifierDidReloadNotification object:self];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDSNotifierDidUpdateNotification object:self];
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
    [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:indexPaths];
}

@end
