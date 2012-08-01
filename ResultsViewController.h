//
//  ResultsViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 3/20/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

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
