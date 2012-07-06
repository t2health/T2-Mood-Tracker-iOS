//
//  ErrorViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/21/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ErrorViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"

@implementation ErrorViewController

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
	
	[FlurryUtility report:EVENT_ERROR_ACTIVITY];
	
	self.title = @"Serious Error";
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)addStringToMessage:(NSString *)string {
	NSString *newString = [NSString stringWithFormat:@"%@ \n %@",string, textView.text];
	textView.text = newString;
}

- (IBAction)okClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
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
