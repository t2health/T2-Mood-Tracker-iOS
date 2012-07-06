//
//  HourSelectorViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/13/11.
//  Copyright 2011 GDIT. All rights reserved.
//

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
