//
//  SettingsViewController.m
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "SettingsViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "SecurityViewController.h"
#import "ClearDataViewController.h"
#import "ReminderSettingsViewController.h"
#import "GroupsViewController.h"
#import "ImproveApplicationViewController.h"
#import "AddNoteViewController.h"
#import "ChartOptionsViewController.h"
#import "AddNoteViewController.h"
#import "PasswordViewController.h"


@implementation SettingsViewController

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
	menuTableView.backgroundView = nil;
	[FlurryUtility report:EVENT_SETTINGS_ACTIVITY];	
	//self.title	= @"ddd";
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(chkPin) name:@"CheckPin" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(rsnPin) name:@"ResignPin" object: nil];
    
}

- (void)chkPin
{
    NSLog(@"rootview:");
    
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark buttons
-(IBAction)securityButtonClicked:(id)sender {
	SecurityViewController *securityViewController = [[SecurityViewController alloc] initWithNibName:@"SecurityViewController" bundle:nil];
    securityViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:securityViewController animated:YES];
	[securityViewController release];
}

- (IBAction)clearDataButtonClicked:(id)sender {
	ClearDataViewController *clearDataViewController = [[ClearDataViewController alloc] initWithNibName:@"ClearDataViewController" bundle:nil];
    clearDataViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:clearDataViewController animated:YES];
	[clearDataViewController release];
}

- (IBAction)improveApplicationButtonClicked:(id)sender {
	ImproveApplicationViewController *improveApplicationViewController = [[ImproveApplicationViewController alloc] initWithNibName:@"ImproveApplicationViewController" bundle:nil];
    improveApplicationViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:improveApplicationViewController animated:YES];
	[improveApplicationViewController release];
}

- (IBAction)reminderButtonClicked:(id)sender {
	ReminderSettingsViewController *reminderSettingsViewController = [[ReminderSettingsViewController alloc] initWithNibName:@"ReminderSettingsViewController" bundle:nil];
    reminderSettingsViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:reminderSettingsViewController animated:YES];
	[reminderSettingsViewController release];
}

- (IBAction)areasButtonClicked:(id)sender {
	GroupsViewController *groupsViewController = [[GroupsViewController alloc] initWithNibName:@"GroupsViewController" bundle:nil];
    groupsViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:groupsViewController animated:YES];
	[groupsViewController release];
}

- (IBAction)optionsButtonClicked:(id)sender {
	ChartOptionsViewController *chartOptionsViewController = [[ChartOptionsViewController alloc] initWithNibName:@"ChartOptionsViewController" bundle:nil];
    chartOptionsViewController.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:chartOptionsViewController animated:YES];
	[chartOptionsViewController release];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numRows;
	
	switch (section) {
		case 0: //Number of sections
			numRows = 5;
			break;
		default:
			numRows = 0;
			break;
	}
	
    return numRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionName;
	
	switch (section) {
		case 0: //Settings
			sectionName = nil;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger section = [indexPath indexAtPosition:0];
	NSInteger row = [indexPath indexAtPosition:1];
	
	NSUserDefaults *defaults;
	
	switch (section) {
		case 0: //Settings
			switch (row) {
				case 0: //Areas Of Interest
					cell.textLabel.text = @"Add/Edit Rating Categories";
					break; 
              //  case 1: //Custom Charting
				//	cell.textLabel.text = @"Custom Charting";
					//break;
				case 1: //Reminders
					cell.textLabel.text = @"Reminders";
					break;
				case 2: //Security
					cell.textLabel.text = @"Security";
					break;
				case 3: //Clear Data
					cell.textLabel.text = @"Clear Data";
					break;
				case 4: //Show Tips
					defaults = [NSUserDefaults standardUserDefaults];
					BOOL storedVal;
					
					if (![defaults objectForKey:@"SHOW_TIPS_ON_STARTUP"]) {
						storedVal = YES;
					}
					else {
						storedVal = [defaults boolForKey:@"SHOW_TIPS_ON_STARTUP"];				
					}
					
					cell.textLabel.text = @"Show Startup Tips?";
					//CGRect switchRect = CGRectMake(cell.frame.size.width - 124, 7, 100, 24);
					UISwitch *aSwitch = [[UISwitch alloc] init];
					
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
					
                    
                    cell.accessoryView = aSwitch;
					//[cell addSubview:aSwitch];
					[aSwitch release];
					break;
				case 6: //Flurry data
					cell.textLabel.text = @"Improve Application";
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	
    return cell;
}

- (void)switchFlipped:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	UISwitch *theSwitch = (UISwitch *)sender;
	
	BOOL val = theSwitch.on;
	[defaults setBool:val forKey:@"SHOW_TIPS_ON_STARTUP"];
	[defaults synchronize];
	if (val == YES) {
		[FlurryUtility report:EVENT_SETTING_TIPS_ENABLED];		
	}
	else {
		[FlurryUtility report:EVENT_SETTING_TIPS_DISABLED];
	}
}


#pragma mark Table view delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
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
	headerLabel.text = @"Settings";
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath indexAtPosition:0];
	NSInteger row = [indexPath indexAtPosition:1];
    
	switch (section) {
		case 0: //Settings
			switch (row) {
				case 0: //Areas Of Interest
					[self areasButtonClicked:nil];
					break;
				case 1: //Reminders
					[self reminderButtonClicked:nil];
					break;
				case 2: //Security
					[self securityButtonClicked:nil];
					break;
				case 3://Clear Data
					[self clearDataButtonClicked:nil];
					break;
				case 4://There is a switch in this row, no actions needed
					break;
				case 5:
					[self improveApplicationButtonClicked:nil];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
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

#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
