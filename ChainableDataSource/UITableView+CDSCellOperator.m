//
//  UITableView+CDSCellOperator.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 20/09/2016.
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

#import "UITableView+CDSCellOperator.h"

@implementation UITableView (CDSCellOperator)

- (UIView*) cds_reusableCellWithIdentifier:(NSString*)cellIdentifier forIndexPath:(NSIndexPath*)indexPath
{
    return [self dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
}

- (UIView*) cds_existingCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath*) cds_indexPathForCell:(UIView*)cell
{
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        return [self indexPathForCell:(UITableViewCell*)cell];
    } else {
        return nil;
    }
}

- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath*)indexPath fromCellDataSource:(id<CDSCellDataSource>)cellDataSource
{
    if ((id)self.dataSource == (id)cellDataSource) {
        return indexPath;
    } else if ([self.dataSource conformsToProtocol:@protocol(CDSCellOperator)]) {
        return [(id<CDSCellOperator>)self.dataSource cds_convertIndexPath:indexPath fromCellDataSource:cellDataSource];
    } else {
        return nil;
    }
}

- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath *)indexPath toCellDataSource:(id<CDSCellDataSource>)cellDataSource
{
    if ((id)self.dataSource == (id)cellDataSource) {
        return indexPath;
    } else if ([self.dataSource conformsToProtocol:@protocol(CDSCellOperator)]) {
        return [(id<CDSCellOperator>)self.dataSource cds_convertIndexPath:indexPath toCellDataSource:cellDataSource];
    } else {
        return nil;
    }
}

@end

