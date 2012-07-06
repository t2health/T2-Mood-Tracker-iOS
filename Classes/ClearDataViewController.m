//
//  ClearDataViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ClearDataViewController.h"
#import "VAS002AppDelegate.h"
#import <CoreData/CoreData.h>
#import "VASAnalytics.h"
#import "Error.h"
#import "Group.h"
#import "Result.h"
#import "Note.h"
#import "GroupResult.h"

@implementation ClearDataViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize currentGroup;
@synthesize deleteNotesChosen;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
		
	self.title = @"Clear Data";
	
	self.currentGroup = nil;
	self.deleteNotesChosen = NO;
	
	[FlurryUtility report:EVENT_CLEAR_DATA_ACTIVITY];
}

- (void)viewWillAppear:(BOOL)animated {
	self.fetchedResultsController = nil;
	[super viewWillAppear:animated];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch data for main menu." withError:error];
	}	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 1;
	
	if (section == 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		numberOfRows = [sectionInfo numberOfObjects];
	}
	
	return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionName;
	
	switch (section) {
		case 0: //Settings
			sectionName = @"Category";
			break;
		case 1:
			sectionName = @"Notes";
			break;
		default:
			sectionName = nil;
			break;
	}
	return sectionName;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	NSInteger numberResults;
	NSString *cellText;
	Group *group;
	NSSet *results;
	NSInteger section = [indexPath section];
	switch (section) {
		case 0: //Group
			group = [self.fetchedResultsController objectAtIndexPath:indexPath];
			results = [group result];
			numberResults = [results count];
			cellText = [NSString stringWithFormat:@"Clear %d %@ records", numberResults, group.title];
			break;
		case 1: //Notes
			numberResults = [self getNumberOfNotes];
			cellText = [NSString stringWithFormat:@"Clear %d notes",numberResults];
			break;
		default:
			cellText = @"";
			break;
	}
	
	cell.textLabel.text = cellText;
	
	return cell;
}

- (NSInteger)getNumberOfNotes {
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to save rating." withError:error];
	}
	
	NSInteger count = [fetchedObjects count];
	return count;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
//	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	self.currentGroup = nil;

	Group* selectedGroup;
	NSString *titleString;
	NSInteger numberResults;
	NSString *messageString;
	UIAlertView *immutableAlert;
	
	switch (section) {
		case 0:
			selectedGroup = (Group *)[self.fetchedResultsController objectAtIndexPath:indexPath];
			self.currentGroup = selectedGroup;
			titleString = @"Delete these records?";
			NSSet *results = [self.currentGroup result];
			numberResults = [results count];
			messageString = [NSString stringWithFormat:@"%@ with %d records",self.currentGroup.title, numberResults];
			immutableAlert = [[[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil] autorelease];
			[immutableAlert show];			
			break;
		case 1:
			titleString = @"Delete these notes?";
			numberResults = [self getNumberOfNotes];
			messageString = [NSString stringWithFormat:@"%d notes", numberResults];
			immutableAlert = [[[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil] autorelease];
			[immutableAlert show];
			self.deleteNotesChosen = YES;
			break;
		default:
			break;
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1)
	{
		if (self.currentGroup != nil) {
			[self deleteResultsForGroup:self.currentGroup];
			self.currentGroup = nil;
		}
		if (self.deleteNotesChosen == YES) {
			[self deleteNotes];
		}
	}
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Group entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *titleDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease];
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:titleDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];

	// Create Predicate
	NSPredicate *rateablePredicate = [NSPredicate predicateWithFormat:@"rateable == TRUE"];
	[fetchRequest setPredicate:rateablePredicate];
	
	// Set Fetch Size
	[fetchRequest setFetchBatchSize:20];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:@"ClearData"];
	self.fetchedResultsController.safeDelegate = self;
	
	return self.fetchedResultsController;
}    

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[groupTableView reloadData];
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	
	[groupTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[groupTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[groupTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[groupTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[groupTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[groupTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the groups's title
	Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = group.title;	
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	
	[groupTableView endUpdates];
}

#pragma mark Delete 
- (void)deleteResultsForGroup:(Group *)group {
	NSSet *results = [group result];
	for (Result *result in results) {
		[self.managedObjectContext deleteObject:result];
	}
	
	NSSet *groupResults = [group groupResult];
	for (GroupResult *groupResult in groupResults) {
		[self.managedObjectContext deleteObject:groupResult];
	}
	
	NSError *error = nil;	
	if (![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save deletion of objects to store." withError:error];
	}
	
	[FlurryUtility report:EVENT_CLEAR_GROUP];
	
		[groupTableView reloadData];
}

- (void)deleteNotes {
	self.deleteNotesChosen = NO;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to delete notes." withError:error];
	}
	
	for (Note *note in fetchedObjects) {
		[self.managedObjectContext deleteObject:note];
	}
	
	error = nil;	
	if (![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save deletion of notes to store." withError:error];
	}
	
	[FlurryUtility report:EVENT_CLEAR_NOTES];
	
	[groupTableView reloadData];
}

#pragma mark cleanup

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	self.currentGroup = nil;
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	self.fetchedResultsController = nil;
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[self.fetchedResultsController release];
	[self.managedObjectContext release], self.managedObjectContext = nil;
	[self.currentGroup release], self.currentGroup = nil;
	
	[super dealloc];
}

@end
