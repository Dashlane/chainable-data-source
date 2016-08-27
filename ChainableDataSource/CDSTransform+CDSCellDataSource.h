//
//  CDSTransform+CDSCellDataSource.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 21/12/2015.
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

#import "CDSTransform.h"

#import "CDSCellOperatorProtocol.h"
#import "CDSCellDataSourceProtocol.h"

/**
 This category makes CDSTransform conform to both CDSCellDataSource and CDSCellOperator protocols, allowing it to be inserted
 in a data source chain between a CDSCellDataSource and its CDSCellOperator.
 Any UITableView/UICollectionView data source / delegate message sent to the object and involving an index path as an argument
 will be forwarded to the appropriate data source depending on the indexPath argument, and the indexPath argument will be converted to the
 target data source space.
 This allows mixing ChainableCellDataSources in the same way as other data sources. CDSCellDataSource can then be implemented completely
 independently of each other, allowing for complex behaviours in tables.
 Caveats: 
 - While the section and indexPath arguments passed to the final call to the CDSCellDataSource are converted to the CDSCellDataSource index space,
 if calls are made on the root CDSCellOperator (table or collection view) directly, the indexPath must first be converted back using the methods of the CDSCellOperator protocol.
 - If some delegate and data source methods are implemented on only some, not all, of the mixed ChainableCellDataSources, the intermediate CDSTransform
 will respond YES to respondsToSelector for these methods, but will never forward them to ChainableCellDataSources that do not implement them, which would usually
 confuse the UITableView/UICollection view making the call in the first place. Thus it is good practice to implement the same set of methods in all
 finals ChainableCellDataSources.
 */
@interface CDSTransform (CDSCellDataSource) <CDSCellOperator, CDSCellDataSource>

/**
 UITableView and UICollectionView delegate and data source calls are always forwarded if possible, other selectors to be forwarded
 can be specified by addding them to this array
 */
@property (nonatomic, copy) NSArray<NSString*>* forwardedIndexPathAndSectionSelectors;

@end
