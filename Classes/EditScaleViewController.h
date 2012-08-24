//
//  EditScaleViewController.h
//  VAS002
//
//  Created by Hasan Edain on 2/17/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Scale;

@interface EditScaleViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, SafeFetchedResultsControllerDelegate> {
	NSManagedObjectContext *managedObjectContext;
    SafeFetchedResultsController *fetchedResultsController;
    NSMutableDictionary *switchDictionary;
	NSMutableDictionary *groupsDictionary;
	NSString *groupName;
	IBOutlet UITableView *tableView;
    
	IBOutlet UITextField *leftTextField;
	IBOutlet UITextField *rightTextField;
	Scale *scale;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *groupName;

@property (nonatomic, retain) IBOutlet UITextField *leftTextField;
@property (nonatomic, retain) IBOutlet UITextField *rightTextField;
@property (nonatomic, retain)Scale *scale;

- (void)save:(id)sender;
- (void)addLegendInfo;
- (NSFetchedResultsController *)fetchedResultsController;

@end
