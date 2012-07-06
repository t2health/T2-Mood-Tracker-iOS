//
//  SecurityViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "SecurityViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"

@implementation SecurityViewController

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
	
	self.title = @"Security";
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pinString = [defaults valueForKey:SECURITY_PIN_SETTING];
	if (![pinString isEqual:@""]) {
		pinField.text = pinString;
	}
	
	NSString *question1String = [defaults valueForKey:SECURITY_QUESTION1_SETTING];
	if (![question1String isEqual:@""]) {
		question1Field.text = question1String;
	}

	NSString *answer1String = [defaults valueForKey:SECURITY_ANSWER1_SETTING];
	if (![answer1String isEqual:@""]) {
		answer1Field.text = answer1String;
	}
	
	NSString *question2String = [defaults valueForKey:SECURITY_QUESTION2_SETTING];
	if (![question2String isEqual:@""]) {
		question2Field.text = question2String;
	}
	
	NSString *answer2String = [defaults valueForKey:SECURITY_ANSWER2_SETTING];
	if (![answer2String isEqual:@""]) {
		answer2Field.text = answer2String;
	}
	
	NSInteger sWidth = self.view.frame.size.width;
	NSInteger sHeight = 130 + helpTextView.frame.origin.y + helpTextView.frame.size.height;
	
	CGSize size = CGSizeMake(sWidth, sHeight);
	scrollView.contentSize = size;
	
	[FlurryUtility report:EVENT_SECURITY_ACTIVITY_SETPASSWORD];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSInteger sWidth = self.view.frame.size.width;
	NSInteger sHeight = 130 + helpTextView.frame.origin.y + helpTextView.frame.size.height;
	
	CGSize size = CGSizeMake(sWidth, sHeight);
	scrollView.contentSize = size;
	[scrollView setNeedsDisplay];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return YES;
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	if(textField == pinField) {
		[pinField resignFirstResponder];
		CGRect fieldFrame = [question1Field frame];
		CGPoint fieldTop = CGPointMake(0, fieldFrame.origin.y - 4);
		[scrollView setContentOffset:fieldTop];
		[question1Field becomeFirstResponder];
	}
	else if(textField == question1Field) {
		[question1Field resignFirstResponder];
		[answer1Field becomeFirstResponder];
	}
	else if(textField == answer1Field) {
		[answer1Field resignFirstResponder];
		CGRect fieldFrame = [question2Field frame];
		CGPoint fieldTop = CGPointMake(0, fieldFrame.origin.y - 4);
		[scrollView setContentOffset:fieldTop];
		[question2Field becomeFirstResponder];
	}
	else if(textField == question2Field) {
		[question2Field resignFirstResponder];
		[answer2Field becomeFirstResponder];
	}
	else if(textField == answer2Field) {
		CGRect fieldFrame = [pinField frame];
		CGPoint fieldTop = CGPointMake(0, fieldFrame.origin.y - 4);
		[scrollView setContentOffset:fieldTop];
		[answer2Field resignFirstResponder];
	}
	
	return YES;	
}

- (IBAction)onValueChange:(id)sender {
	if (sender == pinField) {
		if ([pinField.text intValue] >= 1 && [pinField.text length] ==6) {
			[pinField resignFirstResponder];
			[question1Field becomeFirstResponder];
		}
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:pinField.text forKey:SECURITY_PIN_SETTING];
	[defaults setValue:question1Field.text forKey:SECURITY_QUESTION1_SETTING];
	[defaults setValue:answer1Field.text forKey:SECURITY_ANSWER1_SETTING];
	[defaults setValue:question2Field.text forKey:SECURITY_QUESTION2_SETTING];
	[defaults setValue:answer2Field.text forKey:SECURITY_ANSWER2_SETTING];
	[defaults synchronize];
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