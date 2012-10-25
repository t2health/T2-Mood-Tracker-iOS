//
//  SubLegendTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 7/17/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//
/*
 *
 * T2 Mood Tracker
 *
 * Copyright © 2009-2012 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright © 2009-2012 Contributors. All Rights Reserved.
 *
 * THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
 * REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
 * COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
 * AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
 * THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
 * INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
 * REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
 * DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
 * HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
 * RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: T2MoodTracker002
 * Government Agency Original Software Title: T2 Mood Tracker
 * User Registration Requested. Please send email
 * with your contact information to: robert.kayl2@us.army.mil
 * Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
 *
 */
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
