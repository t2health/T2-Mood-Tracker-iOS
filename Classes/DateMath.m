//
//  DateMath.m
//  VAS002
//
//  Created by Hasan Edain on 1/17/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "DateMath.h"
#import "Group.h"
#import "Result.h"
#import "VAS002AppDelegate.h"
#import "Error.h"

@implementation DateMath

+ (NSDictionary *)getReminderDates {
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]   ;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableArray *timeArray = [NSMutableArray array];
	NSMutableArray *daysArray = [NSMutableArray array];
	
	NSString *key = [NSString stringWithFormat:@"MORNING_REMINDER_STATE"];
	BOOL storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		NSDate *morningDate = [defaults valueForKey:@"MORNING_REMINDER_TIME"];
		[timeArray addObject:morningDate];
	}
	
	key = [NSString stringWithFormat:@"NOON_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		NSDate *noonDate = [defaults valueForKey:@"NOON_REMINDER_TIME"];
		[timeArray addObject:noonDate];
	}
	
	key = [NSString stringWithFormat:@"EVENING_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		NSDate *eveningDate = [defaults valueForKey:@"EVENING_REMINDER_TIME"];
		[timeArray addObject:eveningDate];
	}
	
	key = [NSString stringWithFormat:@"MONDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:2]];
	}
	
	key = [NSString stringWithFormat:@"TUESDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:3]];
	}
	
	key = [NSString stringWithFormat:@"WEDNESDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:4]];
	}
	
	key = [NSString stringWithFormat:@"THURSDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:5]];
	}
	
	key = [NSString stringWithFormat:@"FRIDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:6]];
	}
	
	key = [NSString stringWithFormat:@"SATURDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:7]];
	}
	
	key = [NSString stringWithFormat:@"SUNDAY_REMINDER_STATE"];
	storedVal = [defaults boolForKey:key];
	if (storedVal == YES) {
		[daysArray addObject:[NSNumber numberWithInt:1]];
	}
	
	NSDate *now = [NSDate date];
	NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit + NSMonthCalendarUnit + NSWeekdayOrdinalCalendarUnit fromDate:now];
	
	NSInteger nowYear = [nowComponents year];
	NSInteger nowMonth = [nowComponents month];
	NSInteger nowDayOrdinal = [nowComponents weekdayOrdinal];
	
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setYear:nowYear];
	[components setMonth:nowMonth];
	[components setWeekdayOrdinal:nowDayOrdinal];
	NSDate *alarmDate;
	
	NSDateComponents *timeComponents;
	NSInteger hour;
	NSInteger minute;
	
	NSMutableDictionary *reminderDictionary = [NSMutableDictionary dictionary];
	NSMutableArray *dayArray;
	
	if ([timeArray count] >= 1 && [daysArray count] >= 1) {
		for (NSNumber *intValue in daysArray) {
			NSInteger weekday = [intValue intValue];
			[components setWeekday:weekday];
			dayArray = [NSMutableArray array];
			
			for (NSDate *date in timeArray) {
				timeComponents = [gregorian components:NSHourCalendarUnit + NSMinuteCalendarUnit fromDate:date];
				hour = [timeComponents hour];
				minute = [timeComponents minute];
				[components setHour:hour];
				[components setMinute:minute];
				
				alarmDate = [gregorian dateFromComponents:components];
				[dayArray addObject:alarmDate];
			}
			if ([dayArray count] > 0) {
				[reminderDictionary setObject:dayArray forKey:[NSString stringWithFormat:@"%@",intValue]];
 			}
		}
	}
	
	return reminderDictionary;
}

+ (NSArray *)remindersDueForGroups {
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	NSManagedObjectContext *managadObjectContext = appDelegate.managedObjectContext;
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setFetchLimit:120];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Result" inManagedObjectContext:managadObjectContext];
	[request setEntity:entity];
	
	// Create the sort descriptors array.
	//NSSortDescriptor *groupDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"group.title" ascending:YES] autorelease];
	NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:dateDescriptor, nil] autorelease];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managadObjectContext executeFetchRequest:request error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to get reminders." withError:error];
	}
	
	NSMutableDictionary *reminderDictionary = [NSMutableDictionary dictionary];
	
	NSDate *lastReminder = [DateMath getLastReminderDate];
	
	NSArray *reminderArray = nil;
	
	if (lastReminder != nil) {
		for (Result *aResult in fetchedObjects) {
			if ([reminderDictionary valueForKey:aResult.group.title] == nil ) {
				[reminderDictionary setObject:aResult.timestamp forKey:aResult.group.title];
			}
			else {
				NSDate *otherDate = [reminderDictionary valueForKey:aResult.group.title];
				NSComparisonResult isTimestampLater = [aResult.timestamp compare:otherDate];
				if (isTimestampLater == NSOrderedDescending) {
					[reminderDictionary setObject:aResult.timestamp forKey:aResult.group.title];
				}
			}
		}
		
		NSMutableArray *neededReminders = [NSMutableArray array];
		NSArray *reminderKeys = [reminderDictionary allKeys];
		if ([fetchedObjects count] > 0) {
			for (NSString *title in reminderKeys) {
				NSDate	*reminderDate = [reminderDictionary valueForKey:title];
				NSComparisonResult isTimestampEarlier = [reminderDate compare:lastReminder];
				if (isTimestampEarlier == NSOrderedAscending) {
					[neededReminders addObject: title];
				}
			}
		}
		else {
			NSArray *groupArray = [self getRatableGroups];
			
			for (Group * group in groupArray) {
				[neededReminders addObject:group.title];
			}
		}

		NSArray *noDataArray = [DateMath getRatableGroupsWithoutData];
		for (Group *aGroup in noDataArray) {
			if (![neededReminders containsObject:aGroup.title]) {
				[neededReminders addObject:aGroup.title];
			}
		}
		
		reminderArray = [NSArray arrayWithArray:neededReminders];
		
	}
	return reminderArray;
}

+ (NSArray *) getRatableGroupsWithoutData {
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	NSManagedObjectContext *managadObjectContext = appDelegate.managedObjectContext;
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setFetchLimit:20];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managadObjectContext];
	[request setEntity:entity];
	
	// Create the sort descriptors array.
	//NSSortDescriptor *groupDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"group.title" ascending:YES] autorelease];
	NSSortDescriptor *titleDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:titleDescriptor, nil] autorelease];
	[request setSortDescriptors:sortDescriptors];
	
	NSPredicate *noDataPredicate = [NSPredicate predicateWithFormat:@"result.@count == 0"];
	NSPredicate *rateablePredicate = [NSPredicate predicateWithFormat:@"(rateable == YES)"];
	
	NSArray *finalPredicateArray = [NSArray arrayWithObjects:noDataPredicate,rateablePredicate, nil];
	NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
	[request setPredicate:finalPredicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managadObjectContext executeFetchRequest:request error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to get Categories." withError:error];
	}
	
	return fetchedObjects;	
}

+ (NSArray *) getRatableGroups {
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	NSManagedObjectContext *managadObjectContext = appDelegate.managedObjectContext;
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setFetchLimit:20];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managadObjectContext];
	[request setEntity:entity];
	
	// Create the sort descriptors array.
	//NSSortDescriptor *groupDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"group.title" ascending:YES] autorelease];
	NSSortDescriptor *titleDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:titleDescriptor, nil] autorelease];
	[request setSortDescriptors:sortDescriptors];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rateable == YES)"];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managadObjectContext executeFetchRequest:request error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to get Categories." withError:error];
	}
	
	return fetchedObjects;
}

+ (NSDate *)getLastReminderDate {
	NSDictionary *datesDict = [DateMath getReminderDates];
	NSDateComponents *oldDateComponents = [[[NSDateComponents alloc] init] autorelease];
	[oldDateComponents setYear:1971];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDate *date = [gregorian dateFromComponents:oldDateComponents];
	NSDate *oldDate = date;
	NSDate *now = [NSDate date];
	
	NSArray *keys = [datesDict allKeys];
	
	NSArray *reminderDates;
	for (id key in keys) {
		reminderDates = [datesDict valueForKey:key];
		for (NSDate *aDate in reminderDates) {
			if ([aDate compare:now] == NSOrderedAscending && [aDate compare:date] == NSOrderedDescending) {
				date = aDate;
			}
		}
	}
	
	NSDate *newDate = nil;
	
	if ([date compare:oldDate] != NSOrderedSame) {
		newDate = date;
	}
	
	return newDate;
}

+ (NSUInteger)numberOfRecordsForMonth:(NSInteger)month {
	int monthDays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
	NSInteger daysInMonth = monthDays[month-1];
    return daysInMonth;
}

+ (NSString *)monthNameFrom:(NSInteger)monthNumber {
	NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
	NSString *monthString = [months objectAtIndex:(monthNumber - 1)];
	
	return monthString;
}

+ (NSString *)shortMonthNameFrom:(NSInteger)monthNumber {
	NSArray *months = [NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
	NSString *monthString = [months objectAtIndex:(monthNumber - 1)];
	
	return monthString;
}

@end
