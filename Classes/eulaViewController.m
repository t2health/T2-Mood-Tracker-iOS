//
//  eulaViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 10/4/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "eulaViewController.h"

@interface eulaViewController ()

@end

@implementation eulaViewController

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
    
    self.title = @"END USER LICENSE AGREEMENT";
    self.navigationItem.hidesBackButton = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)acceptClick:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"EULA"];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
