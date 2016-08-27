//
//  ConcatenatedSectionsViewController.m
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

#import "ConcatenatedSectionsViewController.h"

#import <ChainableDataSource/ChainableDataSource.h>
#import "FruitCellDataSource.h"
#import "AppDelegate.h"

@interface ConcatenatedSectionsViewController ()

@property (nonatomic, strong) id<CDSCellDataSource> cellDataSource;

@end

@interface AnimalCellDataSource : CDSCellDataSource
@end

@implementation ConcatenatedSectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"animal-cell"];
    
    NSFetchedResultsController* fruitsByInitial = [(AppDelegate*)[[UIApplication sharedApplication] delegate] fruitsByInitialFetchedResultsController];
    
    FruitCellDataSource* fruitCDS = [FruitCellDataSource new];
    fruitCDS.dataSource = [CDSFetchWrapper dataSourceWithFetchedResultsController:fruitsByInitial];
    
    AnimalCellDataSource* animalCDS = [AnimalCellDataSource new];
    animalCDS.cellIdentifierOverride =@"animal-cell";
    animalCDS.dataSource = @[@"Eléphant", @"Chien", @"Souris", @"Ver de terre", @"Python", @"Impala"];
    
    //concatenate both cell data sources into one
    self.cellDataSource = [CDSConcatenatedSections transformFromDataSources:@[animalCDS, fruitCDS]];
    
    self.tableView.dataSource = self.cellDataSource;
    self.tableView.delegate = self.cellDataSource;
    self.cellDataSource.cds_updateDelegate = self.tableView;
    
}

@end

@implementation AnimalCellDataSource

- (void) configureCell:(UIView *)cell withObject:(id)object
{
    [(UITableViewCell*)cell textLabel].text = [NSString stringWithFormat:@"😸 %@", object];
    [(UITableViewCell*)cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Animals";
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
