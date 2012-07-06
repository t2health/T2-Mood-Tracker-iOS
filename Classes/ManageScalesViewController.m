//
//  ManageScalesViewController.m
//  VAS002
//
//  Created by Hasan Edain on 2/16/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ManageScalesViewController.h"
#import "Group.h"
#import "Scale.h"
#import "Error.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "EditScaleViewController.h"

@implementation ManageScalesViewController

@synthesize fetchedResultsController;
@synthesize scalesTableView;
@synthesize group;

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = [NSString stringWithFormat:@"Edit %@ Scales",self.group.title];
	
	[FlurryUtility report:EVENT_MANAGE_SCALE_ACTIVITY];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
	self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.scalesTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
  	NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
	return numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRows = [sectionInfo numberOfObjects];
	return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the book's title
	
	Scale *aScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (![aScale.minLabel isEqual:@""]) {
		cell.textLabel.text = aScale.minLabel;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.alpha = 1.0f;
	}
	else {
		cell.textLabel.text = @"(Edit)";
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.textLabel.alpha = 0.5f;		
	}
	
	if (![aScale.maxLabel isEqual:@""]) {
		cell.detailTextLabel.text = aScale.maxLabel;
		cell.detailTextLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.alpha = 1.0f;
	}
	else {
		cell.detailTextLabel.text = @"(Edit)";
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		cell.detailTextLabel.alpha = 0.5f;		
	}
	
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray	*objects = [self.fetchedResultsController fetchedObjects];
	Scale *scale = [objects objectAtIndex:[indexPath row]];

	EditScaleViewController *editScaleViewController = [[EditScaleViewController alloc] initWithNibName:@"EditScaleViewController" bundle:nil];
	editScaleViewController.scale = scale;
	[self.navigationController pushViewController:editScaleViewController animated:YES];
	[editScaleViewController release];
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	// Create and configure a fetch request with the Category entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *indexDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:indexDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"group.title like '%@'",self.group.title];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
	[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"EditGroups"];
	fetchedResultsController.safeDelegate = self;

	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to load Category data" withError:error];
	}
	
	return 
    fetchedResultsController;
}    

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	
	[self.scalesTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}	
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if (!((sectionIndex == 0) && ([self.scalesTableView numberOfSections] == 1)))
                [self.scalesTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            if (!((sectionIndex == 0) && ([self.scalesTableView numberOfSections] == 1) ))
                [self.scalesTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate: 
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	
	[self.scalesTableView endUpdates];
}

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[self.scalesTableView reloadData];
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[self.scalesTableView release];
	[self.group release];
	self.fetchedResultsController.delegate = nil;
	[self.fetchedResultsController release];
	
    [super dealloc];
}

@end