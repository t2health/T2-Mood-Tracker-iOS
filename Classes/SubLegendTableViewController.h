//
//  SubLegendTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 7/17/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"

@class Group;
@class Scale;

@interface SubLegendTableViewController : UITableViewController <SafeFetchedResultsControllerDelegate>
{
    SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    NSArray*	mList;
	NSMutableDictionary *groupsDictionary;
    NSArray *groupsArray;
    NSMutableDictionary *scalesDictionary;
    NSArray *scalesArray;
    NSString *groupName;
    
}

@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) NSMutableDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) NSString *groupName;

@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)fillGroupsDictionary;
- (void)fillScalesDictionary;

- (void)refresh;
- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color;
@end
