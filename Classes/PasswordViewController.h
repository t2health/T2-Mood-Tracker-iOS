//
//  PasswordViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

@interface PasswordViewController : UIViewController <UITextViewDelegate>{
	IBOutlet UILabel *pinLabel;
	IBOutlet UITextField *pinField;
	IBOutlet UILabel *question1Label;
	IBOutlet UITextField *answer1Field;
	IBOutlet UILabel *question2Label;
	IBOutlet UITextField *answer2Field;
	IBOutlet UITextView *warningLabel;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UITextView *tipView;
	IBOutlet UILabel *showTipLabel;
	IBOutlet UISwitch *showTipSwitch;
}

- (IBAction)pinResetClicked:(id)sender;
- (IBAction)onValueChange:(id)sender;
- (void)tryReset;
- (IBAction)showtipSwitchFliped;

@end
