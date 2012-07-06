//
//  OutReachViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 6/6/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "OutReachViewController.h"

@implementation OutReachViewController

@synthesize _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"outreach_wefeature" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:urlPath isDirectory:NO];
	[self._webView loadRequest:[NSURLRequest requestWithURL:url]];	
    self.title = @"24/7 Outreach Center";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


@end
