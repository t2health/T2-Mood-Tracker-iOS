//
//  PasswordViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "PasswordViewController.h"
#import "SecurityViewController.h"
#import "VAS002AppDelegate.h"
#import "Tip.h"
#import "Error.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"

@implementation PasswordViewController

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

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
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
	}
	else {
		tipView.text = @"Unable to fetch tip.";
		[Error showErrorByAppendingString:@"Unable to fetch a Tip" withError:error];
	}
	
	[fetch release];
	[FlurryUtility report:EVENT_SECURITY_ACTIVITY_LOGIN];
}

- (IBAction)showtipSwitchFliped {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:showTipSwitch.on forKey:@"SHOW_TIPS_ON_STARTUP"];
	[defaults synchronize];	
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

-(IBAction)pinResetClicked:(id)sender {
	tipView.hidden = YES;
	showTipLabel.hidden = YES;
	showTipSwitch.hidden = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *question1String = [defaults valueForKey:SECURITY_QUESTION1_SETTING];
	question1Label.text = [NSString stringWithFormat:@"Question: %@", question1String];
	question1Label.hidden = NO;

	answer1Field.hidden = NO;
	answer1Field.userInteractionEnabled = YES;

	NSString *question2String = [defaults valueForKey:SECURITY_QUESTION2_SETTING];
	question2Label.text = [NSString stringWithFormat:@"Question: %@", question2String];
	question2Label.hidden = NO;
	
	answer2Field.hidden = NO;
	answer2Field.userInteractionEnabled = YES;

	warningLabel.hidden = NO;
	
	CGRect question1Frame = [question1Label frame];
	CGPoint offsetPoint = CGPointMake(0, question1Frame.origin.y - 4);
	[scrollView setContentOffset:offsetPoint];
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	if(textField == pinField) {
		[pinField resignFirstResponder];
	}
	else if(textField == answer1Field) {
		[answer1Field resignFirstResponder];
		[answer2Field becomeFirstResponder];
		CGRect question2Frame = [question2Label frame];
		CGPoint offsetPoint = CGPointMake(0, question2Frame.origin.y - 4);
		[scrollView setContentOffset:offsetPoint];
		[self tryReset];
	}
	else if(textField == answer2Field) {
		[answer2Field resignFirstResponder];
		[self tryReset];
	}
	
	return YES;	
}

-(void)tryReset {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *answer1String = [defaults valueForKey:SECURITY_ANSWER1_SETTING];
	NSString *answer2String = [defaults valueForKey:SECURITY_ANSWER2_SETTING];
	NSString *guess1 = answer1Field.text;
	NSString *guess2 = answer2Field.text;
	
	if ([answer1String isEqual:guess1] && [answer2String isEqual:guess2]) {
		[defaults setValue:@"" forKey:SECURITY_PIN_SETTING];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignPin" object: nil];

//		UIApplication *app = [UIApplication sharedApplication];

//		VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
//		[appDelegate.navigationController setNavigationBarHidden:NO];
//		[appDelegate.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)onValueChange:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (sender == pinField) {
		NSString *pinString = [defaults valueForKey:SECURITY_PIN_SETTING];

		if ([pinField.text isEqual:pinString]) {
			[pinField resignFirstResponder];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignPin" object: nil];
            
            /*
			UIApplication *app = [UIApplication sharedApplication];
			VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
			[appDelegate.navigationController setNavigationBarHidden:NO];
			[appDelegate.navigationController popViewControllerAnimated:YES];
            appDelegate.tabBarController.tabBar.hidden = NO;  
             */

		}
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
