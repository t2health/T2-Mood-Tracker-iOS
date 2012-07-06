
//
//  ChartOptionsViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 5/24/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SafeFetchedResultsController.h"
#import "HRColorPickerViewController.h"


@class Group;

@interface SChartOptionsViewController : UIViewController <SafeFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, HRColorPickerViewControllerDelegate>
{
	NSManagedObjectContext *managedObjectContext;
	SafeFetchedResultsController *fetchedResultsController;
	
	NSMutableDictionary *switchDictionary;
	NSMutableDictionary *groupsDictionary;
    IBOutlet UIView *pickerView;
    IBOutlet UIView *colorPicker;
    IBOutlet UIView *symbolPicker;
    NSMutableDictionary *userSettingsDictionary;
	NSString *groupName;
	IBOutlet UITableView *_tableView;
    
    NSMutableDictionary *symbolsDictionary;
    NSMutableDictionary *colorsDictionary;
    NSMutableDictionary *ledgendColorsDictionary;
    NSDictionary *scalesDictionary;
    NSArray *scalesArray;
    
    NSString *editGroupName;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SafeFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *groupsDictionary;
@property (nonatomic, retain) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) NSMutableDictionary *userSettingsDictionary;
@property (nonatomic, retain) IBOutlet UIView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *colorPicker;
@property (nonatomic, retain) IBOutlet UIView *symbolPicker;
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSMutableDictionary *colorsDictionary;

@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;

@property (nonatomic, retain) NSString *editGroupName;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)editColor;
- (void)editSymbol;
- (void)fillGroupsDictionary;
- (void)fillColors;
- (void)fillSymbols;

- (void)cancelEdit;

- (void)addSwitchForGroup:(Group *)group;
- (NSInteger) numberSwitchesOn;
- (IBAction)doneClick:(id)sender;

- (void)openPicker:(UIColor *)withColor;
- (void)refreshTable;

- (void)checkButtonTapped:(id)sender event:(id)event;
- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color;


@end
