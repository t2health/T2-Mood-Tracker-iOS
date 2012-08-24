//
//  SavedResultsController.h
//  VAS002
//
//  Created by Melvin Manzano on 3/22/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SafeFetchedResultsController.h"
#import "Saved.h"


@class MailData;
@interface SavedResultsController : UIViewController <SafeFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIActionSheetDelegate>
{
    
    SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	IBOutlet UITableView *resultsTableView;
    Saved *selectedIndex;

}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Saved *selectedIndex;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)displayComposerSheetWithMailData:(MailData *)data;
- (void)launchMailAppOnDeviceWithMailData:(MailData *)data;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
- (void)emailResults;
- (void)sendMail:(MailData *)data;
- (void)handleGesture:(UILongPressGestureRecognizer *)recognizer;

@end
