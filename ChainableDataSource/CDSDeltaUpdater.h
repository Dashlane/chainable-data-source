//
//  CDSDeltaUpdater.h
//  ChainableDataSource
//
//  This data source turns data source reload into optimal insertion/deletion of items
//  WARNING: do not use with a potentially large item count before remplementing the subsequence algo (see implementation)
//
//  Created by Amadour Griffais on 02/12/2015.
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

#import "CDSDataSourceProtocol.h"

/**
 Turns reload of a data source into set of updates including just the objects that where inserted and removed. Can also perform the same operation between two different data sources (eg 2 slightly different NSArrays) using setDataSource:animated:.
 Caveat: the content of the data source needs to be cached at all time to be ready to perform the update when a relaod message arrives. This means every object of the source will be queried when the data source is set, so do not use if the is an issue.
 */
@interface CDSDeltaUpdater : NSObject <CDSDataSource, CDSUpdateDelegate>

+ (instancetype) deltaUpdateDataSourceWithDataSource:(id<CDSDataSource>)dataSource;

@property (nonatomic, strong) id<CDSDataSource> dataSource; //The source object whose reloads are turned into updates
- (void) setDataSource:(id<CDSDataSource>)dataSource animated:(BOOL)animated; //Switch our data source, optionally in an animation fashion.
@property (nonatomic, assign, getter=isDeltaUpdateDisabled) BOOL deltaUpdateDisabled; //disable delta updates, reloads will ot be turned into update
@property (nonatomic, assign) BOOL matchesUnnamedSections; //If there are several sections in the compared states, the list of sections will first be diffed using section name to detect section insertions/deletions. Set this to YES to assume sections whose name is not set can still be compared (eg while comparing 2 NSArrays)
@property (nonatomic, assign) BOOL sendUpdateMessagesOnReload; //set this to YES to send an update message for pre-existing items when a delta update was performed instead of a reload
@property (nonatomic, strong) BOOL(^comparisonBlock)(id obj1, id obj2); //this block is used to compare objects while performing the diff. By default (nil value), isEqual is used to compare objects.
@property (nonatomic, assign) NSUInteger itemCountLimit; //Set this to a positive number to disable diffing if too many objects are involved. (default is 0, means no limit to how many objects can be compared)

@end

