//
//  Fruitypedia.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 04/09/2016.
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

#import "FruitypediaViewController.h"
#import <CoreData/CoreData.h>
#import <ChainableDataSource/ChainableDataSource.h>
#import "FruitCellDataSource.h"
#import "AppDelegate.h"

@interface FruitypediaViewController()  <UISearchBarDelegate>

@property (nonatomic, strong) id<CDSCellDataSource> cellDataSource;
@property (nonatomic, strong) CDSCellDataSource* bannerDataSource;
@property (nonatomic, strong) CDSDeltaUpdater* filterDeltaUpdate;
@property (nonatomic, weak) CDSPredicateFilter* filterDataSource;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic, weak) IBOutlet UISwitch* animationsSwitch;

@end

@interface AddChainableCellDataSource : CDSCellDataSource
@end

/**************************************************************************/
#pragma mark View controller

@implementation FruitypediaViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //Prepare a fetch results controller
    CDSFetchWrapper* fetchDS = [CDSFetchWrapper new];
    fetchDS.fetchedResultsController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] fruitsByInitialFetchedResultsController];
    
    //Chain with a filter
    CDSPredicateFilter* fds = [CDSPredicateFilter transformFromDataSource:fetchDS];
    fds.filterPredicate = [NSPredicate predicateWithFormat:@"$filterText == nil OR $filterText.length == 0 OR self.name CONTAINS[cd] $filterText"];
    self.filterDataSource = fds;
    
    //Filter out empty sections
    CDSEmptySectionFilter* eds = [CDSEmptySectionFilter transformFromDataSource:fds];
    
    //Make sure filtering is animated
    CDSDeltaUpdater* dds = [CDSDeltaUpdater deltaUpdateDataSourceWithDataSource:eds];
    self.filterDeltaUpdate = dds;
    self.filterDeltaUpdate.deltaUpdateDisabled = !self.animationsSwitch.isOn;

    //Map fruits to cells
    CDSCellDataSource* fetchCds = [FruitCellDataSource new];
    fetchCds.dataSource = dds;

    //Banner cell data source
    CDSCellDataSource* bannerCds = [CDSCellDataSource new];
    bannerCds.cellIdentifierOverride = @"banner-cell";
    bannerCds.dataSource = @[@"banner"];
    
    //Insert Banner cell into filtered results
    CDSInsert* insertDS = [CDSInsert transformFromDataSources:@[fetchCds, bannerCds]];
    insertDS.insertionIndexPath = [NSIndexPath cds_indexPathForObject:2 inSection:0];
    insertDS.insertAtEndIfNeeded = NO;
    
    //Add cell
    CDSCellDataSource* addCds = [AddChainableCellDataSource new];
    addCds.dataSource = @[@"add"];
    addCds.cellIdentifierOverride = @"add-cell";
    
    //Show add cell if there are no results
    CDSPlaceholder* placeholderDS = [CDSPlaceholder transformFromDataSources:@[insertDS, addCds]];
    
    self.cellDataSource = placeholderDS;
    
    //Plug the table view
    self.cellDataSource.cds_updateDelegate = self.tableView;
    self.tableView.dataSource = self.cellDataSource;
    self.tableView.delegate = self.cellDataSource;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

/**************************************************************************/
#pragma mark Actions

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterDataSource.filterText = searchText;
}

- (IBAction)addFruit:(id)sender
{
    if ([self.searchBar.text length] == 0) {
        return;
    }
    NSManagedObjectContext* moc = [(AppDelegate*)[[UIApplication sharedApplication] delegate] moc];
    NSManagedObject* fruit = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Fruit" inManagedObjectContext:moc] insertIntoManagedObjectContext:moc];
    [fruit setValue:[self.searchBar.text capitalizedString] forKey:@"name"];
    [moc save:NULL];
}

- (IBAction)toggleAnimations:(id)sender
{
    self.filterDeltaUpdate.deltaUpdateDisabled = !self.animationsSwitch.isOn;
}

@end

@implementation AddChainableCellDataSource

- (void) configureCell:(UIView *)cell withObject:(id)object
{
    return;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] sendAction:@selector(addFruit:) to:nil from:self forEvent:nil];
}

@end
