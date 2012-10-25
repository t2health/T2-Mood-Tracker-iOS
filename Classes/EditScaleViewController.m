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

#import "EditScaleViewController.h"
#import "Scale.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "Error.h"

@implementation EditScaleViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize switchDictionary;
@synthesize groupsDictionary;
@synthesize tableView;

@synthesize leftTextField;
@synthesize rightTextField;
@synthesize scale;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;	
	
	self.title = [NSString stringWithFormat:@"Edit Scale"];
	self.leftTextField.text = self.scale.minLabel;
	self.rightTextField.text = self.scale.maxLabel;
	[FlurryUtility report:EVENT_ADD_EDIT_SCALE_ACTIVITY];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];	
    
}

- (void)save:(id)sender {
	self.scale.minLabel = self.leftTextField.text;
	self.scale.maxLabel = self.rightTextField.text;
	
	NSError *error = nil;
	
	if ([self.managedObjectContext hasChanges] ) {
		if(![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save scale edit." withError:error];
		}
	}
	
	[self.navigationController popViewControllerAnimated:YES];	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == leftTextField) {
		[leftTextField resignFirstResponder];
		[rightTextField becomeFirstResponder];
		self.scale.minLabel = leftTextField.text;
	}
	
	if (textField == rightTextField) {
		[rightTextField resignFirstResponder];
		self.scale.maxLabel = rightTextField.text;
	}
	
	NSError *error = nil;
    
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save Category edit." withError:error];
	}
	
	return YES;	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	BOOL shouldChangeText = YES;
	
	NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	NSCharacterSet *punctuation = [NSCharacterSet punctuationCharacterSet];
	
	NSString *trimmedReplacement = [string stringByTrimmingCharactersInSet:charactersToRemove ];
	
	trimmedReplacement = [trimmedReplacement stringByTrimmingCharactersInSet:punctuation];
	
	if (![trimmedReplacement isEqual:string]) {
		shouldChangeText = NO;
	}
	
	return shouldChangeText;
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		// Configure the cell...
		[self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    Scale *aScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (![aScale.minLabel isEqual:@""] && ![aScale.maxLabel isEqual:@""]) 
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", aScale.minLabel, aScale.maxLabel];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.alpha = 1.0f;
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *indexDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:indexDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	//NSString *showGraphPredicateString = [NSString stringWithFormat:@"group.title like '%@'",self.group.title];
	//NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
    //[NSFetchedResultsController deleteCacheWithName:nil]; 
	//[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"GetScales"];
	fetchedResultsController.safeDelegate = self;
    
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to load Category data" withError:error];
	}
	return 
    fetchedResultsController;
}    



#pragma mark Memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[self.managedObjectContext release];
	
	[self.leftTextField release];
	[self.rightTextField release];
	[self.scale release], self.scale = nil;
	
    [super dealloc];
}


@end
