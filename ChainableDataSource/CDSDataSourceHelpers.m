//
//  ChainableDataSourceHelpers.m
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

#import "CDSDataSourceHelpers.h"
#import "NSIndexPath+CDSDataSource.h"

@implementation CDSDataSource

+ (NSArray*) objectsBySectionsWithDataSource:(id<CDSDataSource>)dataSource
{
    NSMutableArray* sections = [NSMutableArray array];
    for (NSInteger section = 0; section < [dataSource cds_numberOfSections]; section++) {
        NSMutableArray* objects = [NSMutableArray array];
        for (NSInteger row = 0; row < [dataSource cds_numberOfObjectsInSection:section]; row++) {
            [objects addObject:[dataSource cds_objectAtIndexPath:[NSIndexPath cds_indexPathForObject:row inSection:section]]];
        }
        [sections addObject:[objects copy]];
    }
    return [sections copy];
}

+ (NSArray*) allObjectsInDataSource:(id<CDSDataSource>)dataSource {
    NSMutableArray* objects = [NSMutableArray array];
    for (NSInteger section = 0; section < [dataSource cds_numberOfSections]; section++) {
        for (NSInteger row = 0; row < [dataSource cds_numberOfObjectsInSection:section]; row++) {
            [objects addObject:[dataSource cds_objectAtIndexPath:[NSIndexPath cds_indexPathForObject:row inSection:section]]];
        }
    }
    return [objects copy];
}

+ (NSArray*) sectionsNamesWithDataSource:(id<CDSDataSource>)dataSource
{
    NSMutableArray* names = [NSMutableArray array];
    for (NSInteger section = 0; section < [dataSource cds_numberOfSections]; section++) {
        NSString* name = [dataSource cds_nameOfSection:section];
        [names addObject:name?:[NSNull null]];
    }
    return [names copy];
}

+ (NSInteger) totalNumberOfObjectsInDataSource:(id<CDSDataSource>)dataSource
{
    NSInteger count = 0;
    for (NSInteger section = 0; section < [dataSource cds_numberOfSections]; section++) {
        count += [dataSource cds_numberOfObjectsInSection:section];
    }
    return count;
}

+ (void) enumerateObjectsInDataSource:(id<CDSDataSource>)dataSource withBlock:(void(^)(id object, NSInteger section, NSInteger row))block
{
    if (!block) {
        return;
    }
    NSInteger sectionCount = [dataSource cds_numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger rowCount = [dataSource cds_numberOfObjectsInSection:section];
        for (NSInteger row = 0; row < rowCount; row++) {
            block([dataSource cds_objectAtIndexPath:[NSIndexPath cds_indexPathForObject:row inSection:section]], section, row);
        }
    }
}

+ (NSIndexPath*) cds_indexPathInDataSource:(id<CDSDataSource>)dataSource forObject:(id)dataSourceObject
{
    __block NSIndexPath* ip = nil;
    [self enumerateObjectsInDataSource:dataSource withBlock:^(id object, NSInteger section, NSInteger row) {
        if (ip) {
            return ;
        }
        if ([dataSourceObject isEqual:object]) {
            ip = [NSIndexPath cds_indexPathForObject:row inSection:section];
        }
    }];
    return ip;
}

@end
