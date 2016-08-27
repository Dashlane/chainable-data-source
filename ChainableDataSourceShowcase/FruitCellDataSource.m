//
//  FruitCellDataSource.m
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

#import "FruitCellDataSource.h"

#import <SafariServices/SafariServices.h>

@implementation FruitCellDataSource

-(void)configureCell:(UIView *)cell withObject:(id)object
{
    ((UITableViewCell*)cell).textLabel.text = [self labelForFruitObject:object];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the corresponding fruit object (the argument index path is already in our own index space)
    id fruit = [self.dataSource cds_objectAtIndexPath:indexPath];
    
    //get the index path in table coordinates
    NSIndexPath* tableIndexPath = [tableView cds_convertIndexPath:indexPath fromCellDataSource:self];
    
    //show the fruit
    [self showFruit:fruit sender:[tableView cellForRowAtIndexPath:tableIndexPath]];
    
    //deselect the cell
    [tableView deselectRowAtIndexPath:tableIndexPath animated:YES];
}

- (NSString*) cellIdentifierForObject:(id)object
{
    return @"fruit-cell";
}

- (void) showFruit:(id)fruit sender:(id)sender
{
    NSString* escapedFruitName = [[self labelForFruitObject:fruit] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSURL* fruitURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://fr.wikipedia.org/wiki/%@", escapedFruitName]];
    SFSafariViewController* safariVC = [[SFSafariViewController alloc] initWithURL:fruitURL];
    [[self viewControllerForSender:sender] showViewController:safariVC sender:sender];
}

- (UIViewController*) viewControllerForSender:(id)sender
{
    while ([sender respondsToSelector:@selector(nextResponder)] && ![sender isKindOfClass:[UIViewController class]]) {
        sender = [sender nextResponder];
    }
    return sender;
}

- (NSString*) labelForFruitObject:(id)fruitObject
{
    NSString* label = nil;
    if ([fruitObject isKindOfClass:[NSManagedObject class]]) {
        label = [fruitObject valueForKey:@"name"];
    } else if ([fruitObject isKindOfClass:[NSString class]]) {
        label = fruitObject;
    }
    return label;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject* object = [self.dataSource cds_objectAtIndexPath:indexPath];
        NSManagedObjectContext* moc = object.managedObjectContext;
        [moc deleteObject:object];
        [moc save:NULL];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataSource cds_objectAtIndexPath:indexPath];
    return [object isKindOfClass:[NSManagedObject class]] ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataSource cds_objectAtIndexPath:indexPath];
    return [object isKindOfClass:[NSManagedObject class]];
}

@end

