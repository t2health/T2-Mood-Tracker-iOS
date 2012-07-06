//
//  SecurityViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//


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
