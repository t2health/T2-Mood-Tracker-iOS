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

#import "EditGroupViewController.h"
#import "ManageScalesViewController.h"
#import "Group.h"
#import "Scale.h"
#import "Error.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "EditScaleViewController.h"
#import "UICustomSwitch.h"

@implementation EditGroupViewController

@synthesize group;
@synthesize managedObjectContext;
@synthesize scalesTableView;
@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    scalesTableView.backgroundView = nil;

	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
	
	if (self.group != nil) {
		self.title = group.title;
		groupTextField.text = self.group.title;
		
		manageScalesButton.enabled = YES;
		deleteGroup.enabled = YES;
	}
	else {
		self.title = @"New Category";
	}
	
	UICustomSwitch *switchView = [[UICustomSwitch alloc] initWithFrame:CGRectZero];
    
	switchView = [UICustomSwitch switchWithLeftText:@"YES" andRight:@"NO"];
	switchView.center = CGPointMake(160.0f, 60.0f);
	switchView.on = YES;
	[self.view addSubview:switchView];
    
	[FlurryUtility report:EVENT_GROUP_ACTIVITY];
}

- (void)saveEdit {
	self.group.title = groupTextField.text;
	
	NSError *error = nil;
	
	if ([self.managedObjectContext hasChanges] ) {
		if(![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save group edit." withError:error];
		}
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Buttons
- (IBAction)deleteGroupPressed:(id)sender {
	NSString *titleString = [NSString stringWithFormat:@"Delete Category? %@",self.group.title];
	
	UIAlertView *immutableAlert = [[[UIAlertView alloc]initWithTitle:titleString message:@"You are about to delete this Category, and all data associated with it." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil] autorelease];
	[immutableAlert show];
}

- (IBAction)manageScalesPressed:(id)sender {
    
	ManageScalesViewController *manageScalesViewController = [[ManageScalesViewController alloc] initWithNibName:@"ManageScalesViewController" bundle:nil];
	manageScalesViewController.group = self.group;
	[self.navigationController pushViewController:manageScalesViewController animated:YES];
	[manageScalesViewController release];
}

#pragma mark Alert 
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1)
	{
		NSManagedObject *local = [self.managedObjectContext objectWithID:[self.group objectID]];
		if ([local isDeleted]) {
			return;
		}
		if (![local isInserted]) {
			[self saveAction:self];
		}
		
		[self.managedObjectContext deleteObject:local];
		
		NSError *error = nil;
		if ([self.managedObjectContext hasChanges]){
			if (![self.managedObjectContext save:&error]) {
				[Error showErrorByAppendingString:@"Unable to save edits made to Category." withError:error];
			}	
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		[FlurryUtility report:EVENT_DELETE_GROUP_ACTIVITY];
	}
}

#pragma mark actionSheet


- (IBAction)saveAction:(id)sender {
	NSError *error = nil;
	
	if (![self.managedObjectContext hasChanges])return;
	if (![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save Category edit." withError:error];
	}
}

#pragma mark Rotation
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == groupTextField) {
		[groupTextField resignFirstResponder];
		self.title = groupTextField.text;
		
		manageScalesButton.enabled = YES;
		deleteGroup.enabled = YES;
		if (self.group == nil) {
			[self addGroup];
		}
		else {
			[self saveEdit];
		}
	}
	
	return YES;	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	BOOL shouldChangeText = YES;
	
    NSMutableCharacterSet *charactersToKeep = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToKeep addCharactersInString:@" "];
    
    NSCharacterSet *charactersToRemove = [charactersToKeep invertedSet];
    
    NSString *trimmedReplacement = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@"" ];
    
	
	if (![trimmedReplacement isEqual:string]) {
		shouldChangeText = NO;
	}
	
	return shouldChangeText;
}

-(BOOL) doesGroupnameExist:(NSString *)groupName {
	BOOL doesExist = NO;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, titleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
	[fetchRequest setPredicate:showGraphPredicate];
	
	
	NSError *error = nil;
	NSArray *groupArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Group * aGroup in groupArray) {
		if ([aGroup.title isEqual:groupName]) {
			doesExist = YES;
			break;
		}
	}
	
	[sectionTitleDescriptor autorelease];
	[titleDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
	
	return doesExist;
}

- (NSNumber *)getNextMenuIndex {
	NSNumber *menuIdx = [NSNumber numberWithInt:0];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *menuIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuIndex" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, menuIndexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
	[fetchRequest setPredicate:showGraphPredicate];
	
	
	NSError *error = nil;
	NSArray *groupArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Group * aGroup in groupArray) {
		if ([aGroup.menuIndex compare:menuIdx] == NSOrderedDescending) { //Groups menu index is larger than the current value
			menuIdx = aGroup.menuIndex;
		}
	}
	
	[sectionTitleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
	
	return [[menuIdx retain] autorelease];
}

#pragma mark CREATE group
- (void)addGroup {	
	NSString *groupName = groupTextField.text;
	
	if ([self doesGroupnameExist:groupName] == YES) {
		NSString *messageString = [NSString stringWithFormat:@"You already have a group titled: %@",groupName];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString
                                                                 delegate:self 
                                                        cancelButtonTitle:@"Ok" 
                                                   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
		[groupTextField becomeFirstResponder];
	}
	else if([groupName isEqual:@""]) {
		NSString *messageString = [NSString stringWithFormat:@"A Category must contain at least one character: %@",groupName];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString
																 delegate:self 
														cancelButtonTitle:@"Ok" 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
		[groupTextField becomeFirstResponder];
	}
	else {
		Group *newGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		newGroup.section = @"Rate";
		newGroup.title = groupTextField.text;
		newGroup.groupDescription = @"Lorem ipsum dolor sit amet";
		newGroup.visible = [NSNumber numberWithBool:YES];
		newGroup.rateable = [NSNumber numberWithBool:YES];
		newGroup.immutable = [NSNumber numberWithBool:NO];
		newGroup.showGraph = [NSNumber numberWithBool:YES];
		newGroup.menuIndex = [self getNextMenuIndex];
		newGroup.positiveDescription = [NSNumber numberWithBool:isPositveSwitch.on];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving new Category" withError:error];
		}
		
		Scale *newScale;
		for (NSInteger i = 0; i<10; i++) {
			newScale = [NSEntityDescription insertNewObjectForEntityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
			
			newScale.maxLabel = @"";
			newScale.minLabel = @"";			
			
			newScale.weight = [NSNumber numberWithInt:50];
			newScale.group = newGroup;
			newScale.index = [NSNumber numberWithInt:i];
			
			error = nil;
			if (![self.managedObjectContext save:&error]) {
				[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
			}
		}
		
		self.group = newGroup;
	}
}

- (IBAction)switchFlipped:(id)sender {
	if (self.group != nil) {
		self.group.positiveDescription = [NSNumber numberWithBool:isPositveSwitch.on];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
		}
	}
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
    
	//UIApplication *app = [UIApplication sharedApplication];
	//VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	//NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	// Create and configure a fetch request with the Category entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *indexDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:indexDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"group.title like '%@'",self.group.title];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
    [NSFetchedResultsController deleteCacheWithName:nil]; 
	[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"EditGroups"];
	fetchedResultsController.safeDelegate = self;
    
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to load Category data" withError:error];
	}
	
	return 
    fetchedResultsController;
}


#pragma mark Memory management

- (void)dealloc {
	if (self.group != nil) {
		[self.group release];		
	}
    
	[self.managedObjectContext release];
	
    [super dealloc];
}

@end