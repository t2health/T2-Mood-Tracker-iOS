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

@interface SecurityViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UITextField *pinField;
	IBOutlet UITextField *question1Field;
	IBOutlet UITextField *answer1Field;
	IBOutlet UITextField *question2Field;
	IBOutlet UITextField *answer2Field;
	IBOutlet UITextView *helpTextView;
}

- (IBAction)onValueChange:(id)sender;

#define SECURITY_PIN_SETTING		@"Security_Pin_Setting"
#define SECURITY_QUESTION1_SETTING	@"Security_Question1_setting"
#define SECURITY_ANSWER1_SETTING	@"Security_Answer1_setting"
#define SECURITY_QUESTION2_SETTING	@"Security_Question2_setting"
#define SECURITY_ANSWER2_SETTING	@"Security_Answer2_setting"

@end
