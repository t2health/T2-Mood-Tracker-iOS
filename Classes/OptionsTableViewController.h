//
//  OptionsTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 7/9/12.
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


@interface OptionsTableViewController : UITableViewController <UINavigationControllerDelegate, SafeFetchedResultsControllerDelegate>
{
    SafeFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    NSArray *dataSourceArray;
    UINavigationController *myNavController;
    NSString *whichGraph;
    UISwitch *legendSwitch;
    UISwitch *symbolSwitch;
    UISwitch *gradientSwitch;
}

@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) UINavigationController *myNavController;
@property (nonatomic, retain) UISwitch *legendSwitch;
@property (nonatomic, retain) UISwitch *symbolSwitch;
@property (nonatomic, retain) UISwitch *gradientSwitch;
@property (nonatomic, retain) NSString *whichGraph;


- (void)legendToggle;
- (void)symbolToggle;
- (void)gradientToggle;

@end
