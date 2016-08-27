//
//  CDSUpdateCache.m
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

#import "CDSUpdateCache.h"

@implementation CDSUpdateCache

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void) reset
{
    _deleteIndexPaths = [NSMutableArray array];
    _insertIndexPaths = [NSMutableArray array];
    _updateIndexPaths = [NSMutableArray array];
    _deleteSectionsIndexes = [NSMutableIndexSet indexSet];
    _insertSectionsIndexes = [NSMutableIndexSet indexSet];
}

- (void) addUpdatesFromCache:(CDSUpdateCache*)otherUpdateCache
{
    [self.deleteSectionsIndexes addIndexes:otherUpdateCache.deleteSectionsIndexes];
    [self.deleteIndexPaths addObjectsFromArray:otherUpdateCache.deleteIndexPaths];
    [self.insertSectionsIndexes addIndexes:otherUpdateCache.insertSectionsIndexes];
    [self.insertIndexPaths addObjectsFromArray:otherUpdateCache.insertIndexPaths];
    [self.updateIndexPaths addObjectsFromArray:otherUpdateCache.updateIndexPaths];
}

- (NSString*) debugDescription
{
    NSMutableString* description = [NSMutableString string];
    [description appendFormat:@"%d section deleted\n", (int)self.deleteSectionsIndexes.count];
    [description appendFormat:@"%d section inserted\n", (int)self.insertSectionsIndexes.count];
    [description appendFormat:@"%d objects deleted\n", (int)self.deleteIndexPaths.count];
    [description appendFormat:@"%d objects inserted\n", (int)self.insertIndexPaths.count];
    [description appendFormat:@"%d objects updated\n", (int)self.updateIndexPaths.count];
    return description;
}

@end

