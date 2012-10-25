/*
 *
 * T2 Mood Tracker
 *
 * Copyright © 2009-2012 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright © 2009-2012 Contributors. All Rights Reserved.
 *
 * THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
 * REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
 * COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
 * AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
 * THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
 * INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
 * REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
 * DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
 * HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
 * RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: T2MoodTracker002
 * Government Agency Original Software Title: T2 Mood Tracker
 * User Registration Requested. Please send email
 * with your contact information to: robert.kayl2@us.army.mil
 * Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
 *
 */

#import "GroupsViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Group.h"
#import "Scale.h"
#import "VAS002AppDelegate.h"
#import "EditGroupViewController.h"
#import "Error.h"

@implementation GroupsViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize switchDictionary;
@synthesize groupsDictionary;
@synthesize tableView;

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.backgroundView = nil;

	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
    
	self.title = @"Rating Categories";
	
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup:)];
	self.navigationItem.rightBarButtonItem = plusButton;
	
	[FlurryUtility report:EVENT_EDIT_GROUP_ACTIVITY];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self fillGroupsDictionary];
	[self createSwitches];
	//[self.tableView reloadData];
}

- (void)viewDidUnload {
	self.fetchedResultsController = nil;
}

#pragma mark Create dictionaries

- (void)fillGroupsDictionary {
	NSArray *groupsArray = [[self fetchedResultsController] fetchedObjects];
	
	self.groupsDictionary = nil;
	self.groupsDictionary = [NSMutableDictionary dictionary];
	
	for (Group *aGroup in groupsArray) {
		[self.groupsDictionary setObject:aGroup forKey:aGroup.title];
	}
    
    
    
    
}

- (void)createSwitches {
	NSArray *groupNames = [self.groupsDictionary allKeys];
	Group *aGroup;
	
	self.switchDictionary = nil;
	self.switchDictionary = [NSMutableDictionary dictionary];
	
	for (NSString *groupTitle in groupNames) {
		aGroup = [self.groupsDictionary objectForKey:groupTitle];
		[self addSwitchForGroup:aGroup];
	}
}

- (void)addSwitchForGroup:(Group *)group {
	UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	aSwitch.on = [group.visible boolValue];
	[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged]; 
	[self.switchDictionary setObject:aSwitch forKey:group.title];
	[aSwitch release];
}

#pragma mark orientation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRows = [sectionInfo numberOfObjects];
    
	return numberOfRows;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	NSArray *sections = [[self fetchedResultsController] sections];
	NSString *sectionName = [[sections objectAtIndex:section] name];
	return sectionName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //static NSString *CellIdentifier = @"Cell";
    
    // Perm fix for tableview WEIRD Bug from v2.0; 5/15/2012 Mel Manzano
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d, %d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		// Configure the cell...
		[self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
    
	Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
	if ([self.groupsDictionary objectForKey:group.title]==nil) {
		[self.groupsDictionary setObject:group forKey:group.title];
		[self addSwitchForGroup:group];
	}
    
	cell.textLabel.text = group.title;
	if (group.visible == NO) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
	}
	
	CGRect switchRect = CGRectMake(cell.frame.size.width - 110, 8, 100, 27);
	UISwitch *aSwitch = [self.switchDictionary objectForKey:group.title];
	[aSwitch setFrame:switchRect];
	cell.accessoryView = aSwitch;
    
}

#pragma mark group methods


- (void)addGroup:(id)sender {		
	[FlurryUtility report:EVENT_ADD_GROUP_SELECTED];
	
	[self editGroup:nil];
}

- (void)editGroup:(Group *)group {
	NSNumber *isImmutable = group.immutable;
	if ([isImmutable boolValue] == NO) {
        
		EditGroupViewController *editGroupViewController = [[EditGroupViewController alloc] initWithNibName:@"EditGroupViewController" bundle:nil];
		editGroupViewController.group = group;
		[self.navigationController pushViewController:editGroupViewController animated:YES];
		[editGroupViewController release];
        
	}
	else {
		NSString *titleString = [NSString stringWithFormat:@"Can not delete %@",group.title];
		
		UIAlertView *immutableAlert = [[UIAlertView alloc]initWithTitle:titleString message:@"Hide it by turning the switch to OFF" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[immutableAlert show];
		[immutableAlert release];
	}
}

-(void)switchFlipped:(id)sender {
	NSEnumerator *enumerator = [self.switchDictionary keyEnumerator];
	id key;
	
	UISwitch *currentValue;
	NSString *switchTitle = @"";
	while ((key = [enumerator nextObject])) {
		currentValue = [self.switchDictionary objectForKey:key];
		if (currentValue == sender) {
			switchTitle = key;
			Group *aGroup = [self.groupsDictionary objectForKey:switchTitle];
            
			UISwitch *theSwitch = (UISwitch *)currentValue;
			BOOL isOn = theSwitch.on;
            
			if ([self numberSwitchesOn] > 0) {
				NSNumber *isOnNumber = [NSNumber numberWithBool:isOn];
				aGroup.visible = isOnNumber;
				NSString *flurryKey = EVENT_GROUP_ACTIVATED;
				if (aGroup.visible ==  NO) {
					flurryKey = EVENT_GROUP_DEACTIVATED;
				}
				NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:aGroup.title,flurryKey, nil];
				[FlurryUtility report:flurryKey withData:usrDict];
				
				NSError *error = nil;
				if (![self.managedObjectContext save:&error]) {
					[Error showErrorByAppendingString:@"Unable to save Category edits." withError:error];
				}
				break;
			}
			else {
				theSwitch.on = YES;
				NSString *titleString = [NSString stringWithFormat:@"Minimum Categories"];
				UIAlertView *immutableAlert = [[UIAlertView alloc]initWithTitle:titleString message:@"You must have at least one Category on." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[immutableAlert show];
				[immutableAlert release];
			}			
		}
	}	
}

- (NSInteger) numberSwitchesOn {
	NSInteger numberOn = 0;
	
	for (NSString *switchTitle in self.switchDictionary) {
		UISwitch *currentSwitch = [self.switchDictionary objectForKey:switchTitle];
		if (currentSwitch.on == YES) {
			numberOn++;
		}
	}
	
	return numberOn;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[self editGroup:group];
	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    //	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSSortDescriptor *menuIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuIndex" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, menuIndexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
    [NSFetchedResultsController deleteCacheWithName:nil]; 
	[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:
									 self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Groups"];
	self.fetchedResultsController.safeDelegate = self;
	
	[sectionTitleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch data for groups." withError:error];
	}
    
	return self.fetchedResultsController;
}    

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	
	[self.tableView beginUpdates];
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


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	if (!self.tableView.editing) {
		[self.tableView reloadData];
	}
	
	[self.tableView endUpdates];
}

#pragma mark Memory management

- (void)dealloc {
	// Not sure why I have to explicitly set the delegate to nil, but if I don'tthe delegate will 
	// persist even after the View Controller has been deallocated.
	[self.tableView release];
	self.fetchedResultsController.delegate = nil;
	[self.fetchedResultsController release];
	[self.managedObjectContext release];
	[self.switchDictionary release];
	[self.groupsDictionary release];
	
    [super dealloc];
}

@end