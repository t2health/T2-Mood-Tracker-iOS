//
//  EditGroupViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/14/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"
@class Group;

@interface EditGroupViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, SafeFetchedResultsControllerDelegate>{	
	NSManagedObjectContext *managedObjctContext;
    SafeFetchedResultsController *fetchedResultsController;
	IBOutlet UITextField *groupTextField;
	IBOutlet UIButton *deleteGroup;
	IBOutlet UIButton *manageScalesButton;
	IBOutlet UISwitch *isPositveSwitch;
    
    IBOutlet UITableView *scalesTableView;	
	
	Group *group;
}

@property (nonatomic, retain)NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain)Group *group;
@property (nonatomic, retain) IBOutlet UITableView *scalesTableView;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;

- (IBAction)deleteGroupPressed:(id)sender;
- (IBAction)manageScalesPressed:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)saveAction:(id)sender;
- (void)addGroup;
- (void)saveEdit;
- (NSNumber *)getNextMenuIndex;
- (IBAction)switchFlipped:(id)sender;

@end
