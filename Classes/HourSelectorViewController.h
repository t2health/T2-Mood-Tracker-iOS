//
//  HourSelectorViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/13/11.
//  Copyright 2011 GDIT. All rights reserved.
//

@interface HourSelectorViewController : UIViewController {
	NSInteger section;
	IBOutlet UIDatePicker *hourPicker;
}

@property (nonatomic, assign)NSInteger section;

- (IBAction)hourSelected:(id)sender;

@end
