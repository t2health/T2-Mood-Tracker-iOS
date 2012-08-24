//
//  NotesTableViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 6/20/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "NotesTableViewController.h"
#import "VAS002AppDelegate.h"
#import "Note.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Error.h"
#import "DateMath.h"
#import "AddNoteViewController.h"
#import "ViewNoteViewController.h"
#import "GraphViewController.h"


@implementation NotesTableViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize notesTableView, myNavController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    notesTableView.backgroundView = nil;
    
	self.title = @"View Notes";
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
	
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote:)];
	self.navigationItem.rightBarButtonItem = plusButton;
    [plusButton release];
    // Orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
	
	[FlurryUtility report:EVENT_NOTES_ACTIVITY];	
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch notes." withError:error];
	}	
}

- (void)viewWillAppear:(BOOL)animated {
	[notesTableView reloadData];
}

- (void)refresh
{
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
}

#pragma mark Button Clicks
-(void)addNote:(id)sender 
{
    NSString *nibName = @"AddNoteViewController";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        // ipad
        nibName = @"AddNoteViewController-iPad";
    }
    
    addNoteViewController = [[AddNoteViewController alloc] initWithNibName:nibName bundle:nil];
    addNoteViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addNoteViewController animated:YES];
    [addNoteViewController release];
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Category entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *noteDateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"noteDate" ascending:NO] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:noteDateDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"ViewNotes"];
	fetchedResultsController.safeDelegate = self;
	
	[fetchRequest setFetchBatchSize:60];
	
	return fetchedResultsController;
}

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[notesTableView reloadData];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSArray *sections = [self.fetchedResultsController sections];
    NSInteger numberOfSections = [sections count];
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
	NSInteger numberRows = (NSInteger)[sectionInfo numberOfObjects];
	return numberRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"cellcreation");
    UITableViewCell *cell = [notesTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;	
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the note
	Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:note.noteDate];
	cell.textLabel.text = dateString;
	cell.textLabel.textColor = [UIColor lightGrayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
	cell.detailTextLabel.text = note.note;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:18];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	id <NSFetchedResultsSectionInfo> theSection = [[fetchedResultsController sections] objectAtIndex:section];
	
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year and month components to a string representation.
     */
    static NSArray *monthSymbols = nil;
    
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]];
        monthSymbols = [[formatter monthSymbols] retain];
        [formatter release];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    
	NSInteger year = numericSection / 1000;
	NSInteger month = numericSection - (year * 1000);
	
	NSString *titleString = [NSString stringWithFormat:@"%@ %d", [monthSymbols objectAtIndex:month-1], year];
	
	return titleString;	
    
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> theSection = [[fetchedResultsController sections] objectAtIndex:section];
	
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year and month components to a string representation.
     */
    static NSArray *monthSymbols = nil;
    
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]];
        monthSymbols = [[formatter monthSymbols] retain];
        [formatter release];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    
	NSInteger year = numericSection / 1000;
	NSInteger month = numericSection - (year * 1000);
    
    // create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)] autorelease];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
    
    NSString *titleString = [NSString stringWithFormat:@"%@ %d", [monthSymbols objectAtIndex:month-1], year];
	headerLabel.text = titleString;
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
}

// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSArray *sections = [self.fetchedResultsController sections];
	
	NSMutableArray *tmp = [NSMutableArray array];
	for (id <NSFetchedResultsSectionInfo> section in sections) {
		NSString *sectionName = section.name;
		NSInteger month = [[sectionName substringFromIndex:4] intValue];
		NSString *monthName = [DateMath shortMonthNameFrom:month];
		[tmp addObject:monthName];
	}
	
	NSArray *sectionNames =[NSArray arrayWithArray:tmp];
	return [[sectionNames retain] autorelease];
}   

// tell table which section corresponds to section title/index (e.g. "B",1))
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//	
//	return index;
//}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSLog(@"deleted");
        
		NSError *error;
		if (![context save:&error]) {
			[Error showErrorByAppendingString:@"Unable to delete note" withError:error];
		}
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ViewNoteViewController *vnvc = [[ViewNoteViewController alloc] initWithNibName:@"ViewNoteViewController" bundle:nil];
	Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
	vnvc.note = note;
    vnvc.notesController = self;
    [self.myNavController pushViewController:vnvc animated:YES];
	[vnvc release];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload  {
	self.fetchedResultsController = nil;
}

- (void)dealloc {	
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	[managedObjectContext release];
	
    [super dealloc];
}


@end
