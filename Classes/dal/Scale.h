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

@class Group;
@class Result;

@interface Scale :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * minLabel;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * maxLabel;
@property (nonatomic, retain) Group * group;
@property (nonatomic, retain) NSSet* result;
@property (nonatomic, retain) NSNumber *index;

@end


@interface Scale (CoreDataGeneratedAccessors)
- (void)addResultObject:(Result *)value;
- (void)removeResultObject:(Result *)value;
- (void)addResult:(NSSet *)value;
- (void)removeResult:(NSSet *)value;

- (void)addGroupObject:(Group *)value;
- (void)removeGroupObject:(Group *)value;
- (void)addGroup:(NSSet *)value;
- (void)removeGroup:(NSSet *)value;

@end

