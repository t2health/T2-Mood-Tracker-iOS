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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "GraphDataSource.h"
#import "AddNoteViewController.h"
#import "ShinobiCharts/SChartGLView+Screenshot.h"
#import "ShinobiCharts/ShinobiChart+Screenshot.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <dispatch/dispatch.h>

@class ViewNotesViewController;
@class LegendTableViewController;
@class NotesTableViewController;
@class OptionsTableViewController;


@interface GraphViewController : UIViewController <SChartDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource> 
{
    
    ShinobiChart            *chart;
    GraphDataSource         *datasource;    
    UISwitch                *stepSwitch;
    UILabel                 *stepLabel;
    
    IBOutlet UIView *menuView;
    IBOutlet UIView *containerView;
    IBOutlet UIView *graphView;
    IBOutlet UISegmentedControl *segmentButton;
    IBOutlet UINavigationBar *menuBar;
    
    IBOutlet UIImageView *t2LogoImageView;
    IBOutlet UIView *loadingView;
    IBOutlet UILabel *loadingLabel;
    
    NSManagedObjectContext *managedObjectContext;
    
    NSMutableDictionary *switchDictionary;
	NSMutableDictionary *ledgendColorsDictionary;
	NSDictionary *groupsDictionary;
    NSArray *groupsArray;
    NSArray *pickerArray;
    IBOutlet UIButton *legendButton;
    
    NSMutableArray *chartChangeArray;
    
    IBOutlet ViewNotesViewController *notesTable;
    IBOutlet LegendTableViewController *legendTableViewController;
    IBOutlet NotesTableViewController *notesTableViewController;
    IBOutlet OptionsTableViewController *optionsTableViewController;

    NSMutableDictionary *symbolsDictionary;
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *optionView;
    IBOutlet UISwitch *legendSwitch;
    IBOutlet UISwitch *symbolSwitch;
    IBOutlet UISwitch *gradientSwitch;
    dispatch_queue_t backgroundQueue;
    
    IBOutlet UIView *legendView;
    IBOutlet UITableView *_legendTableView;
    IBOutlet UITableView *_notesTableView;
    IBOutlet UITableView *_optionsTableView;
    IBOutlet UIView *noteView;
	UISwipeGestureRecognizer *legendSwipeRight;
	UISwipeGestureRecognizer *legendSwipeLeft;
    UITapGestureRecognizer *legendTap;
    
    IBOutlet UIBarButtonItem *doneButton;	// this button appears only when the date picker is open
    IBOutlet UIPickerView *rangePicker;


    
}

@property (nonatomic, retain) IBOutlet UIButton *legendButton;
@property (nonatomic, retain) IBOutlet UIPickerView *rangePicker;

@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *graphView;
@property (nonatomic, retain) IBOutlet UIImageView *t2LogoImageView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UINavigationBar *menuBar;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) NSDictionary *groupsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) IBOutlet ViewNotesViewController *notesTable;
@property (nonatomic, retain) IBOutlet LegendTableViewController *legendTableViewController;
@property (nonatomic, retain) IBOutlet NotesTableViewController *notesTableViewController;
@property (nonatomic, retain) IBOutlet OptionsTableViewController *optionsTableViewController;

@property (nonatomic, retain) IBOutlet UITableView *_notesTableView;

@property (nonatomic, retain) UISwipeGestureRecognizer *legendSwipeRight;
@property (nonatomic, retain) UISwipeGestureRecognizer *legendSwipeLeft;
@property (nonatomic, retain) UITapGestureRecognizer *legendTap;
@property (nonatomic, retain) NSArray *pickerArray;


@property (nonatomic, retain) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) IBOutlet UITableView *_legendTableView;
@property (nonatomic, retain) IBOutlet UITableView *_optionsTableView;


//0@property (nonatomic, retain) IBOutlet UITableView *_legendTable;

@property (nonatomic, retain) IBOutlet UIView *optionView;
@property (nonatomic, retain) IBOutlet UIView *noteView;
@property (nonatomic, retain) IBOutlet UISwitch *legendSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *symbolSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *gradientSwitch;

@property (nonatomic, retain) IBOutlet UIView *legendView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (void)initSetup;
- (void)getDatasource;
- (void)setupGraph;
- (void)reloadGraph;
- (void)updateGraphData;
- (void)redrawGraph;

- (void)optionButtonClicked;
- (void)shareClick;

- (void)createSwitches;
- (void)switchFlipped:(id)sender;
- (void)switchProcess;
- (void)fillGroupsDictionary;
- (void)fillColors;
- (void)fillSymbols;
- (void)fillOptions;

- (void)saveToGallery;

- (void)legendButtonClicked;
- (void)showLegend;
- (void)resetLegend;

- (void)resignLegend;
- (void)showButtons:(int)howMany;


- (void)legendToggle;
- (void)symbolToggle;
- (void)gradientToggle;
- (IBAction) legendButtonClicked:(id)sender;

- (void)sendMenuToBack;
- (void)emailResults;
- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo;

- (IBAction)doneAction:(id)sender;
- (void)resignPicker;
- (void)slideDownDidStop;

@end
