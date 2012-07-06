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

@class ViewNotesViewController;
@class SLegendTableViewController;

@interface SGraphViewController : UIViewController <SChartDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> 
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
	NSDictionary *groupsDictionary;
    NSArray *groupsArray;
    NSDictionary *scalesDictionary;
	NSArray *scalesArray;
    
    IBOutlet ViewNotesViewController *notesTable;
    IBOutlet SLegendTableViewController *sLegendTableViewController;
    
    NSMutableDictionary *symbolsDictionary;
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *optionView;
    IBOutlet UISwitch *legendSwitch;
    IBOutlet UISwitch *symbolSwitch;
    IBOutlet UISwitch *gradientSwitch;
    dispatch_queue_t backgroundQueue;
    
    IBOutlet UIView *legendView;
    IBOutlet UITableView *_legendTableView;
    
}


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
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) IBOutlet ViewNotesViewController *notesTable;
@property (nonatomic, retain) IBOutlet SLegendTableViewController *sLegendTableViewController;

@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) IBOutlet UITableView *_legendTableView;

@property (nonatomic, retain) IBOutlet UIView *optionView;
@property (nonatomic, retain) IBOutlet UISwitch *legendSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *symbolSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *gradientSwitch;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;

@property (nonatomic, retain) IBOutlet UIView *legendView;


- (void)initSetup;
- (void)reloadData;
- (void)getDatasource;
- (void)getDatasourceReload;

- (void)optionButtonClicked;
- (void)shareClick;

- (void)createSwitches;
- (void)switchFlipped:(id)sender;
- (void)fillGroupsDictionary;
- (void)fillScalesDictionary;
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

- (IBAction) customChartButtonClick:(id)sender;
- (void)customChartClick;

- (void)sendMenuToBack;
- (void)emailResults;
- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo;

@end
