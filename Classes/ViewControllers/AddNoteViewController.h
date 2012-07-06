//
//  AddNoteViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/20/10.
//  Copyright 2010 GDIT. All rights reserved.
//

@interface AddNoteViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate> {
	IBOutlet UILabel *dateLabel;
	IBOutlet UITextView *noteTextView;
	IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *pickerContainer;
	IBOutlet UIButton *pickerButton;
	NSDate *timeStamp;
	NSDate *noteDate;
}

@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UITextView *noteTextView;
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, retain) NSDate *noteDate;
@property (nonatomic, retain) UIView *pickerContainer;
@property (nonatomic, retain) UIButton *pickerButton;


- (IBAction)cancelNoteClicked:(id)sender;
- (void)savedNote;
- (IBAction)dateAction:(id)sender;
- (IBAction)save:(id)sender;
- (void)save;
- (void)cancel;
- (IBAction)editDate:(id)sender;
- (void)deviceOrientationChanged:(NSNotification *)notification;

@end
