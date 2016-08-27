//
//  FruitCellDataSource.h
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

#import <ChainableDataSource/ChainableDataSource.h>

/**
 Our sample cell data source for displaying fruits.
 Note that it can be reused in several view controllers, allowing factorization of common data source
 behaviors.
 Simply display fruit name in a cell and display its wikipedia page on selection.
 If the object is a NSManagedObject, swipe to delete is enabled
 */
@interface FruitCellDataSource : CDSCellDataSource

@end
