//
//  CDSTransform+CDSCellDataSource.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 21/12/2015.
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

#import "CDSTransform+CDSCellDataSource.h"

#import "selector_belongsToProtocol.h"

//make compound data source into cell data sources all sources are cell data sources
@implementation CDSTransform (CDSCellDataSource)

/**************************************************************************/
#pragma mark CDSCellDataSource

- (id<CDSCellOperator>) cds_cellOperator
{
    return [self.cds_updateDelegate conformsToProtocol:@protocol(CDSCellOperator)]?(id<CDSCellOperator>)self.cds_updateDelegate:nil;
}

/**************************************************************************/
#pragma mark CDSCellOperator

- (UIView*) cds_reusableCellWithIdentifier:(NSString*)cellIdentifier forIndexPath:(NSIndexPath*)indexPath
{
    //convert to provider space
    NSIndexPath* providerIndexPath = [self.cds_cellOperator cds_convertIndexPath:indexPath fromCellDataSource:self];
    return [self.cds_cellOperator cds_reusableCellWithIdentifier:cellIdentifier forIndexPath:providerIndexPath];
}

- (UIView*) cds_existingCellAtIndexPath:(NSIndexPath *)indexPath
{
    //convert to provider space
    NSIndexPath* providerIndexPath = [self.cds_cellOperator cds_convertIndexPath:indexPath fromCellDataSource:self];
    return [self.cds_cellOperator cds_existingCellAtIndexPath:providerIndexPath];
}

- (NSIndexPath*) cds_indexPathForCell:(UIView*)cell
{
    NSIndexPath* providerIndexPath = [self.cds_cellOperator cds_indexPathForCell:cell];
    if (!providerIndexPath) { return nil; }
    NSIndexPath* indexPath = [self.cds_cellOperator cds_convertIndexPath:providerIndexPath toCellDataSource:self];
    return indexPath;
}


- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath*)indexPath fromCellDataSource:(id<CDSCellDataSource>)cellDataSource
{
    if (cellDataSource == self) {
        return indexPath;
    } else if (cellDataSource.cds_cellOperator == self && [self.dataSources containsObject:cellDataSource]) {
        return [self indexPathForSourceIndexPath:indexPath inDataSource:cellDataSource];
    } else if (!indexPath || !cellDataSource) {
        return nil;
    } else if (![cellDataSource.cds_cellOperator conformsToProtocol:@protocol(CDSCellDataSource)]) {
        return nil;
    } else {
        id<CDSCellDataSource, CDSCellOperator> parentProvider = (id<CDSCellDataSource, CDSCellOperator>)cellDataSource.cds_cellOperator;
        NSIndexPath* parentIndexPath = [parentProvider cds_convertIndexPath:indexPath fromCellDataSource:cellDataSource];
        return [self cds_convertIndexPath:parentIndexPath fromCellDataSource:parentProvider];
    }
}

- (NSIndexPath*) cds_convertIndexPath:(NSIndexPath*)indexPath toCellDataSource:(id<CDSCellDataSource>)cellDataSource
{
    if (!indexPath || !cellDataSource) {
        return nil;
    }
    //if we are converting to self, we're done
    if (cellDataSource == self) {
        return indexPath;
    }
    //if we are not a provider for this data source return nil
    if (![self isAncestorProviderForCellDataSource:cellDataSource]) {
        return nil;
    }
    //compute the source indexPath
    NSIndexPath* fullSourceIndexPath = [self sourceIndexPathForIndexPath:indexPath];
    if (!fullSourceIndexPath) {
        return nil;
    }
    id<CDSDataSource> sourceDataSource = self.dataSources[[fullSourceIndexPath cds_dataSourceIndex]];
    NSIndexPath* dsIndexPath = [fullSourceIndexPath cds_indexPathInDataSource];
    
    //if the source is one of our data source retrun
    if (sourceDataSource == cellDataSource) {
        return dsIndexPath;
    } else if ([sourceDataSource conformsToProtocol:@protocol(CDSCellOperator)]) {
        return [(id<CDSCellOperator>)sourceDataSource cds_convertIndexPath:dsIndexPath toCellDataSource:cellDataSource];
    }
    
    return nil;
}

- (BOOL) isAncestorProviderForCellDataSource:(id<CDSCellDataSource>)cellDataSource
{
    if (cellDataSource == self) {
        return YES;
    } else if (![cellDataSource.cds_cellOperator conformsToProtocol:@protocol(CDSCellDataSource)]) {
        return NO;
    } else {
        return [self isAncestorProviderForCellDataSource:(id<CDSCellDataSource>)cellDataSource.cds_cellOperator];
    }
}

/**************************************************************************/
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self cds_numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self cds_numberOfObjectsInSection:section];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cds_objectAtIndexPath:indexPath];
}

/**************************************************************************/
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self cds_numberOfObjectsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cds_objectAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self cds_numberOfSections];
}

/**************************************************************************/
#pragma mark Delegate messages forwarding

- (BOOL) respondsToSelector:(SEL)aSelector
{
    if ([self isForwardableDelegateSelector:aSelector]) {
        __block BOOL responds = NO;
        [self.dataSources enumerateObjectsUsingBlock:^(id<CDSDataSource>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            responds = responds || [obj respondsToSelector:aSelector];
        }];
        return responds;
    }
    
    return [super respondsToSelector:aSelector];
}

- (BOOL) isForwardableDelegateSelector:(SEL)aSelector
{
    return selector_belongsToProtocol(aSelector, @protocol(UITableViewDelegate))
    || selector_belongsToProtocol(aSelector, @protocol(UITableViewDataSource))
    || selector_belongsToProtocol(aSelector, @protocol(UICollectionViewDelegate))
    || selector_belongsToProtocol(aSelector, @protocol(UICollectionViewDataSource))
    || [self.forwardedIndexPathAndSectionSelectors containsObject:NSStringFromSelector(aSelector)];
}

- (void) forwardInvocation:(NSInvocation *)anInvocation
{
    //We will forward an invocation if:
    //-it has a single argument of type NSIndexPath, or a NSInteger argument which previous selector component end with "Section"
    //-the target data source for this indexPath or section actually implements it
    if ([self isForwardableDelegateSelector:anInvocation.selector]) {
        NSMethodSignature* signature = anInvocation.methodSignature;
        NSArray* components = [NSStringFromSelector(anInvocation.selector)componentsSeparatedByString:@":"];
        for (NSInteger argIndex = 0; argIndex < signature.numberOfArguments; argIndex++) {
            //skip self and cmd
            if (argIndex < 2) {
                continue;
            }
            //won't work with targetIndexPathForMoveFromRowAtIndexPath, since two indexPath are present
            const char* argType = [signature getArgumentTypeAtIndex:argIndex];
            if (strcmp(argType, @encode(NSIndexPath*)) == 0) {
                __unsafe_unretained id arg;
                [anInvocation getArgument:&arg atIndex:argIndex];
                if ([arg isKindOfClass:[NSIndexPath class]]) {
                    NSIndexPath* indexPath = arg;
                    NSIndexPath* fullIndexPath = [self sourceIndexPathForIndexPath:indexPath];
                    id<CDSDataSource> dataSource = self.dataSources[[fullIndexPath indexAtPosition:0]];
                    NSIndexPath* dsIndexPath = [NSIndexPath cds_indexPathForObject:[fullIndexPath indexAtPosition:2] inSection:[fullIndexPath indexAtPosition:1]];
                    [anInvocation setArgument:&dsIndexPath atIndex:argIndex];
                    if ([dataSource respondsToSelector:anInvocation.selector]) {
                        [anInvocation invokeWithTarget:dataSource];
                    }
                    return;
                }
            } else if (strcmp(argType, @encode(NSInteger)) == 0 && [components[argIndex-2] hasSuffix:@"Section"]) {
                NSInteger section;
                [anInvocation getArgument:&section atIndex:argIndex];
                NSIndexPath* sourceSectionIndexPath = [self sourceSectionIndexPathForSectionIndex:section];
                if (sourceSectionIndexPath) {
                    id<CDSDataSource> dataSource = self.dataSources[[sourceSectionIndexPath indexAtPosition:0]];
                    NSInteger sourceSection = [sourceSectionIndexPath indexAtPosition:1];
                    [anInvocation setArgument:&sourceSection atIndex:argIndex];
                    if ([dataSource respondsToSelector:anInvocation.selector]) {
                        [anInvocation invokeWithTarget:dataSource];
                    }
                }
                return;
            }
        }
        return;
    }
    
    return [super forwardInvocation:anInvocation];
}

- (NSArray<NSString*>*) forwardedIndexPathAndSectionSelectors
{
    return objc_getAssociatedObject(self, @selector(forwardedIndexPathAndSectionSelectors));
}

- (void) setForwardedIndexPathAndSectionSelectors:(NSArray<NSString *> *)forwardedIndexPathAndSectionSelectors
{
    objc_setAssociatedObject(self, @selector(forwardedIndexPathAndSectionSelectors), forwardedIndexPathAndSectionSelectors, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
