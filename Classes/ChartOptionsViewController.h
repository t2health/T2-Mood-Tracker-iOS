//
//  ChartOptionsViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 5/24/12.
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

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"
#import "HRColorPickerViewController.h"


@class Group;

@interface ChartOptionsViewController : UIViewController <SafeFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, HRColorPickerViewControllerDelegate>
{
	NSManagedObjectContext *managedObjectContext;
	SafeFetchedResultsController *fetchedResultsController;
	
	NSMutableDictionary *switchDictionary;
	NSMutableDictionary *groupsDictionary;
    IBOutlet UIView *pickerView;
    IBOutlet UIView *colorPicker;
    IBOutlet UIView *symbolPicker;
    NSMutableDictionary *userSettingsDictionary;
	
	IBOutlet UITableView *_tableView;
    
    NSMutableDictionary *symbolsDictionary;
    NSMutableDictionary *colorsDictionary;
    
    NSString *editGroupName;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) NSMutableDictionary *userSettingsDictionary;
@property (nonatomic, retain) IBOutlet UIView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *colorPicker;
@property (nonatomic, retain) IBOutlet UIView *symbolPicker;

@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSMutableDictionary *colorsDictionary;

@property (nonatomic, retain) NSString *editGroupName;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)editColor;
- (void)editSymbol;
- (void)fillGroupsDictionary;
- (void)fillColors;
- (void)fillSymbols;

- (void)openPicker:(UIColor *)withColor;
- (void)refreshTable;
- (void)cancelEdit;

- (void)addSwitchForGroup:(Group *)group;
- (NSInteger) numberSwitchesOn;
- (IBAction)doneClick:(id)sender;

- (void)checkButtonTapped:(id)sender event:(id)event;
- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color;


@end
