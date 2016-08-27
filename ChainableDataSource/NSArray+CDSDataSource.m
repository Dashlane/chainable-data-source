//
//  NSArray+CDSDataSource.m
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

#import "NSArray+CDSDataSource.h"
#import "NSIndexPath+CDSDataSource.h"

@implementation NSArray (CDSDataSource)

- (NSInteger) cds_numberOfSections
{
    return 1;
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    return [self count];
}

- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath
{
    return self[indexPath.cds_objectIndex];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    return nil;
}

- (void) setCds_updateDelegate:(id<CDSUpdateDelegate>)cds_updateDelegate
{
    
}

- (id<CDSUpdateDelegate>) cds_updateDelegate
{
    return nil;
}

@end



