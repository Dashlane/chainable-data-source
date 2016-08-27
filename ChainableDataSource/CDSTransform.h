//
//  CDSTransform.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 20/12/2015.
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

#import "CDSDataSourceProtocol.h"
#import "CDSCountCache.h"
#import "CDSUpdateCache.h"
#import "NSIndexPath+CDSDataSource.h"

/**
 The CDSTransform is a base class to data source that operate an index-path based transformation on one or several 
 data sources. For instance concatenating two data sources, merging every section into one, and such.
 This class is meant to be subclassed, and is the base of most of the provided data source implementations (the default implementation just passthrough the first data source)
 Subclasses should usually reimplement all 6 methods in "forward support", establishing a mapping between input and
 output index paths in both directions.
 For simple transforms, the backward direction (updates) will be automatically handled from the specified mapping.
 For more complex transforms, the updates set might need to be tweaked pre- and post- update using the last two methods.
 What simple and complex mean in this context is left for the reader to ponder.
 */
@interface CDSTransform : NSObject <CDSDataSource, CDSUpdateDelegate>

//factories
+ (instancetype) transformFromDataSources:(NSArray<id<CDSDataSource>>*)dataSources;
+ (instancetype) transformFromDataSource:(id<CDSDataSource>)dataSource;

@property (nonatomic, copy) NSArray<id<CDSDataSource>>* dataSources;
//convenience accessor for single data source
@property (nonatomic, strong) id<CDSDataSource> dataSource;


@property (nonatomic, copy, readonly) NSArray<CDSCountCache*>* dataSourceCaches; //implement index transformation methods using the sectionObjectsCount in these caches instead of directly accessing the data sources

//convenience accessor
- (CDSCountCache*) cacheForDataSource:(id<CDSDataSource>)dataSource;

/**************************************************************************/
#pragma mark methods to override for forward support and automatic updates

//reimplement based on cached data sources sections and object counts
- (NSInteger) cds_numberOfSections;
- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)section;
//the returned index path has 3 components where the first is the index of the source data source, returns nil if the index path has no match in sources data sources
- (NSIndexPath*) sourceIndexPathForIndexPath:(NSIndexPath*)indexPath;
//get our index path for a given source data source and index path. Returns nil if the source object is not present in our data
- (NSIndexPath*) indexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath inDataSource:(id<CDSDataSource>)sourceDataSource;
//if a source section maps 1:1 on one of our sections return its index, else NSNotFound
- (NSInteger) sectionIndexForSourceSectionIndex:(NSInteger)sourceSection inDataSource:(id<CDSDataSource>)sourceDataSource;
- (NSIndexPath*) sourceSectionIndexPathForSectionIndex:(NSInteger)section; //first index should be the data source, second the section in the data source

/**************************************************************************/
#pragma mark methods to override for advanced backward (update) support

//override if the index translation computation uses other data than the section index count
//the default implementation reloads the caches section item counts directly from the data source
//you should probably call super
- (void) reloadFromDataSource:(id<CDSDataSource>)dataSource;

//override to incrementatly update the caches from the update cache. The default implementation calls reload reloadFromDataSource
- (void) refreshFromDataSource:(id<CDSDataSource>)dataSource withSourceUpdateCache:(CDSUpdateCache*)updateCache;

//convert source update cache to our own update cache (pre-refresh) exceptionally reimplement, you should very probably call super
- (void) preRefreshTranslateSourceUpdateCache:(CDSUpdateCache*)sourceUpdateCache
                               fromDataSource:(id<CDSDataSource>)dataSource
                                toUpdateCache:(CDSUpdateCache*)updateCache;
//convert source update cache to our own update cache (post-refresh) exceptionally reimplement, you should very probably call super
- (void) postRefreshTranslateSourceUpdateCache:(CDSUpdateCache*)sourceUpdateCache
                                fromDataSource:(id<CDSDataSource>)dataSource
                                 toUpdateCache:(CDSUpdateCache*)updateCache;

@end

