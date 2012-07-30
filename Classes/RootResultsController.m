//
//  RootRateController.m
//  VAS002
//
//  Created by Melvin Manzano on 4/3/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "RootResultsController.h"
#import "VAS002AppDelegate.h"
#import "AddNoteViewController.h"
#import "RateMoodViewController.h"
#import "AboutViewController.h"
#import "HelpViewController.h"
#import "SettingsViewController.h"
#import "ViewNotesViewController.h"
#import "ResultsViewController.h"
#import "TipViewController.h"
#import "Group.h"
#import "Result.h"
#import "Scale.h"
#import "MailData.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "PasswordViewController.h"
#import "SecurityViewController.h"
#import "DateMath.h"
#import "Error.h"
#import "GroupResult.h"
#import "SavedResultsController.h"
#import "GraphViewController.h"

@implementation RootResultsController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize reminderArray;
@synthesize tableView;


#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add tabbar back just in case;)
    [self.navigationController popViewControllerAnimated:YES];
    
    
    if (managedObjectContext == nil) 
    { 
        managedObjectContext = [(VAS002AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 

    }

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUnusualEntryNotification:) name:@"UnusualEntryAdded" object:nil];
	[FlurryUtility report:EVENT_MAIN_ACTIVITY];
	
	//Hide the button for unusual notes.
	CGRect noteButtonFrame = noteButton.frame;
	noteButtonFrame.origin.y -= noteButton.bounds.size.height;
	noteButton.frame = noteButtonFrame;
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.origin.y -= noteButton.bounds.size.height;
	tableViewFrame.size.height += noteButton.bounds.size.height;
	self.tableView.frame = tableViewFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(chkPin) name:@"CheckPin" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(rsnPin) name:@"ResignPin" object: nil];

}

- (void)chkPin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pinString = [defaults valueForKey:SECURITY_PIN_SETTING];
    
    if (pinString != nil && ![pinString isEqual:@""]) {
		[self.navigationController setNavigationBarHidden:YES];
        self.tabBarController.tabBar.hidden = YES;  
		UIViewController *passwordViewController = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
		[self.navigationController pushViewController:passwordViewController animated:YES];
		[passwordViewController release];
	}
}

- (void)rsnPin
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
    self.tabBarController.tabBar.hidden = NO;  
}

- (IBAction)textFieldFinished:(id)sender
{
    // [sender resignFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated {
	//[self.tableView reloadData];
    self.tableView.backgroundView = nil;
	//self.reminderArray = [DateMath remindersDueForGroups];
}

- (void)handleUnusualEntryNotification:(NSNotification *)notification {
	NSDictionary *msgInfo = notification.userInfo;
	NSNumber *mean = [msgInfo objectForKey:@"mean"];
	NSNumber *value = [msgInfo objectForKey:@"value"];
	if (mean != nil && value != nil) {
		noteButton.enabled = YES;
		
		[UIView beginAnimations:@"slideButtonIn" context:nil];
		[UIView setAnimationDuration:0.5f];
		
		CGRect noteButtonFrame = noteButton.frame;
		noteButtonFrame.origin.y += noteButton.bounds.size.height;
		noteButton.frame = noteButtonFrame;
		
		CGRect tableViewFrame = self.tableView.frame;
		tableViewFrame.origin.y += noteButton.bounds.size.height;
		tableViewFrame.size.height -= noteButton.bounds.size.height;
		self.tableView.frame = tableViewFrame;
		[UIView commitAnimations];
		
		[NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(hideEntryNotification:) userInfo:nil repeats:NO];
	}
}

-(void)hideEntryNotification:(NSTimer *) theTimer{
	[UIView beginAnimations:@"slideButtonOut" context:nil];
	[UIView setAnimationDuration:0.5f];
	noteButton.enabled = NO;
	CGRect noteButtonFrame = noteButton.frame;
	noteButtonFrame.origin.y -= noteButton.bounds.size.height;
	noteButton.frame = noteButtonFrame;
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.origin.y -= noteButton.bounds.size.height;
	tableViewFrame.size.height += noteButton.bounds.size.height;
	self.tableView.frame = tableViewFrame;
	[UIView commitAnimations];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
	
	return numberOfSections;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRows = [sectionInfo numberOfObjects];
	
	return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSArray *sections = [self.fetchedResultsController sections];
	NSString *sectionName = [[sections objectAtIndex:section] name];
	return sectionName;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
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
    NSArray *sections = [self.fetchedResultsController sections];
	headerLabel.text = [[sections objectAtIndex:section] name];
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the Categories title
	Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = group.title;
	if (self.reminderArray != nil && [group.rateable boolValue] == YES) {
		if ([self.reminderArray containsObject:group.title]) {
			cell.imageView.image = [UIImage imageNamed:@"warning.png"];		
		}
		else {
			cell.imageView.image = [UIImage imageNamed:@"check.png"];
		}
	}
	else {
		cell.imageView.image = nil;
	}
	
	if ([group.visible boolValue] == NO) {
		cell.userInteractionEnabled = NO;
		cell.hidden = YES;
	}
	else {
		cell.userInteractionEnabled = YES;
		cell.hidden = NO;
	}
	
	
	cell.backgroundColor = [UIColor whiteColor];
	cell.accessoryView.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		[self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to delete Category." withError:error];
		}
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];

	ResultsViewController *resultsViewController;
	//GraphResultsViewController *graphResultsViewController;
	ViewNotesViewController *viewNotesViewController;
	GraphViewController *graphViewController;

    SavedResultsController *savedResultsController;
	

	
	switch (section) {
		case 0: //Results
			switch (row) {
				case 0: //Graph Results
                    /*
					graphResultsViewController = [[GraphResultsViewController alloc] initWithNibName:@"GraphResultsViewController" bundle:nil];
					[self.navigationController pushViewController:graphResultsViewController animated:YES];
					[graphResultsViewController release];
                     */
                    graphViewController = [[GraphViewController alloc] initWithNibName:@"GraphViewController" bundle:nil];
                    graphViewController.hidesBottomBarWhenPushed = YES;
					[self.navigationController pushViewController:graphViewController animated:YES];
					[graphViewController release];
					break;
                case 1: //Email Results
					resultsViewController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
					[self.navigationController pushViewController:resultsViewController animated:YES];
					[resultsViewController release];
					break;
                case 2: //Saved Results
					savedResultsController = [[SavedResultsController alloc] initWithNibName:@"SavedResultsController" bundle:nil];
					[self.navigationController pushViewController:savedResultsController animated:YES];
					[savedResultsController release];
					break;    
				case 3: //View Notes
					viewNotesViewController = [[ViewNotesViewController alloc] initWithNibName:@"ViewNotesViewController" bundle:nil];
					[self.navigationController pushViewController:viewNotesViewController animated:YES];
					[viewNotesViewController release];
					break;
				default:
					break;
			}
			break;
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark Create Data

- (void)createData {
	[self createRatings];
	[self createNotes];
}

- (void)createRatings {	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *groupTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:groupTitleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to fetch data to create rating." withError:error];
	}
	
	[groupTitleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
	
	NSDate *date;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	NSDateComponents *parts;
	[dateComponents setYear:2011];
	
	for (NSInteger i=1; i<=4; i++) {
		[dateComponents setMonth:i];
		NSInteger numberDays = [DateMath numberOfRecordsForMonth:i];
		for (NSInteger j=1; j<=numberDays; j++) {
			[dateComponents setDay:j];
			for (Group *group in fetchedObjects) {
				if ([group.rateable boolValue] == YES) {
					NSInteger count = 0;
					NSInteger total = 0;
					NSArray *scales = [self scalesForGroup:group];
					for (Scale *scale in scales) {
						Result *result = nil;
						
						NSInteger value;
						
						if (i==1) {
							result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
							value = j*3;
						}
						else if (i == 2) {
							result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
							value = 100 - (j*3);
						}
						else if(i==3) {
							if (j>7 && j<21) {
								if (j%10 == 0) {
									result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
									value = j*3;
								}								
							}
							else {
								result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
								value = j*3;
							}
                            
						}
						else {
							result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
							value = arc4random()%100;
						}
						
						if (result != nil) {
							date = [gregorian dateFromComponents:dateComponents];
							[result setValue:[NSNumber numberWithInt:value]];
							parts = [gregorian components:(NSDayCalendarUnit + NSMonthCalendarUnit + NSYearCalendarUnit) fromDate:date];
							[result setTimestamp:date];			
							[result setDay:[NSNumber numberWithInt:[parts day]]];
							[result setMonth:[NSNumber numberWithInt:[parts month]]];
							[result setYear:[NSNumber numberWithInt:[parts year]]];
							[result setScale:scale];
							[result setGroup:group];
							count++;
							total += value;
							
							if (count > 0) {
								GroupResult *groupResult = (GroupResult *)[NSEntityDescription insertNewObjectForEntityForName:@"GroupResult" inManagedObjectContext:self.managedObjectContext];
								groupResult.year = [NSNumber numberWithInt:[parts year]];
								groupResult.month = [NSNumber numberWithInt:[parts month]];
								groupResult.day = [NSNumber numberWithInt:[parts day]];
								groupResult.group = group;
								NSInteger avg = total/count;
								groupResult.value = [NSNumber numberWithInt:avg];
							}
						}
					}
				}
			}
		}
	}
	
	[gregorian release];
	
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to create Ratings" withError:error];
	}
}

- (NSArray *)scalesForGroup:(Group *)group {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:indexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group.title == %@",group.title];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to fetch data to create rating." withError:error];
	}
	
	[indexDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
	
	return fetchedObjects;
}

- (void)createNotes {
	NSManagedObject *note = nil;
	
	NSInteger i, j;
	NSString *noteText;
	
	NSDate *date;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	
	[dateComponents setYear:2011];
	NSInteger noteDice;
	
	for (i=1; i<=4; i++) {
		[dateComponents setMonth:i];
		NSInteger numberRecords = [DateMath numberOfRecordsForMonth:i];
		for (j=0; j<numberRecords; j++) {
			noteDice = arc4random()% 100;
			if (noteDice < 60) {
				[dateComponents setDay:j];
				date = [gregorian dateFromComponents:dateComponents];
				noteText = [NSString stringWithFormat:@"Note %d,%d",i,j];
				
				NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit + NSYearCalendarUnit + NSDayCalendarUnit fromDate:date];
				NSInteger day = [monthComponents day];
				NSInteger month = [monthComponents month];
				NSInteger year = [monthComponents year];
				NSString *monthString = [NSString stringWithFormat:@"%d %2d",year, month];
				
				note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
				[note setValue:noteText forKey: @"note"];
				[note setValue:date forKey: @"noteDate"];
				[note setValue:date forKey: @"timestamp"];
				[note setValue:monthString forKey:@"monthString"];
				[note setValue:[NSNumber numberWithInt:day] forKey:@"noteDay"];
				[note setValue:[NSNumber numberWithInt:month] forKey:@"noteMonth"];
				[note setValue:[NSNumber numberWithInt:year] forKey:@"noteYear"];				
			}			
		}
	}
	
	NSError *error = nil;
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to create Notes" withError:error];
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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *menuIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuIndex" ascending:YES];
    //	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSString *resultString = @"Results";
	NSPredicate *visiblePredicate = [NSPredicate predicateWithFormat:@"(section == %@) && (visible == YES)", resultString];
	[NSFetchedResultsController deleteCacheWithName:nil]; 
	[fetchRequest setPredicate:visiblePredicate];
	
    //	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, titleDescriptor, nil];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, menuIndexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[fetchRequest setFetchBatchSize:20];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = 
	[[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										  managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:@"section" 
													 cacheName:@"Results"];
	self.fetchedResultsController.safeDelegate = self;
	
	[sectionTitleDescriptor autorelease];
    //	[titleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors autorelease];
	[fetchRequest autorelease];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch data for main menu." withError:error];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if (!((sectionIndex == 0) && ([self.tableView numberOfSections] == 1)))
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            if (!((sectionIndex == 0) && ([self.tableView numberOfSections] == 1) ))
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
	
	if (!self.tableView.editing) {
		[self.tableView reloadData];
	}
	
	[self.tableView endUpdates];
}

#pragma mark Button Clicks
-(void)addNoteClicked:(id)sender {
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


#pragma mark Mail
-(void)sendFeedback {
	MailData* data = [[MailData alloc] init];
	NSString *recipientString = @"moodtracker@t2health.org";
	data.mailRecipients = [NSArray arrayWithObjects:recipientString, nil];
	NSString *subjectString = @"Feedback on T2 Mood Tracker App";
	data.mailSubject = subjectString;
	NSString *bodyString = @"Please feel free to send your feedback on this application to the team at the National Center for Telehealth & Technology (T2).";
	data.mailBody = bodyString;
	
	[FlurryUtility report:EVENT_FEEDBACK_PRESSED];
	
	[self sendMail:data];
	[data release];
}

-(void)tellAFriend {
	MailData *data = [[MailData alloc] init];
	data.mailRecipients = nil;
	NSString *subjectString = @"Check out this app for monitoring your mood!";
	data.mailSubject = subjectString;
	NSString *bodyString = @"I have been using the T2 Mood Tracker app on my phone. It's a really great tool for monitoring what's going on in my life using simple rating scales that I can fill in as often as I'd like. I thought you might like to check it out! <p><a href=\"http:/itunes.com/apps/t2moodtracker\">T2 Mood Tracker for iPhone</a></p><p><a href=\"http://t2health.org/apps/t2-mood-tracker\">T2 Mood Tracker for Andoid</a></p>";
	data.mailBody = bodyString;
	
	[FlurryUtility report:EVENT_REFER_FRIEND_PRESSED];
	
	[self sendMail:data];
	[data release];
}

-(void)sendMail:(MailData *)data {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) {
			[self displayComposerSheetWithMailData:data];
		}
		else {
			[self launchMailAppOnDeviceWithMailData:data];
		}		
	}
	else {
		[self launchMailAppOnDeviceWithMailData:data];
	}
    
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	if (result  == MFMailComposeResultCancelled) {
		[FlurryUtility report:EVENT_MAIL_CANCELED];
	}
	else if(result == MFMailComposeResultSaved) {
		[FlurryUtility report:EVENT_MAIL_SAVED];
	}
	else if(result == MFMailComposeResultSent) {
		[FlurryUtility report:EVENT_MAIL_SENT];
	}
	else if(result == MFMailComposeResultFailed) {
		[FlurryUtility report:EVENT_MAIL_ERROR];
	}
	[self dismissModalViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetWithMailData:(MailData *)data
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (data.mailSubject != nil) {
		[picker setSubject:data.mailSubject];
	}
	
	// Set up recipients
	if (data.mailRecipients != nil) {
		[picker setToRecipients:data.mailRecipients];
	}
	//	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
	//	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
	//	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	//	[picker setToRecipients:toRecipients];
	//	[picker setCcRecipients:ccRecipients];	
	//	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
	//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
	//    NSData *myData = [NSData dataWithContentsOfFile:path];
	//	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
	//	NSString *emailBody = @"It is raining in sunny California!";
	//	[picker setMessageBody:emailBody isHTML:NO];
	if (data.mailBody != nil) {
		[picker setMessageBody:data.mailBody isHTML:YES];
	}
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDeviceWithMailData:(MailData *)data {
	NSString *body = @"&body=";
	if (data.mailBody != nil) {
		body = [NSString stringWithFormat:@"%@%@",body,data.mailBody];
	}
	
	//TODO: Test on 3.1.2 device
	NSString *recipients = @"";
	if (data.mailRecipients != nil) {
		for (NSString *recipient in data.mailRecipients) {
			if (![recipients isEqual:@""]) {
				recipients = [NSString stringWithFormat:@"%@,%@",recipients,recipient];
			}
			else {
				recipients = [NSString stringWithFormat:@"%@%@",recipients,recipient];	  
			}
		}
	}
	
	recipients = [NSString stringWithFormat:@"mailto:%@",recipients];
	
	NSString *subject = @"&subject=";
	if (data.mailSubject != nil) {
		data.mailSubject = [NSString stringWithFormat:@"%@%@",subject,data.mailSubject];
	}
	
	NSString *email = [NSString stringWithFormat:@"%@%@%@", recipients, subject, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.fetchedResultsController = nil;
}

- (void)dealloc {
	[self.fetchedResultsController release];
	[self.managedObjectContext release];
	[self.reminderArray release];
	[self.tableView release];
	
	[super dealloc];
}

@end