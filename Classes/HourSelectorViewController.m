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

#import "HourSelectorViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"

@implementation HourSelectorViewController

@synthesize section;

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
	
	for (UIView* subview in hourPicker.subviews) {
		subview.frame = hourPicker.bounds;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSDate *storedDate;
	
	switch (section) {
		case 0: //Morning
			storedDate = [defaults objectForKey:@"MORNING_REMINDER_TIME"];
			break;
		case 1: //Noon
			storedDate = [defaults objectForKey:@"NOON_REMINDER_TIME"];			
			break;
		case 2: //Evening
			storedDate = [defaults objectForKey:@"EVENING_REMINDER_TIME"];
			break;
		default:
			storedDate = nil;
			break;
	}
	
	hourPicker.date = storedDate;
	
	[FlurryUtility report:EVENT_GROUP_ACTIVITY_EDIT_HOUR];
}

- (IBAction)hourSelected:(id)sender {
	
}
								   
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

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

- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSDate *storedDate = hourPicker.date;
	
	switch (section) {
		case 0: //Morning
			[defaults setObject:storedDate forKey:@"MORNING_REMINDER_TIME"];
			break;
		case 1: //Noon
			[defaults setObject:storedDate forKey:@"NOON_REMINDER_TIME"];
			break;
		case 2: //Evening
			[defaults setObject:storedDate forKey:@"EVENING_REMINDER_TIME"];
			break;
		default:
			break;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReminderTimeChanged" object:self];
}

- (void)dealloc {
    [super dealloc];
}

@end
