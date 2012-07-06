//
//  ImproveApplicationViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/26/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ImproveApplicationViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"

@implementation ImproveApplicationViewController

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
	
	self.title = @"Improve T2 Mood Tracker";
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	useFlurrySwitch.on = [userDefaults boolForKey:@"DEFAULTS_USE_FLURRY"];
	
	[FlurryUtility report:EVENT_SETTING_ANALYTICS_SCREEN];
}

- (IBAction)useFlurrySwitchChanged {
	BOOL switchState = useFlurrySwitch.on;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:switchState forKey:@"DEFAULTS_USE_FLURRY"];
	[userDefaults synchronize];
	if (switchState == YES) {
		[FlurryUtility report:EVENT_SETTING_ANALYTICS_ENABLED];
	}
	else {
		[FlurryUtility report:EVENT_SETTING_ANALYTICS_DISABLED];
	}

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


- (void)dealloc {
    [super dealloc];
}

@end
