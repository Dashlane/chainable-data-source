//
//  UITableViewController+CDSCellDataSource.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 06/01/2016.
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

#import "UITableViewController+CDSCellDataSource.h"

#import <objc/runtime.h>

@implementation UITableViewController (CDSCellDataSource)

- (NSInteger) cds_numberOfSections
{
    return [self numberOfSectionsInTableView:self.tableView];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    return [self tableView:self.tableView numberOfRowsInSection:sectionIndex];
}

- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    return [self tableView:self.tableView titleForHeaderInSection:sectionIndex];
}

- (id<CDSUpdateDelegate>) cds_updateDelegate
{
    return nil;
}

- (void) setCds_updateDelegate:(id<CDSUpdateDelegate>)cds_updateDelegate
{
    
}

- (id<CDSCellOperator>) cds_cellOperator
{
    return objc_getAssociatedObject(self, @selector(cds_cellOperator));
}

- (void) setCds_cellOperator:(id<CDSCellOperator>)cds_cellOperator
{
    objc_setAssociatedObject(self, @selector(cds_cellOperator), cds_cellOperator, OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
