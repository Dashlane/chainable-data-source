# Chainable Data Sources
`Chainable Data Sources` (CDS) provide a uniformized interface that plugs easily on common UIKit / Foundation components dedicated to displayed large data sets (`UITableView`/`UICollectionView`/`NSFetchedResultsController`), as well as a toolset to manipulate objects conforming to that interface. 

CDS have the following characteristics:

- Can be combined to reuse the same datasets in different parts of the app.
- Reactivity: CDS use the delegation pattern to automatically update the UI when the underlying user data changes, keeping the UI in perfect sync with the data model, with only declarative code required to setup the data sources.
- Can be used to break down sophisticated data manipulation into smaller blocks of lower complexity, allowing easy implementation of complex behaviours that would be otherwise impossible to implement reliably (eg: animated filtering while tracking data changes). 
- Are currently implemented in Obj-C, and would probably be very well-suited to a Swift implementation.
- Allow to make use of UIKit table/collection views animated data updates easily and reliably by providing a component that computes the updates automatically

## Data structure

CDS use a data structure similar to common UIKit classes `UITableViewDataSource` / `UICollectionViewDataSource` / `NSFetchedResultsController`, structuring the data to manipulates into sections where every section has an optional name and can contain a certain number of items. CDS can be used to provide objects of any type: the items just need to be NSObjects.

### Providing Data

CDS must conform to the following protocol :

	@protocol CDSDataSource <NSObject> 
	- (NSInteger) cds_numberOfSections;
	- (NSInteger) cds_numberOfObjectsInSection:(NSInteger)sectionIndex;
	- (id) cds_objectAtIndexPath:(NSIndexPath*)indexPath;
	- (NSString*) cds_nameForSectionAtIndex:(NSInteger)sectionIndex;
	@property (nonatomic, weak) id<GenericDataSourceDelegate> cds_updateDelegate;
	@end
	
Native Cocoa objets can be made to implement this protocol in a category, or by using a lightweight wrapper object. A category is provided for `NSArray`, as well as a wrapper for `NSFetchedResultsController`, effectively turning any `NSArray` and `NSFetchedResultsController` into a CDS. Since the CDS protocol is very simple and similar to protocols in UIKit, making any data-providing object conform to it is very straightforward.

### Notifying data updates

In addition to the data providing method, the CDS protocol also requires implementers to provide an `udpateDelegate` property, that they must notify whenever the data they provide changes. This delegate must implement the following `CDSUpdateDelegate` protocol

	@protocol CDSUpdateDelegate <NSObject> 
	- (void) cds_dataSourceDidReload:(id<CDSDataSource>)dataSource;
	- (void) cds_dataSourceWillUpdate:(id<CDSDataSource>)dataSource;
	- (void) cds_dataSourceDidUpdate:(id<CDSDataSource>)dataSource;
	- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteSectionsAtIndexes:(NSIndexSet*)sectionIndexes;
	- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertSectionsAtIndexes:(NSIndexSet*)sectionIndexes;
	- (void) cds_dataSource:(id<CDSDataSource>)dataSource didDeleteObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
	- (void) cds_dataSource:(id<CDSDataSource>)dataSource didInsertObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
	- (void) cds_dataSource:(id<CDSDataSource>)dataSource didUpdateObjectsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;
	@end

The `dataSourceDidReload` method signals a full reload of the underlying data: the data consumer should completely refresh and ask for all the data again. The update methods allow to signal updates by batch. Update batches must be bracketed by a `dataSourceWillUpdate`/`dataSourceDidUpdate`.

This protocol is very similar to the APIs to report updates on UITableView and UICollectionView. In fact we provide categories on both these classes that implement CDSUpdateDelegate, allowing to make them delegates for data sources providing their content, causing the UI to be updated automatically whenever the underlying data changes.

## Combining and Daisy-Chaining

We provide a toolset to manipulate objects that conforms to the CDS interface. Components exists that provide the following features:

- combining several data sources into one by appending all the sections
- filtering items based on a predicate
- removing empty sections
- flatten a datasource by merging all its sections into a single one
- disable a datasource temporarily 
- automatically animate updates by computing the differences in a dataset before and after a full reload

## Cell Data Sources
A specific category of data sources are `CellDataSources`, which map model objects provided by a `CDSDataSource` to cell views, and implement the UITableView and UICollectionView protocols. Cell data source can thus serve as data sources of table and collection view directly, and will additionally notify them of any updates that happen in the data model. 

The `CellDataSources` must have a reference to a cell operator (protocol `CDSCellOperator`), which abstracts the role UITableView and UICollectionView play in cell dequeing and displaying.  Usually this cell operator is the table or collection view.

