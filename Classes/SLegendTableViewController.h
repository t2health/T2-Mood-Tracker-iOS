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

@interface SLegendTableViewController : UITableViewController <SafeFetchedResultsControllerDelegate>
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
- (void)setGroupName:(NSString *)grpName;

- (void)refresh;
- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color;
@end
