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

#import "TipViewController.h"
#import "Tip.h"
#import "VAS002AppDelegate.h"
#import "Error.h"
#import "VASAnalytics.h"

@implementation TipViewController

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
	
	self.title = @"Tip";
	
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	NSManagedObjectContext *managedObjectContext = appDeleate.managedObjectContext;
		
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tip" inManagedObjectContext:managedObjectContext];
	[fetch setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
	if (!error) {
		NSInteger numberTips = [fetchedObjects count];
		NSInteger tipNumber = arc4random()%numberTips;
		
		Tip *tip = [fetchedObjects objectAtIndex:tipNumber];
		tipView.text = tip.tip;
	}
	else {
		[Error showErrorByAppendingString:@"Unable to fetch tip." withError:error];
	}

	[FlurryUtility report:EVENT_TIP_ACTIVITY];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Buttons
- (IBAction)showTipSwitchFlipped {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:showTipSwitch.on forKey:@"SHOW_TIPS_ON_STARTUP"];
	[defaults synchronize];
	
	if (showTipSwitch.on) {
		[FlurryUtility report:EVENT_SETTING_TIPS_ENABLED];
	}
	else {
		[FlurryUtility report:EVENT_SETTING_TIPS_DISABLED];
	}

}

- (IBAction)closeTipsPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark memory

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
