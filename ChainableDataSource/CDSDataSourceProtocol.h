//
//  ChainableDataSource.h
//  ChainableDataSource
//
//  A protocol that allows to chain datasources
//
//  Created by Amadour Griffais on 10/11/2015.
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


#import <Foundation/Foundation.h>

#import "CDSUpdateDelegateProtocol.h"

/**
 The base protocol that model objects can implement to participate in data source chains.
 Based on the usual data structure found in Cocoa Touch data sources: objects grouped into sections.
 Every method is mandatory, but cds_nameOfSection and cds_updateDelegate can return nil.
 */
@protocol CDSDataSource <NSObject>

- (NSInteger) cds_numberOfSections;
- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex;
- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex;

/**
 The delegate should be implemented and timely notified of updates of the data source content.
 If the data source content never changes, the implementation can simply return nil.
 */
@property (nonatomic, weak) id<CDSUpdateDelegate> cds_updateDelegate;

@end

