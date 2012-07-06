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

@synthesize note;
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

- (void)save:(id)sender {
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (void)dealloc {
	[self.note release];
	[self.noteView release];
    
	[super dealloc];
}


@end
