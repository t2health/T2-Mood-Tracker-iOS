//
//  DatePickerController.m
//  VAS002
//
//  Created by Melvin Manzano on 5/1/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "DatePickerController.h"

@interface DatePickerController ()

@end

@implementation DatePickerController

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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myDateString = [prefs stringForKey:@"landscapeDate"];

	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [dateFormat dateFromString:myDateString];
    NSLog(@"date2: %@", myDateString);
	datePicker.date = date;
	[dateFormat release];
    
}

- (IBAction)dateAction:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:datePicker.date];
    
    [prefs setObject:dateString forKey:@"landscapeDate"];
    [prefs setObject:@"1" forKey:@"landscapeDateTrigger"];
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

@end
