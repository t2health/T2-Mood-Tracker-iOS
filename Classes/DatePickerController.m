//
//  DatePickerController.m
//  VAS002
//
//  Created by Melvin Manzano on 5/1/12.
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
