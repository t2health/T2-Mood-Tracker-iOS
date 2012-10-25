//
//  ResultsViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 3/20/12.
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
#import "ResultsViewController.h"
#import "VAS002AppDelegate.h"
#import "Group.h"
#import "Result.h"
#import "Note.h"
#import "Scale.h"
#import "MailData.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "DateMath.h"
#import "Error.h"
#import "GroupResult.h"
#import "Constants.h"

#import "SavedResultsController.h"
#import "ViewSavedController.h"
#import "WebViewController.h"

#define kTextFieldWidth	260.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

const NSInteger kViewTag = 1;
int whichExport;

@implementation ResultsViewController

@synthesize groupsDictionary;
@synthesize switchDictionary;
@synthesize chartYear;
@synthesize chartMonth;
@synthesize valuesArraysForMonth;
@synthesize groupsArray;
@synthesize fromField;
@synthesize toField;
@synthesize managedObjectContext;
@synthesize tableView;
@synthesize dataSourceArray;
@synthesize ledgendColorsDictionary, filterViewItems;
@synthesize textfieldArray, groupArray, savingScreen;
@synthesize datePickView ,datePicker;
@synthesize doneButton, dataArray, dateFormatter;
@synthesize curFileName, noteSwitch;


CGRect picker_ShownFrame;
CGRect picker_HiddenFrame;	
int pickerShow;



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
    tableView.backgroundView = nil;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    // NSLog(@"stop 1");
    [self slideDownDidStop];
    
    curFileName = @"";
    whichExport = 0;
    savingScreen.hidden = YES;
    pickerShow = 0;
    UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    // NSLog(@"stop 2");
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(generateReport:)];
	self.navigationItem.rightBarButtonItem = nextButton;
    
    self.dataSourceArray = [NSArray arrayWithObjects:@"Start Date", @"End Date", @"Notes", nil];
    
    self.title = NSLocalizedString(@"Export Results", @"");
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
    
	[self fillGroupsDictionary];
	//[self fillColors];
	[self createSwitches];
    
    // Create custom table array
    //Initialize the array.
    filterViewItems = [[NSMutableArray alloc] init];
    
    
    NSDictionary *groupDict = [NSDictionary dictionaryWithObject:groupsDictionary forKey:@"Groups"];
    
    NSDictionary *fieldDict = [NSDictionary dictionaryWithObject:dataSourceArray forKey:@"Groups"];
    
    
    [filterViewItems addObject:fieldDict];
    [filterViewItems addObject:groupDict];
    
    //NSLog(@"filterViewItems: %@",filterViewItems);
    
    // Init array to hold date data
    textfieldArray = [[NSMutableArray alloc]init];
    for(int i=0; i<2; i++){
        [textfieldArray addObject: [self.dateFormatter stringFromDate:[NSDate date]]];
    }
    //NSLog(@"stop 6");
    // NSLog(@"switchDictionary: %@", switchDictionary);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.dataSourceArray = nil;
    self.dateFormatter = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{	
    [doneButton release];
	[dataArray release];
	[datePicker release];
	[dateFormatter release];
    [textfieldArray release];
	
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark Orientation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	BOOL shouldRotate = NO;	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
		shouldRotate = YES;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
    {
		shouldRotate = YES;
	}
	
	return shouldRotate;
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    [tableView reloadData];
    [self resignPicker];
}

#pragma mark Fill Groups

- (void)fillGroupsDictionary {
	if (self.groupsDictionary == nil) {
		NSMutableDictionary *groups = [NSMutableDictionary dictionary];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
        
		NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(showGraph == YES)"];
		NSPredicate *visiblePredicate = [NSPredicate predicateWithFormat:@"(visible == YES)"];
		
		NSArray *finalPredicateArray = [NSArray arrayWithObjects:groupPredicate,visiblePredicate, nil];
		NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
		[fetchRequest setPredicate:finalPredicate];
        
		NSError *error = nil;
		NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			[Error showErrorByAppendingString:@"Unable to get Categories to graph" withError:error];
		}
		
		[fetchRequest release];
		
		for (Group *aGroup in objects) {
			[groups setObject:aGroup forKey:aGroup.title];
		}			
		self.groupsDictionary = [NSDictionary dictionaryWithDictionary:groups];
		
		NSArray *keys = [self.groupsDictionary allKeys];
		NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		
		NSMutableArray *grpArray = [NSMutableArray array];
		for (NSString *groupName in sortedKeys) {
			[grpArray addObject:[self.groupsDictionary objectForKey:groupName]];
		}
		self.groupsArray = [NSArray arrayWithArray:grpArray];
        // NSLog(@"grpArray: %@", grpArray);
	}
}

#pragma mark Switches

-(void)createSwitches {
	if (self.switchDictionary == nil) {
		self.switchDictionary = [NSMutableDictionary dictionary];
		
		NSInteger switchWidth = 96;
		NSInteger height = 24;
		NSInteger xOff = 8;
		NSInteger yOff = 8;
		
		CGRect switchRect = CGRectMake(xOff, yOff , switchWidth, height);
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL storedVal;
		NSString *key;
		
		NSArray *grpArray = [[self.groupsDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		for (NSString *groupTitle in grpArray) {			
			UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchRect];
			key = [NSString stringWithFormat:@"SWITCH_STATE_%@",groupTitle];
			if (![defaults objectForKey:key]) {
				storedVal = YES;
			}
			else {
				storedVal = [defaults boolForKey:key];				
			}
            
			aSwitch.on = storedVal;
			aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
			[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
			
			[self.switchDictionary setValue:aSwitch forKey:groupTitle];
			[aSwitch release];
		}
	}
}

-(void)switchFlipped:(id)sender {
	NSEnumerator *enumerator = [self.switchDictionary keyEnumerator];
	id key;
	
	UISwitch *currentValue;
	NSString *switchTitle = @"";
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
	while ((key = [enumerator nextObject])) {
		currentValue = [self.switchDictionary objectForKey:key];
		if (currentValue == sender) {
			switchTitle = key;
			defaultsKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",switchTitle];
			BOOL val = ((UISwitch *)currentValue).on;
			[defaults setBool:val forKey:defaultsKey];
			[defaults synchronize];
			NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:switchTitle, [NSNumber numberWithBool:val],nil];
			[FlurryUtility report:EVENT_GRAPHRESULTS_SWITCHFLIPPED withData:usrDict];
		}
	}
	
	//[self monthChanged];
}

#pragma mark colors

-(UIColor *)UIColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor grayColor], [UIColor brownColor],	[UIColor cyanColor],[UIColor magentaColor],  nil];
	
	UIColor *color = nil;
	
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
	}
	return color;
}


- (void)fillColors {
	if (self.ledgendColorsDictionary == nil) {
		self.ledgendColorsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.groupsDictionary allKeys];
        // NSLog(@"groupDict: %@", groupsDictionary);
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
			UIColor *color = [self UIColorForIndex:index];
			[self.ledgendColorsDictionary setObject:color forKey:groupTitle];
			index++;
		}
	}
    
    // NSLog(@"colorDict: %@", ledgendColorsDictionary);
}

#pragma mark Show filter view for Email Results
- (void)emailResults
{
    
    // Fetch filtered data
    //   NSLog(@"Fetching data...");
    
    // Open mail view
    MailData *data = [[MailData alloc] init];
    data.mailRecipients = nil;
    NSString *subjectString = @"T2 Mood Tracker App Results";
    data.mailSubject = subjectString;
    NSString *filteredResults = @"";
    NSString *bodyString = @"T2 Mood Tracker App Results:<p>";
    
    data.mailBody = [NSString stringWithFormat:@"%@%@", bodyString, filteredResults];
    
    [FlurryUtility report:EVENT_EMAIL_RESULTS_PRESSED];
    
    [self sendMail:data];
    [data release];
    
    
    
}


#pragma mark Fetch Result Data

- (NSDictionary *)getValueDictionaryForMonth {
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupResult" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    
    /*
     NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
     
     for (NSManagedObject *info in fetchedObjects) {
     
     // Group Result
     NSLog(@"day: %@", [info valueForKey:@"day"]);
     NSLog(@"month: %@", [info valueForKey:@"month"]);
     NSLog(@"value: %@", [info valueForKey:@"value"]);
     NSLog(@"year: %@", [info valueForKey:@"year"]);
     
     NSLog(@"-----------------");     
     }
     */
    
	// Create the sort descriptors array.
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	NSSortDescriptor *monthDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:YES];
	NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
	NSSortDescriptor *groupTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"group.title" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearDescriptor, monthDescriptor,dayDescriptor, groupTitleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *groupPredicateString = @"";
	
	NSArray *results;
	NSPredicate *titlePredicate;
	NSString *timePredicateString;
	NSPredicate *timePredicate;
	NSPredicate *visiblePredicate;
	NSArray *finalPredicateArray;
	NSPredicate *finalPredicate;
    
    
	for (NSString *groupTitle in self.groupsDictionary) 
    {
		Group *currentGroup = [self.groupsDictionary objectForKey:groupTitle];
		UISwitch *currentSwitch = [switchDictionary objectForKey:groupTitle];
        // NSLog(@"currentSwitch: %@", currentSwitch);
        
		if (currentSwitch.on == YES) 
        {
            
			groupPredicateString = [NSString stringWithFormat:@"group.title like %%@"];
			titlePredicate = [NSPredicate predicateWithFormat:groupPredicateString, groupTitle];
			timePredicateString = [NSString stringWithFormat:@"(year == %%@) && (month == %%@)"];
			timePredicate = [NSPredicate predicateWithFormat:timePredicateString, [ NSNumber numberWithInt:self.chartYear], [NSNumber numberWithInt:self.chartMonth]];
			visiblePredicate = [NSPredicate predicateWithFormat:@"group.visible == TRUE"];
            
			finalPredicateArray = [NSArray arrayWithObjects:titlePredicate, timePredicate,visiblePredicate, nil];
		    
			finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
            
			[fetchRequest setPredicate:finalPredicate];
            
			[fetchRequest setFetchBatchSize:31];
			
			NSError *error = nil;
			results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            // NSLog(@"result: %@", results);
            
            
            
			if (error) 
            {
				[Error showErrorByAppendingString:@"could not get result data to email" withError:error];
			} 
			else 
            {
                
				NSMutableArray *tempTotalArray = [NSMutableArray arrayWithCapacity:31];
				NSMutableArray *tempCountArray = [NSMutableArray arrayWithCapacity:31];
                
				for (NSInteger i=0; i<31; i++) 
                {
					[tempTotalArray addObject:[NSNumber numberWithInt:0]];
					[tempCountArray addObject:[NSNumber numberWithInt:0]];
				}
				
				for (GroupResult *groupResult in results) 
                {
					double value = [groupResult.value doubleValue];
					double day = [groupResult.day doubleValue] - 1;
					double totalValue = [[tempTotalArray objectAtIndex:day] doubleValue] + value;
					double count = [[tempCountArray objectAtIndex:day] doubleValue] + 1;
					[tempTotalArray replaceObjectAtIndex:day withObject:[NSNumber numberWithDouble:totalValue]];
					[tempCountArray replaceObjectAtIndex:day withObject:[NSNumber numberWithDouble:count]];
				}
				
				NSMutableArray *summaryArray = [NSMutableArray arrayWithCapacity:31];
				for (NSInteger i = 0; i<31; i++) 
                {
					double value = [[tempTotalArray objectAtIndex:i] doubleValue];
					double count = [[tempCountArray objectAtIndex:i] doubleValue];
					double averageValue = -1;
					if(count > 0) 
                    {
						averageValue = value/count;
						if (![currentGroup.positiveDescription boolValue] == NO) 
                        {
							averageValue = 100 - averageValue;
                        }
                    }
                    
					[summaryArray addObject:[NSNumber numberWithDouble:averageValue]];
				}
                
				[tempDict setObject:summaryArray forKey:groupTitle];
			}
		}
	}
	
	NSDictionary *valueDictionary = [NSDictionary dictionaryWithDictionary:tempDict];
    
	[yearDescriptor release];
	[monthDescriptor release];
	[dayDescriptor release];
	[groupTitleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
    
    
    
	return valueDictionary;
}

#pragma mark Mail Delegate Methods

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *Path = [documentsDir stringByAppendingString:[NSString stringWithFormat:@"/%@", curFileName]];
    
    NSData *myData = [NSData dataWithContentsOfFile:Path];
	[picker addAttachmentData:myData mimeType:@"text/plain" fileName:curFileName];
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






#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [filterViewItems count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dictionary = [filterViewItems objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"Groups"];
     NSLog(@"arraycount: %i", [array count]);
    return [array count];
    
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
    
    NSString *sectionName = @"";
    if (section == 1) 
    {
        sectionName = @"Categories";
    }
    else
    {
        sectionName = @"Date Range";
    }
    
    headerLabel.text = sectionName;
    
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
	// Configure the cell to show the Categories title
    NSInteger row = [indexPath indexAtPosition:1];
	
    // Fetch categories
	Group *group = [self.groupsArray objectAtIndex:row];
	NSString *groupName = group.title;
    NSString *cellName = @"";
    NSString *cellDate = @"";
    
    if (indexPath.section == 0) 
    {
        
        cellName = [self.dataSourceArray objectAtIndex: indexPath.row];
        
        if ([cellName isEqualToString:@"Notes"]) 
        {
            UISwitch *aSwitch = [[UISwitch alloc] init];
            aSwitch.on = YES;
            noteSwitch = aSwitch;
            cell.accessoryView = noteSwitch;
            [aSwitch release];
        }
        else 
        {
            cellDate = [self.textfieldArray objectAtIndex: indexPath.row];

            cell.accessoryView = nil;
        }
    }
    else
    {
        // groups
        cellName = groupName;
        UISwitch *aSwitch = [self.switchDictionary objectForKey:groupName];
        aSwitch.tag = indexPath.row;
        cell.accessoryView = aSwitch;
        
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = cellName;
    cell.detailTextLabel.text = cellDate;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
	cell.textLabel.textAlignment  = UITextAlignmentLeft;
	cell.backgroundColor = [UIColor whiteColor];
	//cell.accessoryView.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    [cell setNeedsLayout]; 
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
    if (indexPath.section == 0) 
    {
        int startHeight = 0;
        int startWeight = 0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            //iPad
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
            if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
            {
                startHeight = 329;
                startWeight = 768;
            }
            else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
            {
                startHeight = 585;
                startWeight = 1024;
                
            }
        }
        else 
        {
            //iPhone
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
            if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
            {
                startHeight = 329;
                startWeight = 320;
                
            }
            else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
            {
                startHeight = 423;
                startWeight = 480;
                
            }
        }
        
        
        UITableViewCell *targetCell = [self.tableView cellForRowAtIndexPath:indexPath];
        self.datePicker.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
        // check if our date picker is already on screen
        if (self.datePicker.superview == nil)
        {
            
            [self.view addSubview: self.datePicker];
            // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
            //
            // compute the start frame
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          startWeight, pickerSize.height);
            self.datePicker.frame = startRect;
            // NSLog(@"startheight: %i", startHeight);
            // compute the end frame
            CGRect pickerRect = CGRectMake(0.0,
                                           (screenRect.origin.y + screenRect.size.height) - startHeight,
                                           startWeight,
                                           pickerSize.height);
            // start the slide up animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            
            self.datePicker.frame = pickerRect;
            
            // shrink the table vertical size to make room for the date picker
            CGRect newFrame = self.tableView.frame;
            newFrame.size.height -= self.datePicker.frame.size.height;
            self.tableView.frame = newFrame;
            [UIView commitAnimations];
            
            // add the "Done" button to the nav bar
            self.navigationItem.rightBarButtonItem = self.doneButton;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark Email/Save
-(void)generateReport:(id)sender {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle:@"" 
                                   delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                                   destructiveButtonTitle:nil 
                                   otherButtonTitles:@"Export CSV", @"Export PDF", nil] autorelease];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];  
}

- (void)saveResults
{
    [self.view bringSubviewToFront:savingScreen];
    [self fetchFilteredResults];
}

- (void)fetchFilteredResults
{
    // Get raw data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    
    NSString *rawFromDate = [textfieldArray objectAtIndex:0];
    NSString *rawToDate = [textfieldArray objectAtIndex:1];
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    NSDate *myFromDate = [df dateFromString: rawFromDate];
    NSDate *myToDate = [df dateFromString: rawToDate];

    NSLog(@"from: %@ - to: %@", myFromDate, myToDate);

    
    
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(timestamp >= %@) AND (timestamp <= %@)", myFromDate, myToDate];
    
    NSString *categoryString = @"";
    int counter = 0;
    for (NSString *groupTitle in self.groupsDictionary) 
    {
		Group *currentGroup = [self.groupsDictionary objectForKey:groupTitle];
		UISwitch *currentSwitch = [switchDictionary objectForKey:groupTitle];
        // NSLog(@"switch: %@", currentSwitch);
        NSString *tString = currentGroup.title;
        
        if (!currentSwitch.on) 
        {
            if (counter == 0) 
            {
                categoryString = [NSString stringWithFormat:@"(group.title != '%@' )", tString];
                counter++;
            }
            else
            {
                categoryString = [NSString stringWithFormat:@"%@ AND (group.title != '%@' )",categoryString, tString];
            }
            
        }
    }
    //  NSLog(@"tstring: %@", categoryString);
    
    if (counter != 0) 
    {
        NSPredicate *catPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@", categoryString]];
        
        NSArray *finalPredicateArray = [NSArray arrayWithObjects:datePredicate, catPredicate, nil];
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
        [fetchRequest setPredicate:finalPredicate];
    }
    else
    {
        NSArray *finalPredicateArray = [NSArray arrayWithObjects:datePredicate, nil];
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
        [fetchRequest setPredicate:finalPredicate];
    }
    
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [Error showErrorByAppendingString:@"Unable to get data" withError:error];
    }
    
    [fetchRequest release];
    
    
    NSArray *noteArray = [NSArray arrayWithArray:[self fetchNotes]];

    if (whichExport == 0) 
    {
        //PDF
        [self convertArrayToPDF:objects:noteArray];
        
    }
    else 
    {
        // CSV
        [self convertArrayToCSV:objects:noteArray];
    }
    
}

- (NSArray *)fetchNotes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *rawFromDate = [textfieldArray objectAtIndex:0];
    NSString *rawToDate = [textfieldArray objectAtIndex:1];
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    NSDate *myFromDate = [df dateFromString: rawFromDate];
    NSDate *myToDate = [df dateFromString: rawToDate];
    
    NSLog(@"from: %@ - to: %@", myFromDate, myToDate);

    
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(timestamp >= %@) AND (timestamp <= %@)", myFromDate, myToDate];
    
    NSArray *finalPredicateArray = [NSArray arrayWithObjects:datePredicate, nil];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
    [fetchRequest setPredicate:finalPredicate];
    
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [Error showErrorByAppendingString:@"Unable to get data" withError:error];
    }
    
    [fetchRequest release];
    
    return objects;
    
}
#pragma mark -
#pragma mark delegate method


- (void)service:(PDFService *)service
didFailedCreatingPDFFile:(NSString *)filePath
        errorNo:(HPDF_STATUS)errorNo
       detailNo:(HPDF_STATUS)detailNo
{
    NSString *message = [NSString stringWithFormat:@"Couldn't create a PDF file at %@\n errorNo:0x%04x detalNo:0x%04x",
                         filePath,
                         errorNo,
                         detailNo];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"PDF creation error"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void) createPDF
{

    NSArray *arrayPaths = 
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"test.pdf"];
    NSLog(@"path: %@", path);
    PDFService *service = [PDFService instance];
    service.delegate = self;
    [service createPDFFile:path];
    service.delegate = nil;
    [self showPDF];
}

- (void)convertArrayToPDF:(NSArray *)valueArray:(NSArray *)withNotes;
{
    
    NSArray * data = [NSArray arrayWithArray:valueArray];
    NSArray * notes = [NSArray arrayWithArray:withNotes];
    
    NSMutableString * csv = [NSMutableString string];
    
    for (Result *aResult in data) {
        //NSLog(@"resulttest: %@,%@,%@/%@,%@",aResult.timestamp, aResult.group.title, aResult.scale.minLabel, aResult.scale.maxLabel, aResult.value);
        NSString * combinedLine = [NSString stringWithFormat:@"%@,%@,%@/%@,%@,%@",aResult.timestamp, aResult.group.title, aResult.scale.minLabel, aResult.scale.maxLabel, aResult.value, aResult.group.positiveDescription];
        [csv appendFormat:@"%@\n", combinedLine];
        
    }
    [csv appendFormat:@"NOTES,-,-,-\n"];
    // Fetch Notes and add CSV
    if (noteSwitch.on) 
    {
        for (Note *aNote in notes) 
        {
            NSString * combinedLine = [NSString stringWithFormat:@"NOTES,%@,\"%@\",",aNote.timestamp, aNote.note];
            
            [csv appendFormat:@"%@\n", combinedLine];
            
        }	
    }
    //  NSLog(@"csv: %@", csv);
    
    
    
    // Save file to disk
    //UIApplication *app = [UIApplication sharedApplication];
	//VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];	 
    
    NSString *rawFromDate = [textfieldArray objectAtIndex:0];
    NSString *rawToDate = [textfieldArray objectAtIndex:1];
    NSArray *fromDateArray = [rawFromDate componentsSeparatedByString:@"/"];
    NSArray *toDateArray = [rawToDate componentsSeparatedByString:@"/"];
    
    int fromDay = [[fromDateArray objectAtIndex:1] intValue];
    int fromMonth = [[fromDateArray objectAtIndex:0] intValue];
    int fromYear = [[fromDateArray objectAtIndex:2] intValue];
    
    int toDay = [[toDateArray objectAtIndex:1] intValue];
    int toMonth = [[toDateArray objectAtIndex:0] intValue];
    int toYear = [[toDateArray objectAtIndex:2] intValue];  
    
    
    int r = arc4random() % 1000;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
    [dateFormat setDateFormat:@"MM/dd/yy"];
    NSDate *fromTempDate = [dateFormat dateFromString:rawFromDate];
    NSDate *toTempDate = [dateFormat dateFromString:rawToDate];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *fromDate = [dateFormat stringFromDate:fromTempDate];
    NSString *toDate = [dateFormat stringFromDate:toTempDate];
    
    NSString *fileName = [NSString stringWithFormat:@"/%i%i%i_%i%i%i_%i.csv", fromDay, fromMonth, fromYear, toDay, toMonth, toYear, r];  
    NSString *rawFileName = [NSString stringWithFormat:@"%i%i%i_%i%i%i_%i.csv", fromDay, fromMonth, fromYear, toDay, toMonth, toYear, r];
    
    NSString *reportType = @"";
    if (whichExport == 0) 
    {
        reportType = @"CSV";
    }
    else 
    {
        reportType = @"PDF";
    }
    NSString *titleText = [NSString stringWithFormat:@" (%@) %@ - %@",reportType, fromDate, toDate];
    NSDate *today = [NSDate date];
    curFileName = rawFileName;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *finalPath = [NSString stringWithFormat:@"%@%@",documentsDir, fileName];
    [csv writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.view sendSubviewToBack:savingScreen];
    
    // Save file info in Core Data
    NSManagedObject *savedResult = nil;
    
    savedResult = [NSEntityDescription insertNewObjectForEntityForName:@"SavedResults" inManagedObjectContext:self.managedObjectContext];
    
    [savedResult setValue:titleText forKey: @"title"];
    [savedResult setValue:fileName forKey: @"filename"];
    [savedResult setValue:today forKey: @"timestamp"];
    
    
    
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        [Error showErrorByAppendingString:@"Unable to save result" withError:error];
    } 	
    
    // Send to SavedResults View
    savingScreen.hidden = YES;
    ViewSavedController *viewSavedController = [[[ViewSavedController alloc] initWithNibName:@"ViewSavedController" bundle:nil] autorelease];
	viewSavedController.finalPath = fileName;
    viewSavedController.fileName = titleText;
    if (whichExport == 0) 
    {
        viewSavedController.fileType = @"CSV";
    }
    else 
    {
        viewSavedController.fileType = @"PDF";
    }
    [self.navigationController pushViewController:viewSavedController animated:YES];   
}

- (void)convertArrayToCSV:(NSArray *)valueArray:(NSArray *)withNotes;
{
    
    // Create CSV
    NSArray * data = [NSArray arrayWithArray:valueArray];
    NSArray * notes = [NSArray arrayWithArray:withNotes];
    
    NSMutableString * csv = [NSMutableString string];
    
    for (Result *aResult in data) {
        //NSLog(@"resulttest: %@,%@,%@/%@,%@",aResult.timestamp, aResult.group.title, aResult.scale.minLabel, aResult.scale.maxLabel, aResult.value);
        NSString * combinedLine = [NSString stringWithFormat:@"%@,%@,%@/%@,%@,%@",aResult.timestamp, aResult.group.title, aResult.scale.minLabel, aResult.scale.maxLabel, aResult.value, aResult.group.positiveDescription];
        [csv appendFormat:@"%@\n", combinedLine];
        
    }
    [csv appendFormat:@"NOTES,-,-,-\n"];
    // Fetch Notes and add CSV
    if (noteSwitch.on) 
    {
        for (Note *aNote in notes) 
        {
            NSString * combinedLine = [NSString stringWithFormat:@"NOTES,%@,\"%@\",",aNote.timestamp, aNote.note];
            
            [csv appendFormat:@"%@\n", combinedLine];
            
        }	
    }
  //  NSLog(@"csv: %@", csv);
    
    
    
    // Save file to disk
    //UIApplication *app = [UIApplication sharedApplication];
	//VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];	 
    
    NSString *rawFromDate = [textfieldArray objectAtIndex:0];
    NSString *rawToDate = [textfieldArray objectAtIndex:1];
    NSArray *fromDateArray = [rawFromDate componentsSeparatedByString:@"/"];
    NSArray *toDateArray = [rawToDate componentsSeparatedByString:@"/"];
    
    int fromDay = [[fromDateArray objectAtIndex:1] intValue];
    int fromMonth = [[fromDateArray objectAtIndex:0] intValue];
    int fromYear = [[fromDateArray objectAtIndex:2] intValue];
    
    int toDay = [[toDateArray objectAtIndex:1] intValue];
    int toMonth = [[toDateArray objectAtIndex:0] intValue];
    int toYear = [[toDateArray objectAtIndex:2] intValue];  
    
    
    int r = arc4random() % 1000;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
    [dateFormat setDateFormat:@"MM/dd/yy"];
    NSDate *fromTempDate = [dateFormat dateFromString:rawFromDate];
    NSDate *toTempDate = [dateFormat dateFromString:rawToDate];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *fromDate = [dateFormat stringFromDate:fromTempDate];
    NSString *toDate = [dateFormat stringFromDate:toTempDate];
    
    NSString *fileName = [NSString stringWithFormat:@"/%i%i%i_%i%i%i_%i.csv", fromDay, fromMonth, fromYear, toDay, toMonth, toYear, r];  
    NSString *rawFileName = [NSString stringWithFormat:@"%i%i%i_%i%i%i_%i.csv", fromDay, fromMonth, fromYear, toDay, toMonth, toYear, r];
    
    NSString *reportType = @"";
    if (whichExport == 0) 
    {
        reportType = @"CSV";
    }
    else 
    {
        reportType = @"PDF";
    }
    NSString *titleText = [NSString stringWithFormat:@" (%@) %@ - %@",reportType, fromDate, toDate];
    NSDate *today = [NSDate date];
    curFileName = rawFileName;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *finalPath = [NSString stringWithFormat:@"%@%@",documentsDir, fileName];
    [csv writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.view sendSubviewToBack:savingScreen];
    
    // Save file info in Core Data
    NSManagedObject *savedResult = nil;
    
    savedResult = [NSEntityDescription insertNewObjectForEntityForName:@"SavedResults" inManagedObjectContext:self.managedObjectContext];
    
    [savedResult setValue:titleText forKey: @"title"];
    [savedResult setValue:fileName forKey: @"filename"];
    [savedResult setValue:today forKey: @"timestamp"];

    
    
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        [Error showErrorByAppendingString:@"Unable to save result" withError:error];
    } 	
    
    // Send to SavedResults View
    savingScreen.hidden = YES;
    ViewSavedController *viewSavedController = [[[ViewSavedController alloc] initWithNibName:@"ViewSavedController" bundle:nil] autorelease];
	viewSavedController.finalPath = fileName;
    viewSavedController.fileName = titleText;
    switch (whichExport) {
        case 0:
            // PDF
            viewSavedController.fileType = @"PDF";
            break;
        case 1:
            // CSV
            viewSavedController.fileType = @"CSV";
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:viewSavedController animated:YES];   
   
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
    
    //   NSLog(@"button press: %i", buttonIndex);
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        // Export CSV
        // NSLog(@"Export CSV");
        whichExport = 0;
        savingScreen.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(saveResults) userInfo:nil repeats:NO];
        
    } 
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        // Export PDF
        //  NSLog(@"Export PDF");
        whichExport = 1;
        savingScreen.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(saveResults) userInfo:nil repeats:NO];
        //[self emailResults];
    }
    /*
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) 
    {
        // Export CSV
        //  NSLog(@"Email CSV");
        whichExport = 1;
        savingScreen.hidden = NO;
      //  [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(saveResults) userInfo:nil repeats:NO];
        
        //[self emailResults];
    }
     else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) 
     {
     // Export PNG
     NSLog(@"Email PNG");
     [self emailResults];
     }
     */
}


#pragma mark Date Picker
- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.datePicker removeFromSuperview];
}

- (IBAction)dateAction:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    if ([cell.textLabel.text isEqualToString:@"Start Date"])
    {
        [textfieldArray replaceObjectAtIndex:0 withObject:cell.detailTextLabel.text];
    }
    else
    {
        [textfieldArray replaceObjectAtIndex:1 withObject:cell.detailTextLabel.text];
    }
    //NSLog(@"textfieldArray: %@", textfieldArray);   
    
}

- (void)resignPicker
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.datePicker.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    self.datePicker.frame = endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.datePicker.frame.size.height;
	self.tableView.frame = newFrame;
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(generateReport:)];
	self.navigationItem.rightBarButtonItem = nextButton;    
}

- (IBAction)doneAction:(id)sender
{
    [self resignPicker];
}

- (void) showPDF
{
    NSString *nibName = @"WebViewController";
    WebViewController *controller = [[WebViewController alloc] initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
#pragma mark Fetched results controller
@end
