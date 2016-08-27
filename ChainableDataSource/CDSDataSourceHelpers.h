//
//  ChainableDataSourceHelpers.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 28/08/2016.
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
 Helper methods for classes implementing CDSDataSource.
 */
@interface CDSDataSource : NSObject

+ (NSArray*) objectsBySectionsWithDataSource:(id<CDSDataSource>)dataSource;
+ (NSArray*) allObjectsInDataSource:(id<CDSDataSource>)dataSource;
+ (NSArray*) sectionsNamesWithDataSource:(id<CDSDataSource>)dataSource;
+ (NSInteger) totalNumberOfObjectsInDataSource:(id<CDSDataSource>)dataSource;
+ (void) enumerateObjectsInDataSource:(id<CDSDataSource>)dataSource withBlock:(void(^)(id object, NSInteger section, NSInteger row))block;
+ (NSIndexPath*) cds_indexPathInDataSource:(id<CDSDataSource>)dataSource forObject:(id)dataSourceObject;

@end
