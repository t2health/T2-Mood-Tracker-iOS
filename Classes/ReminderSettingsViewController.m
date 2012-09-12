//
//  ReminderSettingsViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/13/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "ReminderSettingsViewController.h"
#import "HourSelectorViewController.h"
#import "VASAnalytics.h"
#import "FlurryUtility.h"

@implementation ReminderSettingsViewController

@synthesize gregorian;

@synthesize morningReminderStateSwitch;
@synthesize noonReminderStateSwitch;
@synthesize eveningReminderStateSwitch;
@synthesize mondayReminderStateSwitch;
@synthesize tuesdayReminderStateSwitch;
@synthesize wednesdayReminderStateSwitch;
@synthesize thursdayReminderStateSwitch;
@synthesize fridayReminderStateSwitch;
@synthesize saturdayReminderStateSwitch;
@synthesize sundayReminderStateSwitch;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    table.backgroundView = nil;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = @"Reminders";
	
	gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"ReminderTimeChanged" object:nil];
	[FlurryUtility report:EVENT_REMINDER_ACTIVITY];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self setReminerSummaryText];
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)handleNotification:(NSNotification*)note {
	[table reloadData];
}

-(void)setReminerSummaryText {
	NSString *timeString = @"";
	NSString *daysString = @"";
	NSString *currentString = @"";
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDate *storedDate = nil;
	NSInteger hour;
	NSInteger minute;
	
	NSDateComponents *components;
	
	BOOL currentSetting = [userDefaults boolForKey:@"MORNING_REMINDER_STATE"];
	if (currentSetting == YES) {
		storedDate = [userDefaults objectForKey:@"MORNING_REMINDER_TIME"];
		components = [self.gregorian components:NSHourCalendarUnit + NSMinuteCalendarUnit fromDate:storedDate];
		hour = [components hour];
		minute = [components minute];
		if (hour == 0) {
            currentString = [NSString stringWithFormat:@"%d:%02d AM",12,minute];
        }
        else if (hour < 12) {
			currentString = [NSString stringWithFormat:@"%d:%02d AM",hour,minute];			
		}
        else if(hour == 12) {
            currentString = [NSString stringWithFormat:@"%d:%02d PM",hour,minute];
        }
		else {
			currentString = [NSString stringWithFormat:@"%d:%02d PM",hour - 12,minute];
		}
		
		if ([timeString isEqual:@""]) {
			timeString = currentString;
		}
		else {
			timeString = [NSString stringWithFormat:@"%@, %@",timeString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"NOON_REMINDER_STATE"];
	if (currentSetting == YES) {
		storedDate = [userDefaults objectForKey:@"NOON_REMINDER_TIME"];
		components = [self.gregorian components:NSHourCalendarUnit + NSMinuteCalendarUnit fromDate:storedDate];
		hour = [components hour];
		minute = [components minute];
		if (hour == 0) {
            currentString = [NSString stringWithFormat:@"%d:%02d AM",12,minute];
        }
        else if (hour < 12) {
			currentString = [NSString stringWithFormat:@"%d:%02d AM",hour,minute];			
		}
        else if(hour == 12) {
            currentString = [NSString stringWithFormat:@"%d:%02d PM",hour,minute];
        }
		else {
			currentString = [NSString stringWithFormat:@"%d:%02d PM",hour - 12,minute];
		}
		
		if ([timeString isEqual:@""]) {
			timeString = currentString;
		}
		else {
			timeString = [NSString stringWithFormat:@"%@, %@",timeString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"EVENING_REMINDER_STATE"];
	if (currentSetting == YES) {
		storedDate = [userDefaults objectForKey:@"EVENING_REMINDER_TIME"];
		components = [self.gregorian components:NSHourCalendarUnit + NSMinuteCalendarUnit fromDate:storedDate];
		hour = [components hour];
		minute = [components minute];
		if (hour == 0) {
            currentString = [NSString stringWithFormat:@"%d:%02d AM",12,minute];
        }
        else if (hour < 12) {
			currentString = [NSString stringWithFormat:@"%d:%02d AM",hour,minute];			
		}
        else if(hour == 12) {
            currentString = [NSString stringWithFormat:@"%d:%02d PM",hour,minute];
        }
		else {
			currentString = [NSString stringWithFormat:@"%d:%02d PM",hour - 12,minute];
		}
		
		if ([timeString isEqual:@""]) {
			timeString = currentString;
		}
		else {
			timeString = [NSString stringWithFormat:@"%@, %@",timeString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"SUNDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:0];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"MONDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:1];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"TUESDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:2];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"WEDNESDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:3];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"THURSDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:4];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"FRIDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:5];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	currentSetting = [userDefaults boolForKey:@"SATURDAY_REMINDER_STATE"];
	if (currentSetting == YES) {
		currentString = [self weekdayString:6];
		if ([daysString isEqual:@""]) {
			daysString = currentString;
		}
		else {
			daysString = [NSString stringWithFormat:@"%@, %@",daysString,currentString];
		}
	}
	
	if (![timeString isEqual:@""] && ![daysString isEqual:@""]) {
		NSString *summaryString = [NSString stringWithFormat:@"%@ on %@", timeString, daysString];
		reminderText.text = summaryString;
	}
	else {
		reminderText.text = @"Choose at least one time and one day to receive reminders.";
	}
	
}

- (NSString *)weekdayString:(NSInteger)weekday {
	NSString *weekdayString = nil;
	
	switch (weekday) {
		case 0:
			weekdayString = @"Sun";
			break;
		case 1:
			weekdayString = @"Mon";
			break;
		case 2:
			weekdayString = @"Tue";
			break;
		case 3:
			weekdayString = @"Wed";
			break;
		case 4:
			weekdayString = @"Thu";
			break;
		case 5:
			weekdayString = @"Fri";
			break;
		case 6:
			weekdayString = @"Sat";
			break;			
		default:
			break;
	}
	
	return weekdayString;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numRows;
	
	switch (section) {
		case 0: //Times for alarms
			numRows = 3;
			break;
		case 1: //Days for alarms
			numRows = 7;
			break;
		default:
			numRows = 0;
			break;
	}
	
    return numRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionName;
	
	switch (section) {
		case 0: //Time
			sectionName = @"Time(s)";
			break;
		case 1: //Days
			sectionName = @"Day(s)";
			break;
		default:
			sectionName = nil;
			break;
	}
	return sectionName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger section = [indexPath indexAtPosition:0];
	NSInteger row = [indexPath indexAtPosition:1];
    
	//CGRect switchFrame;
	//CGRect cellFrame;
	
	NSString *key;
	BOOL storedVal;
	NSString *dateString;
	NSDate *storedDate;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//NSInteger switchLeftPad = 10;
	//NSInteger switchRightPad = 120;
	
	//cellFrame = cell.frame;
	//switchFrame = CGRectMake(cellFrame.size.width - switchRightPad, switchLeftPad, 100, 27);
	UISwitch *aSwitch = [[[UISwitch alloc] init] autorelease];
	
	switch (section) {
		case 0: //Time
			switch (row) {
				case 0: //8:00AM
					key = [NSString stringWithFormat:@"MORNING_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					[aSwitch addTarget:self action:@selector(morningReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.morningReminderStateSwitch = aSwitch;
					storedDate = [defaults objectForKey:@"MORNING_REMINDER_TIME"];
					if (storedDate == nil) {
						NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
						[components setHour:8];
						[components setMinute:0];
						
						storedDate = [gregorian dateFromComponents:components];
						[defaults setObject:storedDate forKey:@"MORNING_REMINDER_TIME"];
					}
					
					dateString = [self getDateString:storedDate];
					cell.textLabel.text = [NSString stringWithFormat:@"%@ (Edit)",dateString];
					break;
				case 1: //12:00AM
					key = [NSString stringWithFormat:@"NOON_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;					
					[aSwitch addTarget:self action:@selector(noonReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.noonReminderStateSwitch = aSwitch;
					storedDate = [defaults valueForKey:@"NOON_REMINDER_TIME"];
					if (storedDate == nil) {
						NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
						[components setHour:12];
						[components setMinute:0];
						
						storedDate = [gregorian dateFromComponents:components];
						[defaults setObject:storedDate forKey:@"NOON_REMINDER_TIME"];
					}
					
					dateString = [self getDateString:storedDate];
					cell.textLabel.text = [NSString stringWithFormat:@"%@ (Edit)",dateString];
					break;
				case 2: //5:00PM
					key = [NSString stringWithFormat:@"EVENING_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(eveningReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.eveningReminderStateSwitch = aSwitch;
					storedDate = [defaults valueForKey:@"EVENING_REMINDER_TIME"];
					if (storedDate == nil) {
						NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
						[components setHour:17];
						[components setMinute:0];
						
						storedDate = [gregorian dateFromComponents:components];
						[defaults setObject:storedDate forKey:@"EVENING_REMINDER_TIME"];
					}
					
					dateString = [self getDateString:storedDate];
					
					cell.textLabel.text = [NSString stringWithFormat:@"%@ (Edit)",dateString];
					break;
				default:
					break;
			}
			break;
		case 1: //Day
			switch (row) {
				case 0: //Sunday
					key = [NSString stringWithFormat:@"SUNDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(sundayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.sundayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Sunday";			
					break;					
				case 1: //Monday
					key = [NSString stringWithFormat:@"MONDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(mondayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.mondayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Monday";
					break;
				case 2: //Tuesday
					key = [NSString stringWithFormat:@"TUESDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(tuesdayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.tuesdayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Tuesday";					
					break;
				case 3: //Wednesday
					key = [NSString stringWithFormat:@"WEDNESDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(wednesdayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.wednesdayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Wednesday";					
					break;
				case 4: //Thursday
					key = [NSString stringWithFormat:@"THURSDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(thursdayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.thursdayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Thursday";					
					break;
				case 5: //Friday
					key = [NSString stringWithFormat:@"FRIDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(fridayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.fridayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Friday";					
					break;
				case 6: //Saturday
					key = [NSString stringWithFormat:@"SATURDAY_REMINDER_STATE"];
					storedVal = [defaults boolForKey:key];
					aSwitch.on = storedVal;
					
					[aSwitch addTarget:self action:@selector(saturdayReminderStateSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
					self.saturdayReminderStateSwitch = aSwitch;
					cell.textLabel.text = @"Saturday";					
					break;					
				default:
					break;
			}
			break;
		default:
			break;
	}
	cell.accessoryView = aSwitch;
	//[cell addSubview:aSwitch];
	
    return cell;
}

-(NSString *)getDateString:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	NSLocale *usLocale = [NSLocale currentLocale];
	[dateFormatter setLocale:usLocale];
	
	NSString *dateString = [dateFormatter stringFromDate:date];
	
	return dateString;
}

- (void)morningReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"MORNING_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)noonReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"NOON_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)eveningReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"EVENING_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)mondayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"MONDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)tuesdayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"TUESDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)wednesdayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"WEDNESDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)thursdayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"THURSDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)fridayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"FRIDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)saturdayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"SATURDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)sundayReminderStateSwitchFlipped:(id)sender {
	NSString *defaultsKey = @"SUNDAY_REMINDER_STATE";
	UISwitch *theSwitch = (UISwitch *)sender;
	
	[self setDefaultStateTo:theSwitch.on withDefaultName:defaultsKey];
	[self setReminerSummaryText];
}

- (void)setDefaultStateTo:(BOOL)state withDefaultName:(NSString *)name{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:state forKey:name];
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath indexAtPosition:0];
	NSInteger row = [indexPath indexAtPosition:1];
	
	HourSelectorViewController *hourSelectorViewController;
	
	switch (section) {
		case 0: //Times
			switch (row) {
				case 0: //Morning
					hourSelectorViewController = [[[HourSelectorViewController alloc] initWithNibName:@"HourSelectorViewController" bundle:nil] autorelease];
					hourSelectorViewController.section = row;
					hourSelectorViewController.title = @"Reminder Time";
					[self.navigationController pushViewController:hourSelectorViewController animated:YES];
					break;
				case 1: //Noon
					hourSelectorViewController = [[[HourSelectorViewController alloc] initWithNibName:@"HourSelectorViewController" bundle:nil] autorelease];
					hourSelectorViewController.section = row;
					hourSelectorViewController.title = @"Reminder Time";
					[self.navigationController pushViewController:hourSelectorViewController animated:YES];					
					break;
				case 2: //Evening
					hourSelectorViewController = [[[HourSelectorViewController alloc] initWithNibName:@"HourSelectorViewController" bundle:nil] autorelease];
					hourSelectorViewController.section = row;
					hourSelectorViewController.title = @"Reminder Time";
					[self.navigationController pushViewController:hourSelectorViewController animated:YES];					
					break;
				default:
					break;
			}
			break;
		case 1: //Days
			break;
		default:
			break;
	}
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void) viewWillDisappear:(BOOL)animated {
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
	NSDateComponents *nowComponents = [self.gregorian components:NSYearCalendarUnit + NSMonthCalendarUnit + NSWeekdayOrdinalCalendarUnit fromDate:now];
	
	NSInteger nowYear = [nowComponents year];
	NSInteger nowMonth = [nowComponents month];
	NSInteger nowDayOrdinal = [nowComponents weekdayOrdinal];
	
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setYear:nowYear];
	[components setMonth:nowMonth];
	[components setWeekdayOrdinal:nowDayOrdinal];
	NSDate *alarmDate;
	NSString *alertString = @"How are you feeling?";
	
	NSDateComponents *timeComponents;
	NSInteger hour;
	NSInteger minute;
	
	UIApplication *app = [UIApplication sharedApplication];
	
	
	Class notificationClass = (NSClassFromString(@"UILocalNotification"));
	if (notificationClass != nil) {
		[app cancelAllLocalNotifications];
	}
	if ([timeArray count] >= 1 && [daysArray count] >= 1) {
		for (NSDate *date in timeArray) {
			timeComponents = [self.gregorian components:NSHourCalendarUnit + NSMinuteCalendarUnit fromDate:date];
			hour = [timeComponents hour];
			minute = [timeComponents minute];
			[components setHour:hour];
			[components setMinute:minute];
			for (NSNumber *intValue in daysArray) {
				NSInteger weekday = [intValue intValue];
				[components setWeekday:weekday];
				alarmDate = [self.gregorian dateFromComponents:components];
				[self addNotificationForDate:alarmDate andMessage:alertString];
			}
		}
	}	
}

- (void)addNotificationForDate:(NSDate *)date andMessage:(NSString *)message {
    Class notificationClass = (NSClassFromString(@"UILocalNotification"));
	if (notificationClass != nil) {
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
		localNotification.fireDate = date;
		localNotification.alertBody = message;
		localNotification.soundName = UILocalNotificationDefaultSoundName;
		localNotification.applicationIconBadgeNumber = 1;
		localNotification.repeatInterval = NSWeekCalendarUnit;
        
		[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
		[localNotification release];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[gregorian release];
	
	[morningReminderStateSwitch release];
	[noonReminderStateSwitch release];
	[eveningReminderStateSwitch release];
	
	[mondayReminderStateSwitch release];
	[tuesdayReminderStateSwitch release];
	[wednesdayReminderStateSwitch release];
	[thursdayReminderStateSwitch release];
	[fridayReminderStateSwitch release];
	[saturdayReminderStateSwitch release];
	[sundayReminderStateSwitch release];
	
    [super dealloc];
}

@end