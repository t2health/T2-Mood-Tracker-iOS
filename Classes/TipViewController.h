//
//  TipViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/20/11.
//  Copyright 2011 GDIT. All rights reserved.
//

@interface TipViewController : UIViewController {
	IBOutlet UITextView *tipView;
	IBOutlet UISwitch *showTipSwitch;
}

- (IBAction)showTipSwitchFlipped;
- (IBAction)closeTipsPressed;

@end
