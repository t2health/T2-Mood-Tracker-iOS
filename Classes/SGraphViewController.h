//
//  GraphViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 4/24/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "SGraphDataSource.h"
#import "AddNoteViewController.h"
#import "ShinobiCharts/SChartGLView+Screenshot.h"
#import "ShinobiCharts/ShinobiChart+Screenshot.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <dispatch/dispatch.h>
#import "HRColorPickerViewController.h"


@class ViewNotesViewController;
@class SubLegendTableViewController;
@class NotesTableViewController;
@class OptionsTableViewController;


@interface SGraphViewController : UIViewController <SChartDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, HRColorPickerViewControllerDelegate, HRColorPickerViewControllerDelegate> 
{
    
    ShinobiChart            *chart;
    SGraphDataSource         *datasource;    
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
    NSString *groupName;
    
    NSManagedObjectContext *managedObjectContext;
    
    NSMutableDictionary *switchDictionary;
	NSMutableDictionary *ledgendColorsDictionary;
    NSArray *groupsArray;
    NSDictionary *scalesDictionary;
	NSArray *scalesArray;
    NSArray *pickerArray;
    IBOutlet UIButton *legendButton;
    
    IBOutlet ViewNotesViewController *notesTable;
    IBOutlet SubLegendTableViewController *subLegendTableViewController;
    IBOutlet NotesTableViewController *notesTableViewController;
    IBOutlet OptionsTableViewController *optionsTableViewController;
    
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
    IBOutlet UIView *pickerView;
    IBOutlet UIView *pickerView_iPad;

}

@property (nonatomic, retain) IBOutlet UIButton *legendButton;
@property (nonatomic, retain) IBOutlet UIPickerView *rangePicker;
@property (nonatomic, retain) IBOutlet UIView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *pickerView_iPad;
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *graphView;
@property (nonatomic, retain) IBOutlet UIImageView *t2LogoImageView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UINavigationBar *menuBar;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) IBOutlet ViewNotesViewController *notesTable;
@property (nonatomic, retain) IBOutlet SubLegendTableViewController *subLegendTableViewController;
@property (nonatomic, retain) IBOutlet NotesTableViewController *notesTableViewController;
@property (nonatomic, retain) IBOutlet OptionsTableViewController *optionsTableViewController;

@property (nonatomic, retain) IBOutlet UITableView *_notesTableView;

@property (nonatomic, retain) UISwipeGestureRecognizer *legendSwipeRight;
@property (nonatomic, retain) UISwipeGestureRecognizer *legendSwipeLeft;
@property (nonatomic, retain) UITapGestureRecognizer *legendTap;
@property (nonatomic, retain) NSArray *pickerArray;

@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) IBOutlet UITableView *_legendTableView;
@property (nonatomic, retain) IBOutlet UITableView *_optionsTableView;

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

- (void) imageTapped:(UITapGestureRecognizer *)gesture;

- (void)optionButtonClicked;
- (void)shareClick;

- (void)createSwitches;
- (void)switchFlipped:(id)sender;
- (void)switchProcess;
- (void)fillScalesDictionary;
- (void)fillColors;
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
