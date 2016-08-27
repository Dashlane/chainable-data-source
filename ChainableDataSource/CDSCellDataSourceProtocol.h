//
//  CDSCellDataSourceProtocol.h
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

#import "CDSDataSourceProtocol.h"

@protocol CDSCellOperator;

/**
 Extends CDSDataSource to implement UITableView and UICollectionView data source and delegate methods.
 */
@protocol CDSCellDataSource <CDSDataSource, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

/**
 @return The table view or collection view, (or a downstream data source) our cells are being fed to. Usually is our cds_updateDelegate.
 */
- (id<CDSCellOperator>) cds_cellOperator;

@end

