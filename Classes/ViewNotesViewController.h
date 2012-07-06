//
//  ViewNotesViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"
#import "AddNoteViewController.h"

@interface ViewNotesViewController : UIViewController <SafeFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    AddNoteViewController *addNoteViewController; 
	IBOutlet UITableView *notesTableView;
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
