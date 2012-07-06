//
//  LegendTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 6/8/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Group;

@interface LegendTableViewController : UITableViewController <SafeFetchedResultsControllerDelegate>
{
    SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    NSArray*	mList;
	NSMutableDictionary *groupsDictionary;
    NSArray *groupsArray;
    
}

@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)fillGroupsDictionary;
- (void)refresh;
- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color;
@end
