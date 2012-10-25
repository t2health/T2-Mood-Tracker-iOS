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
//
//  Group.h
//  VAS002
//
//  Created by Roger Reeder on 11/12/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Result;
@class Scale;
@class Section;
@class GroupResult;

@interface Group :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *section;
@property (nonatomic, retain) NSString *groupDescription;
@property (nonatomic, retain) NSNumber *visible;
@property (nonatomic, retain) NSNumber *rateable;
@property (nonatomic, retain) NSNumber *showGraph;
@property (nonatomic, retain) NSNumber *immutable;
@property (nonatomic, retain) NSNumber *menuIndex;
@property (nonatomic, retain) NSNumber *positiveDescription;
@property (nonatomic, retain) NSSet *result;
@property (nonatomic, retain) NSSet *groupResult;
@property (nonatomic, retain) NSSet *scale;

@end


@interface Group (CoreDataGeneratedAccessors)
- (void)addResultObject:(Result *)value;
- (void)removeResultObject:(Result *)value;
- (void)addResult:(NSSet *)value;
- (void)removeResult:(NSSet *)value;

- (void)addGroupResultObject:(GroupResult *)value;
- (void)removeGroupResultObject:(GroupResult *)value;
- (void)addGroupResult:(NSSet *)value;
- (void)removeGroupResult:(NSSet *)value;

- (void)addScaleObject:(Scale *)value;
- (void)removeScaleObject:(Scale *)value;
- (void)addScale:(NSSet *)value;
- (void)removeScale:(NSSet *)value;
@end

