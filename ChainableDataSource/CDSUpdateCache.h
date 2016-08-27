//
//  CDSUpdateCache.h
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
 Helper class to store index changes during updates
 */
@interface CDSUpdateCache : NSObject

@property (nonatomic, readonly) NSMutableArray<NSIndexPath*> *deleteIndexPaths;
@property (nonatomic, readonly) NSMutableArray<NSIndexPath*> *insertIndexPaths;
@property (nonatomic, readonly) NSMutableArray<NSIndexPath*> *updateIndexPaths;
@property (nonatomic, readonly) NSMutableIndexSet *deleteSectionsIndexes;
@property (nonatomic, readonly) NSMutableIndexSet *insertSectionsIndexes;

- (void) reset;
- (void) addUpdatesFromCache:(CDSUpdateCache*)otherUpdateCache;

@end

