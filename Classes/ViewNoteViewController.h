//
//  ViewNoteViewController.h
//  VAS002
//
//  Created by Hasan Edain on 3/1/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface ViewNoteViewController : UIViewController <UITextViewDelegate> {
	Note *note;
	IBOutlet UITextView *noteView;
	IBOutlet UILabel *dateLabel;
    UITableViewController *notesController;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) UITextView *noteView;
@property (nonatomic, retain) UITableViewController *notesController;

- (void)save:(id)sender;

@end
