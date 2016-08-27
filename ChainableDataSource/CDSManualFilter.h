//
//  CDSManualFilter.h
//  ChainableDataSource
//
//  Created by Amadour Griffais on 06/01/2016.
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

/**
 Allows filtering sections and object out of our data source by manually specified the indexPaths and sections to be filtered out.
 */
@interface CDSManualFilter : CDSTransform

- (void) beginUpdates;
- (void) endUpdatesAnimated:(BOOL)animated;
- (void) setSectionHidden:(BOOL)hidden atSourceIndex:(NSInteger)sectionIndex; //animated by default
- (void) setObjectHidden:(BOOL)hidden atSourceIndexPath:(NSIndexPath*)indexPath; //animated by default
//batch update using an udpdate cache
- (void) updateHiddenObjectsWithUpdateCache:(CDSUpdateCache*)updateCache animated:(BOOL)animated;

//querying
- (BOOL) isSectionHiddenAtSourceIndex:(NSInteger)sectionIndex;
- (BOOL) isObjectHiddenAtSourceIndexPath:(NSIndexPath*)indexPath; //this does not taks in account the state of the whole section

@end
