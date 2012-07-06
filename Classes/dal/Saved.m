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