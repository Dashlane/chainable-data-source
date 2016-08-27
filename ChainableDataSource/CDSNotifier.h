//
//  CDSNotifier.h
//  ChainableDataSource
//
//  Insert this data source in a datasource chains to get notifications from updates/reloads
//
//  Created by Amadour Griffais on 07/03/2016.
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

/**
 Insert this data source in a chain to receive notifications when its upstream data source is reloaded or updated. This can be useful to keep 
 track of what changes happen when a data source is deep into a chain behinf filters and such.
 */
@interface CDSNotifier : NSObject <CDSDataSource, CDSUpdateDelegate>

+ (instancetype) notifierFromDataSource:(id<CDSDataSource>)dataSource;

@property (nonatomic, strong) id<CDSDataSource> dataSource;
@property (nonatomic, weak) id<CDSUpdateDelegate> cds_updateDelegate;

@end

extern NSString* CDSNotifierDidUpdateNotification;
extern NSString* CDSNotifierDidReloadNotification;
