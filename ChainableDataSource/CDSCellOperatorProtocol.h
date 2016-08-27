//
//  CDSCellOperator.h
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

#import <UIKit/UIKit.h>

@protocol CDSCellDataSource;

/**
 This protocol abstracts the UITableView and UICollectionView functions as cell instantiators and users.
 A cell provider represents an index space in its own right, and provides facilities to convert indexPaths
 to the ChainableCellDataSources connected to it in the chain.
 */
@protocol CDSCellOperator <NSObject>

/**
 This method should instantiate/dequeue a cell ready to be configured

 @param cellIdentifier The identifier of the cell to instantiate
 @param indexPath      the destination indexPath of the cell in our index space

 @return The instantiated cell
 */
- (UIView*) cds_reusableCellWithIdentifier:(NSString*)cellIdentifier forIndexPath:(NSIndexPath*)indexPath;

/**
 Get the cell that currently exists at the given indexPath

 @param indexPath the requested indexPath in our own index space
 
 @return the existing cell (nil if no cell currently exists at that indexPath)
 */
- (UIView*) cds_existingCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 Query the indexPath for an existing cell

 @param cell the exsisting cell

 @return the index path in our index space
 */
- (NSIndexPath*) cds_indexPathForCell:(UIView*)cell;


/**
 Convert an indexPath from an upstream chained CDSCellDataSource
 
 @param indexPath      the indexPath to convert from cellDataSource's index space
 @param cellDataSource the CDSCellDataSource to convert the indexPath from. Should be found in our data source chain

 @return the converted indexPath in our index space
 */
- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath*)indexPath fromCellDataSource:(id<CDSCellDataSource>)cellDataSource;

/**
 Convert an indexPath to an upstream chained CDSCellDataSource
 
 @param indexPath      the indexPath in our index space to convert to cellDataSource's index space
 @param cellDataSource the CDSCellDataSource to convert the indexPath to. Should be found in our data source chain
 
 @return the converted indexPath in our index space
 */
- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath*)indexPath toCellDataSource:(id<CDSCellDataSource>)cellDataSource;

@end

