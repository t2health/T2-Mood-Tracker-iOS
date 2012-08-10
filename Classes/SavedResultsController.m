//
//  SavedResultsController.m
//  VAS002
//
//  Created by Melvin Manzano on 3/22/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "SavedResultsController.h"
#import "Error.h"
#import "Saved.h"
#import "VAS002AppDelegate.h"
#import "ResultsViewController.h"
#import "DateMath.h"
#import "MailData.h"
#import "ViewSavedController.h"

@implementation SavedResultsController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;

id viewToDelete;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    resultsTableView.backgroundView = nil;

    
	self.title = @"Saved Results";
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
	
    
	//UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addResult:)];
	//self.navigationItem.rightBarButtonItem = plusButton;
	
	//[FlurryUtility report:EVENT_NOTES_ACTIVITY];	

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch results." withError:error];
	}   
}

- (void)viewWillAppear:(BOOL)animated {
	[resultsTableView reloadData];
}

#pragma mark Button Clicks
-(void)addResult:(id)sender {
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	ResultsViewController *addResultViewController = [[[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil] autorelease];	
	[appDelegate.navigationController pushViewController:addResultViewController animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[resultsTableView reloadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
 //   NSLog(@"fetched");
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Category entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedResults" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *noteDateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"savedDate" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:noteDateDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"ViewResults"];
	fetchedResultsController.safeDelegate = self;
    
	
	[fetchRequest setFetchBatchSize:60];
	
	return fetchedResultsController;
}

- (void)handleGesture:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) 
    {    

        UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                       initWithTitle:@"" 
                                       delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                       destructiveButtonTitle:nil 
                                       otherButtonTitles:@"Delete Results", nil] autorelease];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];  

        
        viewToDelete = recognizer.view;

    } 
    else if (recognizer.state == UIGestureRecognizerStateEnded) 
    {
        
    }
}

#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        //    NSLog(@"Ummm.");
        
    } 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"button press: %i", buttonIndex);
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        id view = viewToDelete;
        while (view && ![view isKindOfClass:[UITableViewCell class]]) {
            view = [view superview];
        }
        UITableViewCell *cell = view;
        NSIndexPath *indexPath = [resultsTableView indexPathForCell:cell];
        NSManagedObject *task = [fetchedResultsController objectAtIndexPath:indexPath];

        [self.managedObjectContext deleteObject:task];

        [self.managedObjectContext save:nil];
        
                
        // Delete file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *finalPath = [NSString stringWithFormat:@"%@%@",documentsDir, cell.detailTextLabel.text];
        NSString *finalPNGPath = [NSString stringWithFormat:@"%@%@.png",documentsDir, cell.detailTextLabel.text];
        if ([fileMgr removeItemAtPath:finalPath error:nil] != YES)
            NSLog(@"Unable to delete file");
        if ([fileMgr removeItemAtPath:finalPNGPath error:nil] != YES)
            NSLog(@"Unable to delete PNG");

        
        [resultsTableView reloadData];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        
    }
    
    
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;	
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the note
	Saved *saved = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [NSString stringWithFormat:@"%@", saved.title];
	cell.textLabel.text = saved.filename;
	cell.textLabel.textColor = [UIColor lightGrayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
	cell.detailTextLabel.text = dateString;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:18];
    
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    accessory.frame = CGRectMake(0, 0, 15, 15);
    accessory.userInteractionEnabled = YES;
    [accessory addTarget:self action:@selector(emailResults) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessory;
    
    UILongPressGestureRecognizer* gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [cell addGestureRecognizer:gestureRecognizer];

    
}



#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSFileManager *fileMgr = [NSFileManager defaultManager];

		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        Saved *saved = [self.fetchedResultsController objectAtIndexPath:indexPath];
       // NSLog(@"Edit-indexPath: %@", indexPath);

      //  NSLog(@"clicked: %@", saved.filename);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *finalPath = [NSString stringWithFormat:@"%@%@",documentsDir, saved.filename];
        NSString *finalPNGPath = [NSString stringWithFormat:@"%@%@.png",documentsDir, saved.filename];
        if ([fileMgr removeItemAtPath:finalPath error:nil] != YES)
            NSLog(@"Unable to delete file");
        if ([fileMgr removeItemAtPath:finalPNGPath error:nil] != YES)
            NSLog(@"Unable to delete PNG");
		
		NSError *error;
		if (![context save:&error]) {
			[Error showErrorByAppendingString:@"Unable to delete note" withError:error];
		}
        
        [resultsTableView reloadData];
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ViewSavedController *vsc = [[ViewSavedController alloc] initWithNibName:@"ViewSavedController" bundle:nil];
	Saved *saved = [self.fetchedResultsController objectAtIndexPath:indexPath];
	vsc.saved = saved;
	[self.navigationController pushViewController:vsc animated:YES];
	[vsc release];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}




#pragma mark Email delegates

- (void)emailResults
{
    // Fetch filtered data
  //  NSLog(@"Fetching data...");
    
    // Open mail view
    MailData *data = [[MailData alloc] init];
    data.mailRecipients = nil;
    NSString *subjectString = @"T2 Mood Tracker App Results";
    data.mailSubject = subjectString;
    NSString *filteredResults = @"";
    NSString *bodyString = @"T2 Mood Tracker App Results:<p>";
    
    data.mailBody = [NSString stringWithFormat:@"%@%@", bodyString, filteredResults];
    
   // [FlurryUtility report:EVENT_EMAIL_RESULTS_PRESSED];
    
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
		//[FlurryUtility report:EVENT_MAIL_CANCELED];
	}
	else if(result == MFMailComposeResultSaved) {
		//[FlurryUtility report:EVENT_MAIL_SAVED];
	}
	else if(result == MFMailComposeResultSent) {
		//[FlurryUtility report:EVENT_MAIL_SENT];
	}
	else if(result == MFMailComposeResultFailed) {
		//[FlurryUtility report:EVENT_MAIL_ERROR];
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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *Path = [documentsDir stringByAppendingString:@"/results.csv"];
    
    NSData *myData = [NSData dataWithContentsOfFile:Path];
	[picker addAttachmentData:myData mimeType:@"text/plain" fileName:@"results"];
  //  NSLog(@"Path: %@", Path);
	//NSLog(@"myData: %@", myData);
    
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


#pragma mark Memory management

- (void)dealloc {	
	self.fetchedResultsController.delegate = nil;
	[self.fetchedResultsController release];
	[self.managedObjectContext release];
	
    [super dealloc];
}

@end
