//
//  ResultsViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 3/20/12.
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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SafeFetchedResultsController.h"
#import "PDFService.h"


@class MailData;
@class Group;

@interface ResultsViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, PDFServiceDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    UITextField *fromField;
    UITextField *toField;
    IBOutlet UITableView *tableView;
    NSMutableDictionary *ledgendColorsDictionary;
    NSDictionary *groupsDictionary;
    NSInteger chartYear;
    NSInteger chartMonth;
    NSMutableDictionary *switchDictionary;
    NSDictionary *valuesArraysForMonth;
    NSArray *groupsArray;
    NSArray *dataSourceArray;
    NSMutableArray *filterViewItems;
    NSMutableArray *textfieldArray;
    NSMutableArray *groupArray;
    IBOutlet UIView *savingScreen;
    IBOutlet UIView *datePickView;
    IBOutlet UIDatePicker *datePicker;
    UIBarButtonItem *doneButton;	// this button appears only when the date picker is open
	
	NSArray *dataArray;
	
	NSDateFormatter *dateFormatter;
    NSString *curFileName;
    
    UISwitch *noteSwitch;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextField *fromField;
@property (nonatomic, retain) IBOutlet UITextField *toField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDictionary *groupsDictionary;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, assign) NSInteger chartYear;
@property (nonatomic, assign) NSInteger chartMonth;
@property (nonatomic, retain) NSDictionary *valuesArraysForMonth;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) NSMutableArray *filterViewItems;
@property (nonatomic, retain) NSMutableArray *textfieldArray;
@property (nonatomic, retain) NSMutableArray *groupArray;
@property (nonatomic, retain) UIView *savingScreen;
@property (nonatomic, retain) UIView *datePickView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSString *curFileName;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) NSArray *dataArray; 
@property (nonatomic, retain) NSDateFormatter *dateFormatter; 
@property (nonatomic, retain) UISwitch *noteSwitch;



- (void)emailResults;

- (void)sendMail:(MailData *)mailData;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)displayComposerSheetWithMailData:(MailData *)data;
- (void)launchMailAppOnDeviceWithMailData:(MailData *)data;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

- (void)saveResults;
- (void)convertArrayToCSV:(NSArray *)valueArray:(NSArray *)withNotes;
- (void)convertArrayToPDF:(NSArray *)valueArray:(NSArray *)withNotes;
- (void)fetchFilteredResults;
- (NSArray *)fetchNotes;

- (void)createSwitches;
- (void)fillGroupsDictionary;
- (void)fillColors;
- (NSDictionary *)getValueDictionaryForMonth;

- (void)slideDownDidStop;

- (void)resignPicker;
- (void)createPDF;
- (void) showPDF;

- (void)deviceOrientationChanged:(NSNotification *)notification;


@end
