//
//  GraphResultsViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/28/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>
#import <CorePlot/CorePlot.h>

@class ViewNotesViewController;

@interface GraphResultsViewController : UIViewController  <CPPlotDataSource, UIGestureRecognizerDelegate, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
	
	CPGraphHostingView *graphHost;
	
	CPGraph *graph;
	NSInteger chartMonth;
	NSInteger chartYear;
	BOOL dateSet;
	NSMutableDictionary *switchDictionary;
	NSMutableDictionary *ledgendColorsDictionary;
	NSDictionary *groupsDictionary;
	NSArray *groupsArray;
	NSCalendar *gregorian;
	
	NSArray *notesForMonth;
	NSDictionary *valuesArraysForMonth;
	
	UISwipeGestureRecognizer *graphSwipeRight;
	UISwipeGestureRecognizer *graphSwipeLeft;
    UITapGestureRecognizer *graphTap;
	
	IBOutlet UIView *containterView;
	IBOutlet UIView *graphView;
	IBOutlet UIView *ledgendView;
	IBOutlet UITableView *graphSwitches;
	IBOutlet UILabel *monthLabel;
	IBOutlet UIButton *backMonth;
	IBOutlet UIButton *forwardMonth;
	IBOutlet UILabel *segmentLabel;
	IBOutlet UISegmentedControl *segmentButton;
	IBOutlet ViewNotesViewController *notesTable;
    UIImageView *screenShotView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet CPGraphHostingView *graphHost;

@property (nonatomic, retain) CPGraph *graph;
@property (nonatomic, retain) NSCalendar* gregorian;

@property (nonatomic, retain) NSArray *notesForMonth;
@property (nonatomic, retain) NSDictionary *valuesArraysForMonth;

@property (nonatomic, retain) UISwipeGestureRecognizer *graphSwipeRight;
@property (nonatomic, retain) UISwipeGestureRecognizer *graphSwipeLeft;
@property (nonatomic, retain) UITapGestureRecognizer *graphTap;

@property (nonatomic, retain) UITableView *graphSwitches;

@property (nonatomic, assign) NSInteger chartMonth;
@property (nonatomic, assign) NSInteger chartYear;
@property (nonatomic, assign) BOOL dateSet;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) IBOutlet ViewNotesViewController *notesTable;
@property (nonatomic, retain) NSDictionary *groupsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) UIImageView *screenShotView;

- (void)setupGraph;
- (void)createSwitches;
- (void)showMonth;
- (void)monthChanged;
- (void)fillGroupsDictionary;
- (void)fillColors;

- (IBAction)backMonthClicked:(id)sender;
- (IBAction)forwardMonthClicked:(id)sender;
- (IBAction)tapClicked:(id)sender;
- (IBAction)segmentIndexChanged;
- (IBAction)drillDownClicked:(id)sender;

- (UIColor *)UIColorForIndex:(NSInteger)index;
- (CPColor *)CPColorForIndex:(NSInteger)index;

- (void)switchFlipped:(id)sender;


- (NSArray *)getMondayArrayForMonth:(NSInteger)month andYear:(NSInteger)year;
- (NSArray *)getNotesForMonth;
- (NSDictionary *)getValueDictionaryForMonth;
- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)getScreenShot;
- (void)getScreenShot;
- (UIImage*)screenShot;

@end