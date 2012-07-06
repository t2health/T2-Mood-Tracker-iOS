//
//  NotesTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 6/20/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"
#import "AddNoteViewController.h"

@interface NotesTableViewController : UITableViewController <SafeFetchedResultsControllerDelegate, UINavigationControllerDelegate>
{
    SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    AddNoteViewController *addNoteViewController; 
	IBOutlet UITableView *notesTableView;
    UINavigationController *myNavController;

}
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) UINavigationController *myNavController;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)refresh;
- (void)deviceOrientationChanged:(NSNotification *)notification; 

@end
