//
//  CDSDeltaUpdater.m
//  ChainableDataSource
//
//  Created by Amadour Griffais on 02/12/2015.
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

#import "CDSDeltaUpdater.h"

#import "CDSDataSourceHelpers.h"
#import "CDSUpdateCache.h"
#import "NSIndexPath+CDSDataSource.h"

@interface LonguestSubsequenceComputationResult : NSObject

@property (nonatomic, strong) NSMutableIndexSet* indexesInFirstArray;
@property (nonatomic, strong) NSMutableIndexSet* indexesInSecondArray;
- (NSUInteger) length;

@end

@implementation LonguestSubsequenceComputationResult
- (NSUInteger) length
{
    return MAX([self.indexesInFirstArray count], [self.indexesInSecondArray count]);
}
@end

@interface CDSDeltaUpdater ()

@property (nonatomic, strong) NSArray* dataSourceObjectsCacheBySections;
@property (nonatomic, strong) NSArray* dataSourceNamesCacheBySections;

@end

@implementation CDSDeltaUpdater

@synthesize  cds_updateDelegate;


/**************************************************************************/
#pragma mark factory

+ (instancetype) deltaUpdateDataSourceWithDataSource:(id<CDSDataSource>)dataSource
{
    CDSDeltaUpdater* instance = [self new];
    instance.dataSource = dataSource;
    return instance;
}

/**************************************************************************/
#pragma mark properties

- (void) setDataSource:(id<CDSDataSource>)dataSource
{
    [self setDataSource:dataSource animated:NO];
}

- (void) setDataSource:(id<CDSDataSource>)dataSource animated:(BOOL)animated
{
    if (_dataSource == dataSource) {
        return;
    }
    
    _dataSource = dataSource;
    _dataSource.cds_updateDelegate = self;

    if (animated) {
        [self performDeltaUpdate];
    } else {
        [self performReload];
    }
}

/**************************************************************************/
#pragma mark delta computations

+ (LonguestSubsequenceComputationResult*) recursiveLongestCommonSubsequenceBetweenArray:(NSArray*)firstArray andArray:(NSArray*)secondArray
{
    //highly inefficent O(2^n) recursive method
    if ([firstArray count] == 0 || [secondArray count] == 0) {
        LonguestSubsequenceComputationResult* result = [LonguestSubsequenceComputationResult new];
        result.indexesInFirstArray = [NSMutableIndexSet indexSet];
        result.indexesInSecondArray = [NSMutableIndexSet indexSet];
        return result;
    }
    
    NSUInteger firstIndex = [firstArray count]-1;
    NSUInteger secondIndex = [secondArray count]-1;
    
    if ([firstArray.lastObject isEqual:secondArray.lastObject]) {
        LonguestSubsequenceComputationResult* result = [self recursiveLongestCommonSubsequenceBetweenArray:[firstArray subarrayWithRange:NSMakeRange(0, firstIndex)]
                                                                                                  andArray:[secondArray subarrayWithRange:NSMakeRange(0, secondIndex)]];
        [result.indexesInFirstArray addIndex:firstIndex];
        [result.indexesInSecondArray addIndex:secondIndex];
        return result;
    } else {
        LonguestSubsequenceComputationResult* result1 = [self recursiveLongestCommonSubsequenceBetweenArray:[firstArray subarrayWithRange:NSMakeRange(0, firstIndex)]
                                                                                                   andArray:[secondArray subarrayWithRange:NSMakeRange(0, secondIndex+1)]];
        LonguestSubsequenceComputationResult* result2 = [self recursiveLongestCommonSubsequenceBetweenArray:[firstArray subarrayWithRange:NSMakeRange(0, firstIndex+1)]
                                                                                                   andArray:[secondArray subarrayWithRange:NSMakeRange(0, secondIndex)]];
        return ([result2 length] > [result1 length])?result2:result1;
    }
}

+ (LonguestSubsequenceComputationResult*) longestCommonSubsequenceBetweenArray:(NSArray*)firstArray andArray:(NSArray*)secondArray
{
    return [self longestCommonSubsequenceBetweenArray:firstArray andArray:secondArray comparisonBlock:nil];
}

+ (LonguestSubsequenceComputationResult*) longestCommonSubsequenceBetweenArray:(NSArray*)firstArray andArray:(NSArray*)secondArray comparisonBlock:(BOOL(^)(id obj1, id obj2))comparisonBlock
{
    if (!comparisonBlock) {
        comparisonBlock = ^(id obj1, id obj2) {
            return [obj1 isEqual:obj2];
        };
    }
    //dynamic programming implementation instead
    //see https://www.ics.uci.edu/~eppstein/161/960229.html and https://en.m.wikipedia.org/wiki/Longest_common_subsequence_problem
    
    NSUInteger count1 = firstArray.count;
    NSUInteger count2 = secondArray.count;
    NSUInteger* lengths;
    size_t size = sizeof(NSUInteger)*(count1+1)*(count2+1);
    lengths = malloc(size);
    memset(lengths, 0, size);
    NSUInteger width = count2+1;
    for (NSUInteger i = 1; i<= count1; i++) {
        for (NSUInteger j = 1; j<= count2; j++) {
            if (comparisonBlock(firstArray[i-1],secondArray[j-1])) {
                lengths[i*width+j] = lengths[(i-1)*width+j-1] + 1;
            } else {
                NSUInteger l1 = lengths[i*width+j-1];
                NSUInteger l2 = lengths[(i-1)*width+j];
                lengths[i*width+j] = MAX(l1,l2);
            }
        }
    }

//    for (NSUInteger i = 0; i<= count1; i++) {
//        NSMutableString* log = [NSMutableString string];
//        for (NSUInteger j = 0; j<= count2; j++) {
//            [log appendFormat:@"\t%d", (int)(lengths[i*width+j])];
//        }
//        NSLog(@"%@", log);
//    }
    
    //backtracking
    LonguestSubsequenceComputationResult* result = [LonguestSubsequenceComputationResult new];
    result.indexesInFirstArray = [NSMutableIndexSet indexSet];
    result.indexesInSecondArray = [NSMutableIndexSet indexSet];
    [self backtrackLongestCommonSubsequenceForLengths:lengths width:width firstIndex:count1 secondIndex:count2 result:result];
    
    free(lengths);
    
    return result;
}

+ (void) backtrackLongestCommonSubsequenceForLengths:(NSUInteger*)length
                                               width:(NSUInteger)width
                                          firstIndex:(NSUInteger)i
                                         secondIndex:(NSUInteger)j
                                              result:(LonguestSubsequenceComputationResult*)result
{
    if (i == 0 || j == 0) {
        return; //done
    }
    if ( (length[i*width+j] > length[(i-1)*width+j]) && (length[i*width+j] > length[i*width+j-1])) {
        //common element, add both indexes to the result
        [result.indexesInFirstArray addIndex:i-1];
        [result.indexesInSecondArray addIndex:j-1];
        [self backtrackLongestCommonSubsequenceForLengths:length width:width firstIndex:i-1 secondIndex:j-1 result:result];
    } else if (length[(i-1)*width+j] > length[i*width+j-1]) {
        //backtrack toward lower i
        [self backtrackLongestCommonSubsequenceForLengths:length width:width firstIndex:i-1 secondIndex:j result:result];
    } else {
        //backtrack toward lower j
        [self backtrackLongestCommonSubsequenceForLengths:length width:width firstIndex:i secondIndex:j-1 result:result];
    }
}

- (void) performDeltaUpdate
{
    NSArray<NSArray*>* objectsBeforeChange = self.dataSourceObjectsCacheBySections?:@[];
    NSArray<NSArray*>* objectsAfterChange = [CDSDataSource objectsBySectionsWithDataSource:self.dataSource];
    
    NSArray* namesBeforeChange = self.dataSourceNamesCacheBySections?:@[];
    NSArray* namesAfterChange = [CDSDataSource sectionsNamesWithDataSource:self.dataSource];

    BOOL canPerformDeltaUpdate = !self.isDeltaUpdateDisabled;
    
    if (self.itemCountLimit > 0) {
        if (objectsBeforeChange.count*objectsAfterChange.count > self.itemCountLimit*self.itemCountLimit) {
            canPerformDeltaUpdate = NO;
        }
    }
    
    if (!canPerformDeltaUpdate) {
        [self performReload];
        return;
    }
    
    //match sections by title
    BOOL(^comparisonBlock)(id, id) = nil;
    if (!self.matchesUnnamedSections) {
        comparisonBlock = ^(id obj1, id obj2){
            if (obj1 == [NSNull null] && obj2 == [NSNull null]) {
                return NO;
            }
            return [obj1 isEqual:obj2];
        };
    }
    LonguestSubsequenceComputationResult* sectionDiff = [[self class] longestCommonSubsequenceBetweenArray:namesBeforeChange
                                                                                                  andArray:namesAfterChange
                                                                                           comparisonBlock:comparisonBlock];

    //perform the section delta computation
    NSMutableIndexSet* deletedSections = [NSMutableIndexSet indexSet];
    for  (NSInteger section = 0; section < [objectsBeforeChange count]; section++) {
        if (![sectionDiff.indexesInFirstArray containsIndex:section]) {
            [deletedSections addIndex:section];
        }
    }
    NSMutableIndexSet* insertedSections = [NSMutableIndexSet indexSet];
    for  (NSInteger section = 0; section < [namesAfterChange count]; section++) {
        if (![sectionDiff.indexesInSecondArray containsIndex:section]) {
            [insertedSections addIndex:section];
        }
    }
    
    NSMutableArray* sectionIndexesBefore = [NSMutableArray array];
    NSUInteger currentIndex = [sectionDiff.indexesInFirstArray firstIndex];
    while (currentIndex != NSNotFound) {
        [sectionIndexesBefore addObject:@(currentIndex)];
        currentIndex = [sectionDiff.indexesInFirstArray indexGreaterThanIndex:currentIndex];
    }
    NSMutableArray* sectionIndexesAfter = [NSMutableArray array];
    currentIndex = [sectionDiff.indexesInSecondArray firstIndex];
    while (currentIndex != NSNotFound) {
        [sectionIndexesAfter addObject:@(currentIndex)];
        currentIndex = [sectionDiff.indexesInSecondArray indexGreaterThanIndex:currentIndex];
    }
    
    //if there is a limit, check every sections update count and bail out if too many items
    if (self.itemCountLimit > 0) {
        for (NSInteger sectionIndex = 0; sectionIndex < [sectionDiff length]; sectionIndex++) {
            NSInteger sectionIndexBefore = [sectionIndexesBefore[sectionIndex] integerValue];
            NSInteger sectionIndexAfter = [sectionIndexesAfter[sectionIndex] integerValue];
            //if the item count is reached, just refresh the whole sections
            if (objectsBeforeChange[sectionIndexBefore].count*objectsAfterChange[sectionIndexAfter].count > self.itemCountLimit*self.itemCountLimit) {
                [self performReload];
                return;
            }
        }
    }
    
    //Compute the delta update by sections
    CDSUpdateCache* updateCache = [CDSUpdateCache new];
    [updateCache.deleteSectionsIndexes addIndexes:deletedSections];
    [updateCache.insertSectionsIndexes addIndexes:insertedSections];
    
    //perform delta update for individual items in sections that remaain
    for (NSInteger sectionIndex = 0; sectionIndex < [sectionDiff length]; sectionIndex++) {
        NSInteger sectionIndexBefore = [sectionIndexesBefore[sectionIndex] integerValue];
        NSInteger sectionIndexAfter = [sectionIndexesAfter[sectionIndex] integerValue];
        
        LonguestSubsequenceComputationResult* result = [[self class] longestCommonSubsequenceBetweenArray:objectsBeforeChange[sectionIndexBefore]
                                                                                                 andArray:objectsAfterChange[sectionIndexAfter]
                                                                                          comparisonBlock:self.comparisonBlock];
        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
        for (NSInteger indexBefore = 0; indexBefore < [objectsBeforeChange[sectionIndexBefore] count]; indexBefore++) {
            if (![result.indexesInFirstArray containsIndex:indexBefore]) {
                [deletedIndexPaths addObject:[NSIndexPath cds_indexPathForObject:indexBefore inSection:sectionIndexBefore]];
            }
        }
        if (deletedIndexPaths.count > 0) {
            [updateCache.deleteIndexPaths addObjectsFromArray:deletedIndexPaths];
        }
        
        NSMutableArray* insertedIndexPaths = [NSMutableArray array];
        NSMutableArray* updatedIndexPaths = [NSMutableArray array];
        for (NSInteger indexAfter = 0; indexAfter < [objectsAfterChange[sectionIndexAfter] count]; indexAfter++) {
            if (![result.indexesInSecondArray containsIndex:indexAfter]) {
                [insertedIndexPaths addObject:[NSIndexPath cds_indexPathForObject:indexAfter inSection:sectionIndexAfter]];
            } else {
                //send update message for preexisting objects
                if (self.sendUpdateMessagesOnReload) {
                    [updatedIndexPaths addObject:[NSIndexPath cds_indexPathForObject:indexAfter inSection:sectionIndexAfter]];
                }
            }
        }
        
        [updateCache.insertIndexPaths addObjectsFromArray:insertedIndexPaths];
        [updateCache.updateIndexPaths addObjectsFromArray:updatedIndexPaths];
    }
    
    //We are done computing the delta update, apply it.
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
    [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:updateCache.deleteSectionsIndexes];
    [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:updateCache.insertSectionsIndexes];
    [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:updateCache.deleteIndexPaths];
    [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:updateCache.insertIndexPaths];
    [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:updateCache.updateIndexPaths];
    
    //update our cache before notifying our delegate that our content changed
    self.dataSourceObjectsCacheBySections = objectsAfterChange;
    self.dataSourceNamesCacheBySections = namesAfterChange;

    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

- (void) performReload
{
    self.dataSourceObjectsCacheBySections = [CDSDataSource objectsBySectionsWithDataSource:self.dataSource];
    self.dataSourceNamesCacheBySections = [CDSDataSource sectionsNamesWithDataSource:self.dataSource];
    [self.cds_updateDelegate cds_dataSourceDidReload:self];
}

/**************************************************************************/
#pragma mark CDSUpdateDelegate

- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource
{
    [self performDeltaUpdate];
}

- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource
{
    [self.cds_updateDelegate cds_dataSourceWillUpdate:self];
}

- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource
{
    //update the current objects cache
    self.dataSourceObjectsCacheBySections = [CDSDataSource objectsBySectionsWithDataSource:self.dataSource];
    self.dataSourceNamesCacheBySections = [CDSDataSource sectionsNamesWithDataSource:self.dataSource];
    [self.cds_updateDelegate cds_dataSourceDidUpdate:self];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    [self.cds_updateDelegate cds_dataSource:self didDeleteSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes
{
    [self.cds_updateDelegate cds_dataSource:self didInsertSectionsAtIndexes:sectionIndexes];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cds_updateDelegate cds_dataSource:self didDeleteObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cds_updateDelegate cds_dataSource:self didInsertObjectsAtIndexPaths:indexPaths];
}

- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cds_updateDelegate cds_dataSource:self didUpdateObjectsAtIndexPaths:indexPaths];
}

/**************************************************************************/
#pragma mark CDSDataSource

- (NSInteger) cds_numberOfSections
{
    return [self.dataSourceObjectsCacheBySections count];
}

- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex
{
    return [self.dataSourceObjectsCacheBySections[sectionIndex] count];
}

- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath
{
    return self.dataSourceObjectsCacheBySections[indexPath.cds_sectionIndex][indexPath.cds_objectIndex];
}

- (NSString*) cds_nameOfSection:(NSInteger)sectionIndex
{
    NSString* name = self.dataSourceNamesCacheBySections[sectionIndex];
    return [name isKindOfClass:[NSString class]]?name:nil;
}

@end
