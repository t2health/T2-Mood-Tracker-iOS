//
//  ViewNoteViewController.m
//  VAS002
//
//  Created by Hasan Edain on 3/1/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ViewNoteViewController.h"
#import "Note.h"
#import "VAS002AppDelegate.h"
#import "Error.h"
#import <CoreData/CoreData.h>
#import "NotesTableViewController.h"

@implementation ViewNoteViewController

@synthesize note,prevNote;
@synthesize noteView, notesController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"View Note";
	
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:note.noteDate];
	
	dateLabel.text = dateString;
	noteView.text = note.note;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
    
    self.prevNote = noteView.text;
    
    NSLog(@"prevNote: %@", prevNote);
    NSLog(@"noteView.text: %@", noteView.text);
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[self.navigationController viewControllers] containsObject:self]) 
    {
        NSLog(@"back button pressed");
        
        [notesController.tableView reloadData];
    }
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

- (void)cancel
{
    NSLog(@"prevNote: %@", prevNote);
    NSLog(@"noteView.text: %@", noteView.text);
    if (![prevNote isEqualToString:noteView.text]) 
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
    NSString *newNote = noteView.text;
	if (![newNote isEqual:@""]) {
		if (![newNote isEqual:note.note]) {
			VAS002AppDelegate *delegate = (VAS002AppDelegate *)[UIApplication sharedApplication].delegate;
			NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
			note.note = newNote;
			
			NSError *error;
			if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				[Error showErrorByAppendingString:@"Unable to save Note" withError:error];
			} 
		}
	}	
	[self.navigationController popViewControllerAnimated:YES];
    
}

- (void)save:(id)sender 
{
    [self save];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (void)dealloc {
	[note release];
	[noteView release];
    
	[super dealloc];
}


@end
