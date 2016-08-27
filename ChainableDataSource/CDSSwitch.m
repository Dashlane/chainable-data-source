//
//  CDSSwitch.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 29/12/2015.
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

#import "CDSSwitch.h"

@implementation CDSSwitch

/**************************************************************************/
#pragma mark CDSDataSource

- (NSInteger) cds_numberOfSections
{
    return self.isDisabled?0:[super cds_numberOfSections];
}

- (void) setDisabled:(BOOL)disabled
{
    if (_disabled == disabled) {
        return;
    }
    
    NSInteger sectionsBefore = [self cds_numberOfSections];
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
    
    _disabled = disabled;

    NSInteger sectionsAfter = [self cds_numberOfSections];

    if (_disabled) {
        [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionsBefore)]];
    } else {
        [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionsAfter)]];
    }

    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

- (BOOL) disabled
{
    return _disabled;
}

/**************************************************************************/
#pragma mark CDSUpdateDelegate

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self reloadFromDataSource:dataSource];
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    [self reloadFromDataSource:dataSource];
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    if (self.disabled) {
        return;
    }
    [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:indexPaths];
}

@end
