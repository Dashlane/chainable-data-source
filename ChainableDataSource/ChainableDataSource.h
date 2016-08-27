//
//  ChainableDataSource.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 27/08/2016.
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

#import <UIKit/UIKit.h>

//! Project version number for CDSDataSource.
FOUNDATION_EXPORT double ChainableDataSourceVersionNumber;

//! Project version string for CDSDataSource.
FOUNDATION_EXPORT const unsigned char ChainableDataSourceVersionString[];

//Base protocol
#import <ChainableDataSource/CDSDataSourceProtocol.h>
#import <ChainableDataSource/CDSUpdateDelegateProtocol.h>
#import <ChainableDataSource/CDSDataSourceHelpers.h>

//Extensions
#import <ChainableDataSource/NSArray+CDSDataSource.h>
#import <ChainableDataSource/UITableView+CDSUpdateDelegate.h>
#import <ChainableDataSource/UITableViewController+CDSCellDataSource.h>
#import <ChainableDataSource/UICollectionView+CDSUpdateDelegate.h>
#import <ChainableDataSource/NSIndexPath+CDSDataSource.h>

//Concrete implementations
#import <ChainableDataSource/CDSFetchWrapper.h>
#import <ChainableDataSource/CDSConcatenatedSections.h>
#import <ChainableDataSource/CDSFlattener.h>
#import <ChainableDataSource/CDSDeltaUpdater.h>
#import <ChainableDataSource/CDSSwitch.h>
#import <ChainableDataSource/CDSPredicateFilter.h>
#import <ChainableDataSource/CDSEmptySectionFilter.h>
#import <ChainableDataSource/CDSManualFilter.h>
#import <ChainableDataSource/CDSNotifier.h>
#import <ChainableDataSource/CDSPlaceholder.h>
#import <ChainableDataSource/CDSInsert.h>

//Cell Data Sources
#import <ChainableDataSource/CDSCellDataSourceProtocol.h>
#import <ChainableDataSource/CDSCellDataSource.h>
#import <ChainableDataSource/CDSCellOperatorProtocol.h>
#import <ChainableDataSource/UITableView+CDSCellOperator.h>
#import <ChainableDataSource/UICollectionView+CDSCellOperator.h>
#import <ChainableDataSource/CDSTransform+CDSCellDataSource.h>
