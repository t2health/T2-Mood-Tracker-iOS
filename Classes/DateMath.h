//
//  DateMath.h
//  VAS002
//
//  Created by Hasan Edain on 1/17/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Group;

@interface DateMath : NSObject {

}

+ (NSDictionary	*)getReminderDates;
+ (NSArray *)remindersDueForGroups;
+ (NSDate *)getLastReminderDate;
+ (NSUInteger)numberOfRecordsForMonth:(NSInteger)month;
+ (NSString *)monthNameFrom:(NSInteger)monthNumber;
+ (NSString *)shortMonthNameFrom:(NSInteger)monthNumber;
+ (NSArray *) getRatableGroups;
+ (NSArray *) getRatableGroupsWithoutData;

@end
