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
//
//  RootViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/20/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SafeFetchedResultsController.h"
#import "AddNoteViewController.h"


@class MailData;
@class Group;

@interface RootViewController : UIViewController  <SafeFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate> {
	SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	NSArray *reminderArray;
	IBOutlet UITableView *tableView;
	IBOutlet UIButton *noteButton;
    AddNoteViewController *addNoteViewController; 
    IBOutlet UIView *addView;
    
    NSMutableDictionary *colorsDictionary;
    NSMutableDictionary *symbolsDictionary;
    NSDictionary *groupsDictionary;
    
    NSMutableDictionary *colorsSubDictionary;
    NSMutableDictionary *symbolsSubDictionary;
    NSDictionary *scalesDictionary;
    NSArray *scalesArray;
    
    NSDictionary *colorsTempDictionary;
    NSDictionary *symbolsTempDictionary;
    NSDictionary *colorsSubTempDictionary;
    NSDictionary *symbolsSubTempDictionary;
    
    
    
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSArray *reminderArray;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *addView;

@property (nonatomic, retain) NSMutableDictionary *colorsDictionary;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSDictionary *colorsTempDictionary;
@property (nonatomic, retain) NSDictionary *symbolsTempDictionary;
@property (nonatomic, retain) NSDictionary *groupsDictionary;

@property (nonatomic, retain) NSMutableDictionary *colorsSubDictionary;
@property (nonatomic, retain) NSMutableDictionary *symbolsSubDictionary;
@property (nonatomic, retain) NSDictionary *colorsSubTempDictionary;
@property (nonatomic, retain) NSDictionary *symbolsSubTempDictionary;
@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;


#define SECTION_NAME_RATE		@"Rate"
#define SECTION_NAME_RESULTS	@"Results"
#define SECTION_NAME_OTHER		@"Other"

- (void)addNoteClicked:(id)sender;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)sendFeedback;
- (void)tellAFriend;

- (void)sendMail:(MailData *)mailData;
- (void)displayComposerSheetWithMailData:(MailData *)data;
- (void)launchMailAppOnDeviceWithMailData:(MailData *)data;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;


- (void)createData;
- (void)createRatings;
- (void)createNotes;

- (NSArray *)scalesForGroup:(Group *)group;
- (void)handleUnusualEntryNotification:(id)sender;
- (IBAction)areasButtonClicked:(id)sender;

- (void)fillGroupsDictionary;
- (void)fillColors;
- (void)fillSymbols;

- (NSDictionary *)fillScalesDictionary:(NSString *)groupName:(int)scaleType;
- (void)fillSubColors;
- (void)fillSubSymbols;

- (void)chkPin;
- (void)rsnPin;

@end
