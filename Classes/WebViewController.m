//
//  WebViewControllerViewController.m
//  VAS002
//
//  Created by Roger Reeder on 7/31/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView;

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
    
    [self loadPDFFile];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadPDFFile
    {
        NSArray *arrayPaths = 
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"test.pdf"];
        NSURL *url = [NSURL fileURLWithPath:path];
#if TARGET_IPHONE_SIMULATOR
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
#else    
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        [docController retain];
        BOOL isValid= [docController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
#endif
    }
     
@end
