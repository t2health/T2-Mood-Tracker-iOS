//
//  ErrorViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/21/11.
//  Copyright 2011 GDIT. All rights reserved.
//

@interface ErrorViewController : UIViewController {
	IBOutlet UITextView *textView;
}

- (void)addStringToMessage:(NSString *)string;

- (IBAction)okClicked:(id)sender;

@end
