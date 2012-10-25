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
