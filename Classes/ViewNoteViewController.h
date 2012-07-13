//
//  ViewNoteViewController.h
//  VAS002
//
//  Created by Hasan Edain on 3/1/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface ViewNoteViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate> {
	Note *note;
	IBOutlet UITextView *noteView;
	IBOutlet UILabel *dateLabel;
    UITableViewController *notesController;
    NSString *prevNote;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) UITextView *noteView;
@property (nonatomic, retain) UITableViewController *notesController;
@property (nonatomic, retain) NSString *prevNote;

- (void)save:(id)sender;
- (void)save;
- (void)cancel;

@end
