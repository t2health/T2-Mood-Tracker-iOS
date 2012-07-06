//
//  DatePickerController.h
//  VAS002
//
//  Created by Melvin Manzano on 5/1/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerController : UIViewController
{
    IBOutlet UIDatePicker *datePicker;
}

- (IBAction)dateAction:(id)sender;
@end
