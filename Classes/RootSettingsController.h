//
//  RootSettingsController.h
//  VAS002
//
//  Created by Melvin Manzano on 4/3/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SafeFetchedResultsController.h"


@class MailData;
@class Group;

@interface RootSettingsController : UIViewController  <SafeFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate> {
	SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	NSArray *reminderArray;
	IBOutlet UITableView *tableView;
	IBOutlet UIButton *noteButton;
    
    
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSArray *reminderArray;

@property (nonatomic, retain) IBOutlet UITableView *tableView;


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

@end

