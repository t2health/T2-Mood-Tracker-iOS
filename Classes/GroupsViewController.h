//
//  GroupsViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/14/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Group;

@interface GroupsViewController : UIViewController <SafeFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDelegate>{
	NSManagedObjectContext *managedObjectContext;
	SafeFetchedResultsController *fetchedResultsController;
	
	NSMutableDictionary *switchDictionary;
	NSMutableDictionary *groupsDictionary;
	
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addGroup:(id)sender;
- (void)editGroup:(Group *)group;
- (void)fillGroupsDictionary;
- (void)createSwitches;
- (void)addSwitchForGroup:(Group *)group;
- (NSInteger) numberSwitchesOn;

@end
