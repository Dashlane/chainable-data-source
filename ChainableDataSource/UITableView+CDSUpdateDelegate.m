//
//  UITableView+CDSUpdateDelegate.m
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

#import "UITableView+CDSUpdateDelegate.h"

/**************************************************************************/
#pragma mark  UITableView (CDSUpdateDelegate)

@implementation UITableView (CDSUpdateDelegate)

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self reloadData];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    [self beginUpdates];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    [self deleteSections:sectionIndexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    [self insertSections:sectionIndexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    [self endUpdates];
}

@end

