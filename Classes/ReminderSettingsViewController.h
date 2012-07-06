//
//  ReminderSettingsViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/13/11.
//  Copyright 2011 GDIT. All rights reserved.
//


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
