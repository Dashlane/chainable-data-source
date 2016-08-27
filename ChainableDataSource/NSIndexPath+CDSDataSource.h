//
//  NSIndexPath+CDSDataSource.h
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

@interface NSIndexPath (CDSDataSource)

//"classic" index path mapping, compatible with UIKit row/section
+ (NSIndexPath*) cds_indexPathForObject:(NSInteger)objectIndex inSection:(NSInteger)sectionIndex;

//length 3 index path to reference an object in a data source array
+ (NSIndexPath*) cds_indexPathForObject:(NSInteger)objectIndex inSection:(NSInteger)sectionIndex inDataSource:(NSInteger)dataSourceIndex;

//length 2 index path to reference a section in a data source array
+ (NSIndexPath*) cds_indexPathForSection:(NSInteger)sectionIndex inDataSource:(NSInteger)dataSourceIndex;

//the following assume length 2 index path are "classic", length 3 are prefixed by the data source index
@property (nonatomic, readonly) NSInteger cds_dataSourceIndex;
@property (nonatomic, readonly) NSInteger cds_sectionIndex;
@property (nonatomic, readonly) NSInteger cds_objectIndex;
@property (nonatomic, readonly) NSIndexPath* cds_indexPathInDataSource;

@end
