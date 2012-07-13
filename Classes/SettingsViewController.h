//
//  SettingsViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//
#import "AddNoteViewController.h"


@interface SettingsViewController : UIViewController <UITableViewDelegate> {
	IBOutlet UITableView *menuTableView;
    AddNoteViewController *addNoteViewController; 
}

- (IBAction)securityButtonClicked:(id)sender;
- (IBAction)clearDataButtonClicked:(id)sender;
- (IBAction)reminderButtonClicked:(id)sender;
- (IBAction)areasButtonClicked:(id)sender;
- (IBAction)improveApplicationButtonClicked:(id)sender;
- (IBAction)optionsButtonClicked:(id)sender;

- (void)switchFlipped:(id)sender;
- (void)addNoteClicked:(id)sender;

- (void)chkPin;
- (void)rsnPin;

@end
