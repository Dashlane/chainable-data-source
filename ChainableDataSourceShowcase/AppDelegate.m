//
//  AppDelegate.m
//  ChainableDataSourceShowcase
//
//  Created by Amadour Griffais on 27/08/2016.
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

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSPersistentStoreCoordinator* coordinator;

@end

@interface NSString (FetchViewController)
- (NSString*) initialForSection;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**************************************************************************/
#pragma mark Core Data Setup

- (void) setupDB
{
    NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Fruits" withExtension:@"momd"]];
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSURL* dbURL = [NSURL fileURLWithPath:[@"~/Documents/db.sql" stringByExpandingTildeInPath]];
    BOOL newDB = ![[NSFileManager defaultManager] fileExistsAtPath:[dbURL path]];
    [self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbURL options:nil error:NULL];
    self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.moc.persistentStoreCoordinator = self.coordinator;
    
    //save fruits
    if (newDB) {
        NSArray* fruits = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fruits" withExtension:@"plist"]];
        for (NSString* fruitName in fruits) {
            NSManagedObject* fruit = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Fruit" inManagedObjectContext:self.moc] insertIntoManagedObjectContext:self.moc];
            [fruit setValue:fruitName forKey:@"name"];
            [self.moc save:NULL];
        }
    }
}

- (NSFetchedResultsController*) fruitsByInitialFetchedResultsController
{
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"Fruit"];
    fr.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSFetchedResultsController* frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:self.moc sectionNameKeyPath:@"name.initialForSection" cacheName:nil];
    return frc;
}

- (NSManagedObjectContext*) moc {
    if (!_moc) {
        [self setupDB];
    }
    return _moc;
}

@end

@implementation NSString (FetchViewController)

- (NSString*) initialForSection
{
    return self.length > 0 ? [self substringToIndex:1] : @"?";
}

@end

