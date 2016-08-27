//
//  StaticTableViewController.m
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

#import "StaticTableViewController.h"

#import <ChainableDataSource/ChainableDataSource.h>

@interface StaticTableViewController ()

//model
@property (nonatomic, assign) BOOL advancedSettingsEnabled;
@property (nonatomic, assign) BOOL advancedSetting1Enabled;
@property (nonatomic, assign) BOOL advancedSetting2Enabled;
@property (nonatomic, assign) BOOL superSimpleModeEnabled;

//view
@property (nonatomic, weak) IBOutlet UITableViewCell* basicSetting1Cell;
@property (nonatomic, weak) IBOutlet UITableViewCell* basicSetting2Cell;
@property (nonatomic, weak) IBOutlet UITableViewCell* advancedSettingsEnableCell;
@property (nonatomic, weak) IBOutlet UITableViewCell* advancedAdvancedSetting1Cell;
@property (nonatomic, weak) IBOutlet UITableViewCell* advancedAdvancedSetting2Cell;
@property (nonatomic, weak) IBOutlet UITableViewCell* superSimpleModeCell;
@property (nonatomic, weak) IBOutlet UITableViewCell* easyCell;

//controller
@property (nonatomic, strong) CDSManualFilter* settingsFilter;

@end

@implementation StaticTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //insert a filter between self as a data source and the table view
    self.settingsFilter = [CDSManualFilter transformFromDataSource:self];
    
    self.tableView.dataSource = self.settingsFilter;
    self.tableView.delegate = self.settingsFilter;
    self.settingsFilter.cds_updateDelegate = self.tableView;
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshSettingsAnimated:NO];
}

- (void) refreshSettingsAnimated:(BOOL) animated
{
    [self.settingsFilter beginUpdates];
    //advanced/basic/super simple : toggle sections
    [self.settingsFilter setSectionHidden:self.superSimpleModeEnabled atSourceIndex:[self cds_indexPathForCell:self.basicSetting1Cell].section];
    [self.settingsFilter setSectionHidden:!self.advancedSettingsEnabled || self.superSimpleModeEnabled atSourceIndex:[self cds_indexPathForCell:self.advancedAdvancedSetting1Cell].section];
    [self.settingsFilter setSectionHidden:!self.advancedSettingsEnabled atSourceIndex:[self cds_indexPathForCell:self.superSimpleModeCell].section];

    //basic settings
    [self.settingsFilter setObjectHidden:self.advancedSettingsEnabled atSourceIndexPath:[self cds_indexPathForCell:self.basicSetting1Cell]];
    [self.settingsFilter setObjectHidden:self.advancedSettingsEnabled atSourceIndexPath:[self cds_indexPathForCell:self.basicSetting2Cell]];

    //advanced setting 1: toggle next row
    [self.settingsFilter setObjectHidden:!self.advancedSetting1Enabled atSourceIndexPath:[self cds_indexPathForCell:self.advancedAdvancedSetting1Cell]];
    
    //advanced setting 2: toggle next row
    [self.settingsFilter setObjectHidden:!self.advancedSetting2Enabled atSourceIndexPath:[self cds_indexPathForCell:self.advancedAdvancedSetting2Cell]];
    
    //super simple mode: show message
    [self.settingsFilter setObjectHidden:!self.superSimpleModeEnabled atSourceIndexPath:[self cds_indexPathForCell:self.easyCell]];
    
    [self.settingsFilter endUpdatesAnimated:animated];
}

//querying cells
- (NSIndexPath*) cds_indexPathForCell:(UITableViewCell*)cell
{
    for (NSInteger section=0; section < [self numberOfSectionsInTableView:self.tableView]; section++) {
        for (NSInteger row=0; row < [self tableView:self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if (cell == [self tableView:self.tableView cellForRowAtIndexPath:indexPath]) {
                return indexPath;
            }
        }
    }
    return nil;
}

//actions
- (IBAction)toggleAdvancedSettings:(id)sender
{
    self.advancedSettingsEnabled = !self.advancedSettingsEnabled;
    [self refreshSettingsAnimated:YES];
}

- (IBAction)toggleAdvancedSetting1:(id)sender
{
    self.advancedSetting1Enabled = !self.advancedSetting1Enabled;
    [self refreshSettingsAnimated:YES];
}

- (IBAction)toggleAdvancedSetting2:(id)sender
{
    self.advancedSetting2Enabled = !self.advancedSetting2Enabled;
    [self refreshSettingsAnimated:YES];
}

- (IBAction)toggleSuperSimpleMode:(id)sender
{
    self.superSimpleModeEnabled = !self.superSimpleModeEnabled;
    [self refreshSettingsAnimated:YES];
}

@end
