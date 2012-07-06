//
//  NumberPadReturn.m
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "NumberPadReturn.h"


@implementation UIViewController (NumPadReturn)

-(void) viewDidLoad{
    // add observer for the respective notifications (depending on the os version)
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardDidShow:) 
                                                     name:UIKeyboardDidShowNotification 
                                                   object:nil];     
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
    }
	
}


- (void)keyboardWillShow:(NSNotification *)note {
    // if clause is just an additional precaution, you could also dismiss it
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
        [self addButtonToKeyboard];
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
    // if clause is just an additional precaution, you could also dismiss it
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
        [self addButtonToKeyboard];
    }
}

- (void)addButtonToKeyboard {
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
        [doneButton setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
    } else {        
        [doneButton setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
    }
    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard found, add the button
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:doneButton];
        }
    }
}

- (void)doneButton:(id)sender {
    NSLog(@"doneButton");
    [self.view endEditing:TRUE];
}



@end