//
//  HelpViewController.m
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "HelpViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"


@implementation HelpViewController

@synthesize helpWebView;

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
	
	[FlurryUtility startTimed:EVENT_HELP_ACTIVITY];
	
	NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:urlPath isDirectory:NO];
	[self.helpWebView loadRequest:[NSURLRequest requestWithURL:url]];	
	self.title = @"Help";
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

- (void)viewWillDisappear:(BOOL)animated {
	[FlurryUtility endTimed:EVENT_HELP_ACTIVITY];
}

- (void)dealloc {
    [super dealloc];
}


@end
