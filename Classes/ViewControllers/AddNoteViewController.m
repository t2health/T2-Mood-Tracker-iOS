//
//  AddNoteViewController.m
//  VAS002
//
//  Created by Hasan Edain on 12/20/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "VAS002AppDelegate.h"
#import "AddNoteViewController.h"
#import "VAS002AppDelegate.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Error.h"
#import "DatePickerController.h"

@implementation AddNoteViewController

@synthesize dateLabel;
@synthesize noteTextView;
@synthesize timeStamp;
@synthesize noteDate, pickerContainer, pickerButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	for (UIView* subview in datePicker.subviews) {
		subview.frame = datePicker.bounds;
	}
	
	[FlurryUtility report:EVENT_ADD_EDIT_NOTE_ACTIVITY];
	
	self.title = @"Add a note";
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    
    [self deviceOrientationChanged:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *landTrigger =  [prefs stringForKey:@"landscapeDateTrigger"];
    NSDate *date;
    
    
    if ([landTrigger isEqualToString:@"1"]) 
    {
        NSString *myDateString = [prefs stringForKey:@"landscapeDate"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
        date = [dateFormat dateFromString:myDateString];
        [dateLabel setText:myDateString];
        datePicker.date = date;
        [dateFormat release];
        
        self.noteDate = date;
        [prefs setObject:@"0" forKey:@"landscapeDateTrigger"];
        
    }
    else 
    {
        NSDate *today = [NSDate date];
        
        if (self.noteDate == NULL) {
            date = [NSDate dateWithTimeIntervalSinceNow:0];        
        }
        else {
            date = self.noteDate;
        }
        
        self.timeStamp = today;
        self.noteDate = date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [dateFormat stringFromDate:date];
        [dateLabel setText:dateString];
        datePicker.date = noteDate;
        [dateFormat release];
        
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        //    NSLog(@"Ummm.");
        
    } 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"button press: %i", buttonIndex);
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        [self save];
    } 
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    } 
}

- (IBAction)cancelNoteClicked:(id)sender
{
    // UIApplication *app = [UIApplication sharedApplication];
	//VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
    [noteTextView resignFirstResponder];
    // [appDelegate cancelNote];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (IBAction)editDate:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:dateLabel.text forKey:@"landscapeDate"];
    
    NSLog(@"date: %@", dateLabel.text);
    DatePickerController *datePickerController = [[DatePickerController alloc] initWithNibName:@"DatePickerController" bundle:nil];
    [self.navigationController pushViewController:datePickerController animated:YES];
    [datePickerController release];
}

- (void)savedNote
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
    if (![noteTextView.text isEqualToString:@""]) 
    {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                       initWithTitle:@"" 
                                       delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                       destructiveButtonTitle:nil 
                                       otherButtonTitles:@"Save Note", @"Don't Save Note", nil] autorelease];
        [actionSheet showInView:self.view];          
    }
    else 
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)save
{
    VAS002AppDelegate *delegate = (VAS002AppDelegate *)[UIApplication sharedApplication].delegate;
	NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
	NSManagedObject *note = nil;
	
	note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
	
	NSString *noteText = self.noteTextView.text;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit + NSYearCalendarUnit + NSDayCalendarUnit fromDate:self.noteDate];
	NSInteger month = [monthComponents month];
	NSInteger year = [monthComponents year];
	NSInteger day = [monthComponents day];
	
	NSString *monthString = [NSString stringWithFormat:@"%d %02d",year, month];
	[gregorian release];
	NSLog(@"notedate: %@", noteDate);
	
	[note setValue:noteText forKey: @"note"];
	[note setValue:self.noteDate forKey: @"noteDate"];
	[note setValue:self.timeStamp forKey: @"timestamp"];
	[note setValue:monthString forKey:@"monthString"];
	[note setValue:[NSNumber numberWithInt:day] forKey:@"noteDay"];
	[note setValue:[NSNumber numberWithInt:month] forKey:@"noteMonth"];
	[note setValue:[NSNumber numberWithInt:year] forKey:@"noteYear"];
	
	NSError *error = nil;
	if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save Note" withError:error];
	} 	
    
    NSDictionary *userDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:[monthComponents year]], @"chartYear",
                                    [NSNumber numberWithInt:[monthComponents month]], @"chartMonth", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"scaleMonthChanged" object:self userInfo:userDictionary];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"subScaleMonthChanged" object:self userInfo:userDictionary];
    
	[FlurryUtility report:EVENT_NOTEADDED_ACTIVITY];
	
	[self savedNote];
}

- (IBAction)save:(id)sender 
{
    [self save];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//return YES;
    
    BOOL shouldRotate = NO;	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		shouldRotate = YES;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		shouldRotate = YES;
        
	}
	
	return shouldRotate;
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
    
	UIDevice *device = [UIDevice currentDevice];
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
        pickerContainer.hidden = NO;
        pickerButton.hidden = YES;
		
        
	}
	else if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
        pickerContainer.hidden = YES;
        pickerButton.hidden = NO;
        
	}
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
	self.noteTextView = nil;
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[self.noteTextView resignFirstResponder];
	return YES;	
}

#pragma mark Date Picker
-(IBAction)dateAction:(id)sender {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	self.noteDate = datePicker.date;
	self.dateLabel.text = [dateFormatter stringFromDate:datePicker.date];
	[dateFormatter release];
}

#pragma mark Memory
- (void)dealloc {
	[dateLabel release];
	[noteTextView release];
	
    [timeStamp release];
	[noteDate release];
	
	[super dealloc];
}

@end