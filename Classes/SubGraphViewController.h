//
//  SubGraphViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/11/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CorePlot/CorePlot.h>
#import "SafeFetchedResultsController.h"

@class ViewNotesViewController;

@interface SubGraphViewController : UIViewController <CPPlotDataSource, UIGestureRecognizerDelegate, UITableViewDelegate>{
    NSManagedObjectContext *managedObjectContext;
	
	CPGraphHostingView *graphHost;
	
	CPGraph *graph;
	NSInteger chartMonth;
	NSInteger chartYear;
	BOOL dateSet;
	NSMutableDictionary *switchDictionary;
	NSMutableDictionary *ledgendColorsDictionary;
	IBOutlet ViewNotesViewController *notesTable;
	NSDictionary *scalesDictionary;
	NSArray *scalesArray;
	NSCalendar *gregorian;
	NSString *groupName;
	
	NSArray *notesForMonth;
	NSDictionary *valuesArraysForMonth;
	
	UISwipeGestureRecognizer *graphSwipeRight;
	UISwipeGestureRecognizer *graphSwipeLeft;
	
	NSDictionary *userDictionary;
	
	IBOutlet UIView *containterView;
	IBOutlet UIView *graphView;
	IBOutlet UIView *ledgendView;
	IBOutlet UITableView *graphSwitches;
	
	IBOutlet UILabel *monthLabel;
	IBOutlet UIButton *backMonth;
	IBOutlet UIButton *forwardMonth;
	IBOutlet UILabel *segmentLabel;
	IBOutlet UISegmentedControl *segmentButton;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet CPGraphHostingView *graphHost;

@property (nonatomic, retain) CPGraph *graph;
@property (nonatomic, assign) NSInteger chartMonth;
@property (nonatomic, assign) NSInteger chartYear;
@property (nonatomic, assign) BOOL dateSet;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) IBOutlet ViewNotesViewController *notesTable;
@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) NSCalendar* gregorian;
@property (nonatomic, retain) NSString *groupName;

@property (nonatomic, retain) NSArray *notesForMonth;
@property (nonatomic, retain) NSDictionary *valuesArraysForMonth;

@property (nonatomic, retain) UISwipeGestureRecognizer *graphSwipeRight;
@property (nonatomic, retain) UISwipeGestureRecognizer *graphSwipeLeft;
@property (nonatomic, retain) NSDictionary *userDictionary;

- (void)setupGraph;
- (void)createSwitches;
- (void)showMonth;
- (void)monthChanged;
- (void)fillScalesDictionary;
- (void)fillColors;

- (IBAction)backMonthClicked:(id)sender;
- (IBAction)forwardMonthClicked:(id)sender;
- (IBAction)segmentIndexChanged;

- (UIColor *)UIColorForIndex:(NSInteger)index;
- (CPColor *)CPColorForIndex:(NSInteger)index;

- (void)switchFlipped:(id)sender;
- (void)addNote:(id)sender;

- (NSArray *)getMondayArrayForMonth:(NSInteger)month andYear:(NSInteger)year;

- (NSArray *)getNotesForMonth;
- (NSDictionary *)getValueDictionaryForMonth;
- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
