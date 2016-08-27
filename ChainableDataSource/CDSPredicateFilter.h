//
//  CDSPredicateFilter.h
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

#import "CDSDataSourceProtocol.h"

#import "CDSTransform.h"

/**
 Filter elements of its data source by applying a predicate to them.
 The filter updates are full reloads, so this can be chained with a Delta Updater for an animated filter.
 */
@interface CDSPredicateFilter : CDSTransform

+ (instancetype) filterDataSourceWithPredicate:(NSPredicate*)predicate dataSource:(id<CDSDataSource>)dataSource;

@property (nonatomic, strong) NSPredicate* filterPredicate; //can use a variable 'filterText' to be updated when filter text change, or can be anything else
@property (nonatomic, copy) NSString* filterText; //updating this refreshes results by applying a predicate with the new filter text
@property (nonatomic, assign) NSTimeInterval filterTextDelay; //if set to positive value, filtering is trigerring only after filter text is done typing
- (void) reload; //refresh the results

@end
