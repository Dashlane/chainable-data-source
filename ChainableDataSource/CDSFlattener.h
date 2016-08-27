//
//  CDSFlattener.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 16/12/2015.
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
#import "CDSTransform.h"

/**
 Takes a potentially multi-section data source and flattens it into one section, which name can be specified.
 */
@interface CDSFlattener : CDSTransform

@property (nonatomic, copy) NSString* sectionName; //this name is queried to name our only exposed section

@end

