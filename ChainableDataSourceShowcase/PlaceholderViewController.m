//
//  PlaceholderViewController.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 22/09/2016.
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

#import "PlaceholderViewController.h"

#import <ChainableDataSource/ChainableDataSource.h>
#import "FruitCellDataSource.h"

@interface PlaceholderViewController () <UISearchBarDelegate>

@property (nonatomic, strong) id<CDSCellDataSource> cellDataSource;
@property (nonatomic, weak) CDSPredicateFilter* filterDataSource;

@end

@implementation PlaceholderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray* fruits = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fruits" withExtension:@"plist"]];
    
    CDSPredicateFilter* fds = [CDSPredicateFilter transformFromDataSource:fruits];
    fds.filterPredicate = [NSPredicate predicateWithFormat:@"$filterText == nil OR $filterText.length == 0 OR self CONTAINS[cd] $filterText"];
    self.filterDataSource = fds;
    
    CDSDeltaUpdater* dds = [CDSDeltaUpdater deltaUpdateDataSourceWithDataSource:self.filterDataSource];
    dds.itemCountLimit = 20;
    dds.matchesUnnamedSections = YES;
    
    CDSCellDataSource* cds = [FruitCellDataSource new];
    cds.dataSource = dds;
    
    CDSCellDataSource* placeholderCDS = [CDSCellDataSource new];
    placeholderCDS.cellIdentifierOverride = @"placeholder-cell";
    placeholderCDS.dataSource = @[@"placeholder info"];
    
    self.cellDataSource = [CDSPlaceholder transformFromDataSources:@[cds, placeholderCDS]];
    
    self.tableView.dataSource = self.cellDataSource;
    self.tableView.delegate = self.cellDataSource;
    self.cellDataSource.cds_updateDelegate = self.tableView;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterDataSource.filterText = searchText;
}

@end
