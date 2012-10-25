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

#import <CoreData/CoreData.h>

@protocol SafeFetchedResultsControllerDelegate;


@interface SafeFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate>
{
	id <SafeFetchedResultsControllerDelegate> safeDelegate;
    id s_myViewDelegate;
	
	NSMutableArray *insertedSections;
	NSMutableArray *deletedSections;
	
	NSMutableArray *insertedObjects;
	NSMutableArray *deletedObjects;
	NSMutableArray *updatedObjects;
	NSMutableArray *movedObjects;
}

@property (nonatomic, assign) id <SafeFetchedResultsControllerDelegate> safeDelegate;

@end

@protocol SafeFetchedResultsControllerDelegate <NSFetchedResultsControllerDelegate, NSObject>
@optional

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller;

@end