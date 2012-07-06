//
//  ManageScalesViewController.h
//  VAS002
//
//  Created by Hasan Edain on 2/16/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Group;

@interface ManageScalesViewController : UITableViewController<SafeFetchedResultsControllerDelegate> {
	SafeFetchedResultsController *fetchedResultsController;
	
	IBOutlet UITableView *scalesTableView;		
	Group *group;
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *scalesTableView;
@property (nonatomic, retain)Group *group;


- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
