//
//  ClearDataViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/7/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Group;

@interface ClearDataViewController : UIViewController <SafeFetchedResultsControllerDelegate, UITableViewDelegate, UIAlertViewDelegate>{
	SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;

	IBOutlet UITableView *groupTableView;
	
	Group *currentGroup;
	BOOL deleteNotesChosen;
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Group *currentGroup;
@property (nonatomic, assign) BOOL deleteNotesChosen;

- (void)deleteResultsForGroup:(Group *)group;
- (void)deleteNotes;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)getNumberOfNotes;
@end
