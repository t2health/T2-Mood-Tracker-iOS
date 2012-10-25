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


@interface ReminderSettingsViewController : UIViewController <UITableViewDelegate> {
	IBOutlet UITextView *reminderText;
	IBOutlet UITableView *table;
	NSCalendar *gregorian;
	
	IBOutlet UISwitch *morningReminderStateSwitch;
	IBOutlet UISwitch *noonReminderStateSwitch;
	IBOutlet UISwitch *eveningReminderStateSwitch;
	IBOutlet UISwitch *mondayReminderStateSwitch;
	IBOutlet UISwitch *tuesdayReminderStateSwitch;
	IBOutlet UISwitch *wednesdayReminderStateSwitch;
	IBOutlet UISwitch *thursdayReminderStateSwitch;
	IBOutlet UISwitch *fridayReminderStateSwitch;
	IBOutlet UISwitch *saturdayReminderStateSwitch;
	IBOutlet UISwitch *sundayReminderStateSwitch;
}

@property (nonatomic, retain)NSCalendar* gregorian;

@property (nonatomic, retain) IBOutlet UISwitch *morningReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *noonReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *eveningReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *mondayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *tuesdayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *wednesdayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *thursdayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *fridayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *saturdayReminderStateSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *sundayReminderStateSwitch;

- (void)morningReminderStateSwitchFlipped:(id)sender;
- (void)noonReminderStateSwitchFlipped:(id)sender;
- (void)eveningReminderStateSwitchFlipped:(id)sender;
- (void)mondayReminderStateSwitchFlipped:(id)sender;
- (void)tuesdayReminderStateSwitchFlipped:(id)sender;
- (void)wednesdayReminderStateSwitchFlipped:(id)sender;
- (void)thursdayReminderStateSwitchFlipped:(id)sender;
- (void)fridayReminderStateSwitchFlipped:(id)sender;
- (void)saturdayReminderStateSwitchFlipped:(id)sender;
- (void)sundayReminderStateSwitchFlipped:(id)sender;
- (void)setDefaultStateTo:(BOOL)state withDefaultName:(NSString *)name;
- (NSString *)getDateString:(NSDate *)date;
- (void)addNotificationForDate:(NSDate *)date andMessage:(NSString *)message;
- (NSString *)weekdayString:(NSInteger)weekday;
- (void)setReminerSummaryText ;
@end
