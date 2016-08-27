//
//  CDSFetchWrapper.m
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

#import "CDSFetchWrapper.h"

/**************************************************************************/
#pragma mark CDSFetchWrapper

@interface CDSFetchWrapper () <NSFetchedResultsControllerDelegate>

@end

@implementation CDSFetchWrapper

@synthesize cds_updateDelegate;

+ (instancetype) dataSourceWithFetchedResultsController:(NSFetchedResultsController*)frc
{
    CDSFetchWrapper* dataSource = [self new];
    dataSource.fetchedResultsController = frc;
    return dataSource;
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    _fetchedResultsController.delegate = nil;
    
    _fetchedResultsController = fetchedResultsController;
    
    _fetchedResultsController.delegate = self;
    NSError* error = nil;
    [_fetchedResultsController performFetch:&error];
    
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

- (NSInteger) cds_numberOfSections
{
    return [self.fetchedResultsController.sections count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    return [self.fetchedResultsController.sections[sectionIndex] numberOfObjects];
}

- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    return [self.fetchedResultsController.sections[sectionIndex] name];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if (newIndexPath && indexPath) { //post iOS10 style updates
                [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:@[indexPath]];
                [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:@[newIndexPath]];
            } else if (indexPath) { //pre iOS 10 updates
                [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:@[indexPath]];
            } else if (newIndexPath) { //nothing that I know of, but you never know...
                [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:@[newIndexPath]];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:@[indexPath]];
            [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

@end
