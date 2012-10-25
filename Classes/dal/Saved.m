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
//  Saved.m
//  VAS002
//
//  Created by Melvin Manzano on 3/27/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "Saved.h"

@implementation Saved

@dynamic title;
@dynamic timestamp;
@dynamic filename;
@dynamic sectionIdentifier;
@dynamic primitiveSectionIdentifier;
@dynamic savedDate;
@dynamic primitiveSavedDate;


#pragma mark Transient properties

- (NSString *)sectionIdentifier {
    
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp) {
        /*
         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        
        NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[self savedDate]];
        tmp = [NSString stringWithFormat:@"%d", ([components year] * 1000) + [components month]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}

#pragma mark Time stamp setter

- (void)setNoteDate:(NSDate *)newDate {
    
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"savedDate"];
    [self setPrimitiveSavedDate:newDate];
    [self didChangeValueForKey:@"savedDate"];
    
    [self setPrimitiveSectionIdentifier:nil];
}

#pragma mark Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"savedDate"];
}

@end