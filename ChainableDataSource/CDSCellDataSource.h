//
//  CDSCellDataSource.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 17/12/2015.
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

#import "CDSCellDataSourceProtocol.h"

@protocol CDSCellDataSource, CDSCellOperator;

/**
 A basic implementation of the CDSCellDataSource protocol using cells mapped from model objects provided by a chained data source.
 Forward every updateDelegate methods to its own updateDelegate, except update messages. The latter will simply trigger a reconfiguration of the target cell.
 The default implementation is a stub meant to be overridden.
 */
@interface CDSCellDataSource : NSObject <CDSCellDataSource, CDSUpdateDelegate>

/**
 The data source whose objects will be mapped to cells
 */
@property (nonatomic, strong) id<CDSDataSource> dataSource;

/**
 Configure the instantiated cell with the source object. Default implementation does nothing, must be overridden.
 
 @param cell   The instantiated cell
 @param object The source object
 */
- (void) configureCell:(UIView*)cell withObject:(id)object;

/**
 Override to return the cell identifier to instantiate/dequeue for a given object. The default implementation returns the source objects class name.

 @param object the source object from our data source

 @return the cell identifier to override
 */
- (NSString*) cellIdentifierForObject:(id)object;

/**
 Alternatively to overriding some of the above methods, the following method can be overriden to completely customze the cell instanciation/configuration process

 @param indexPath the indexPath for cell

 @return The instanciated and configured cell
 */
- (UIView*) cellForObjectAtIndexPath:(NSIndexPath*)indexPath;

/**
 If set, this value is always used instead of calling cellIdentifierForObject:
 */
@property (nonatomic, copy) NSString* cellIdentifierOverride;

@end

