//
//  CDSUpdateDelegateProtocol.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 21/09/2016.
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

#import <Foundation/Foundation.h>

@protocol CDSDataSource;

/**
 This protocol allow data sources to notify of their changes.
 The callbacks mirror those existing in Cocoa Touch for UITableView/UICollectionView/NSFectchedResultsController updates.
 They should follow the same logic:
 - delete indexPath are expressed in the state the source was before starting the update
 - insert/update indexPath are expressed in the state the source is after performing the update
 */
@protocol CDSUpdateDelegate <NSObject>

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource;
- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource;
- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes;
- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes;
- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource;

@end
