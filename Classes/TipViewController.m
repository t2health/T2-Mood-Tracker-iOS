//
//  TipViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/20/11.
//  Copyright 2011 GDIT. All rights reserved.
//

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
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            tipView.font = [UIFont fontWithName:@"Arial" size:17.0f];
            touchLabel.font = [UIFont fontWithName:@"Arial" size:17.0f];
        }
        else 
        {
            tipView.font= [UIFont fontWithName:@"Arial" size:12.0f];
            touchLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        }
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
