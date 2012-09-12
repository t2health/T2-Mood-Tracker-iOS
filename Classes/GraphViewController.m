//
//  GraphViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 4/24/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "GraphViewController.h"
#import "SGraphViewController.h"
#import "ChartOptionsViewController.h"
#import "VAS002AppDelegate.h"
#import "Result.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Group.h"
#import "ViewNotesViewController.h"
#import "Error.h"
#import "Note.h"
#import "GroupResult.h"
#import "DateMath.h"
#import "AddNoteViewController.h"
#import "MailData.h"
#import "LegendTableViewController.h"
#import "NotesTableViewController.h"
#import "OptionsTableViewController.h"
#import "HRColorUtil.h"
#import "HRColorPickerViewController.h"


@implementation GraphViewController

@synthesize menuView, containerView, graphView, notesTable, noteView;
@synthesize managedObjectContext, pickerView_iPad;

@synthesize switchDictionary, menuBar, loadingLabel;
@synthesize ledgendColorsDictionary, legendTap, legendSwipeRight, legendSwipeLeft;
@synthesize groupsDictionary, groupsArray;
@synthesize t2LogoImageView, loadingView, symbolsDictionary,legendButton;
@synthesize _tableView, optionView, legendSwitch, symbolSwitch, gradientSwitch;
@synthesize legendView, legendTableViewController, _legendTableView, notesTableViewController, _notesTableView;
@synthesize optionsTableViewController, _optionsTableView, doneButton, rangePicker, pickerArray, pickerView;

CGRect menu_ShownFrame;
CGRect menu_HiddenFrame;	
bool menuShowing;
bool isOptions;
bool isLegend;
bool isSymbol;
bool isGradient;
bool doUpdate;
bool doSeries;
bool isRefreshTable;
bool isMyLegend;
bool isPortrait;

#pragma mark - Load/Init
- (void)viewDidLoad
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [super viewDidLoad];
    _notesTableView.backgroundView = nil;
    _tableView.backgroundView = nil;
    
    loadingLabel.text = @"Generating Chart";
    // Init view state
    [graphView setAlpha:1.0];
    [menuView setAlpha:1.0];
    containerView.backgroundColor = [UIColor colorWithRed:26.f/255.f green:25.f/255.f blue:25.f/255.f alpha:1.f];
    
    t2LogoImageView.hidden = NO;
    // Menu state
    menuShowing = YES;
    
    // Fill Picker Array
    self.pickerArray = [[[NSArray alloc] initWithObjects:
                         @"30 days", @"90 days", @"180 days", @"1 year", nil] autorelease];
    
    // isOptions default
    isOptions = NO;
    isLegend = NO;
    isSymbol = NO;
    isGradient = NO;
    
    isMyLegend = NO;
    doUpdate = NO;
    doSeries = NO;
    isRefreshTable = NO;
    
    // Views
    optionView.hidden = YES;
    _tableView.hidden = NO;
    noteView.hidden = YES;
    
    notesTableViewController.myNavController = self.navigationController;
    optionsTableViewController.myNavController = self.navigationController;
    optionsTableViewController.whichGraph = @"Category";
    
    // Core Data
    UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
    
    // Setup Data
    [self fillGroupsDictionary];
	[self fillColors];
	[self createSwitches];
    [self fillSymbols];
    [self fillOptions];
    
    // Orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // NOTIFICATIONS----------------------------------------------//
    // Listen for Actions from Option UITableViewController
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(legendToggle) name:@"toggleLegend_Category" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadingSymbol) name:@"toggleSymbol_Category" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadingGradient) name:@"toggleGradient_Category" object: nil];

    // // Listen for Actions from Picker
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showPicker) name:@"showPicker_Category" object: nil];
     // NOTIFICATIONS----------------------------------------------//
    
    // Capture initial orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        isPortrait = YES;
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        isPortrait = NO;
    }
    
    backgroundQueue = dispatch_queue_create("org.t2health.moodtracker.bgqueue", NULL);        
    [containerView bringSubviewToFront:loadingView];

    [self initSetup];
    
}

-(void) viewDidUnload
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    switchDictionary = nil;
	ledgendColorsDictionary = nil;
	groupsDictionary = nil;
    groupsArray = nil;
    pickerArray = nil;
    symbolsDictionary = nil;
    datasource = nil;
    [datasource release];
    dispatch_release(backgroundQueue);


}

-(void) viewWillAppear:(BOOL)animated 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    NSLog(@"groupsArray: %@", groupsArray);
    
    // Capture initial orientation
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        NSLog(@"ORIENTATION: Portrait: %i", isPortrait);
        
        int chartHeight = 0;
        int menuHeight = 0;
        int menuStart = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            chartHeight = 512;
            menuStart = 512;
            menuHeight = 512;
        } 
        else 
        {
            // iPhone
            chartHeight = 211;
            menuStart = 211;
            menuHeight = 215;
        }
        chart.alpha = 0.0f;
        //            [chart removeFromSuperview];
        
        
        CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
        CGRect chartRect = CGRectMake(0.0,
                                      0.0,
                                      chartViewSize.width, chartHeight); 
        
        chart.frame = chartRect;
        [self showButtons:1];
        
        CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
        CGRect menuRect = CGRectMake(0.0,
                                     menuStart,
                                     menuViewSize.width, menuHeight);
        self.menuView.frame = menuRect;
        
       // menuView.hidden = NO;
       // [menuView setAlpha:1.0];
        chart.alpha = 1.0f;
        //            [containerView addSubview:chart];
        //            [containerView bringSubviewToFront:legendView];
        //            [containerView bringSubviewToFront:menuView];
        
        [self slideDownDidStop];
        // [self resetLegend];
        
        isPortrait = YES;    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        int chartHeight = 0;
        int menuHeight = 0;
        int menuStart = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            chartHeight = 700;
            menuStart = 0;
            menuHeight = 700;
        } 
        else 
        {
            // iPhone
            chartHeight = 260;
            menuStart = 0;
            menuHeight = 320;
        } 
        chart.alpha = 0.0f;
        //            [chart removeFromSuperview];
        
        NSLog(@"ORIENTATION: Landscape: %i", isPortrait);
        CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      0.0,
                                      chartViewSize.width, chartHeight); 
        
        chart.frame = startRect;
        [self showButtons:1];
        
        CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
        CGRect menuRect = CGRectMake(0.0,
                                     menuStart,
                                     menuViewSize.width, menuHeight);
        self.menuView.frame = menuRect;
        
        chart.alpha = 1.0f;
        //            [containerView addSubview:chart];
        //            [containerView bringSubviewToFront:legendView];
        //            [containerView bringSubviewToFront:menuView];
        menuView.hidden = YES;
        menuShowing = NO;
        
        [self slideDownDidStop];
        //  [self resetLegend];
        isPortrait = NO;
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self 
                                   selector:@selector(switchProcess) 
                                   userInfo:nil 
                                    repeats:NO];
    
    [_tableView reloadData];    
    //[_legendTableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) 
    {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack. 

    }
    [super viewWillDisappear:animated];
}

#pragma mark Graph Menu 


- (void)reloadGraph
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [containerView bringSubviewToFront:loadingView];
    [_optionsTableView reloadData];
    [chart removeFromSuperview];
    
    dispatch_async(backgroundQueue, ^(void) {
        [self getDatasource];
    }); 
    
    
   // dispatch_async(backgroundQueue, ^(void) {
     //   [self updateGraphData];
    //}); 
}

- (void)updateGraphData
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    // Initialise the data source we will use for the chart
    datasource = [[GraphDataSource alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self redrawGraph];
    });
}

- (void)redrawGraph
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    chart.datasource = datasource;

    // Reload data
    [chart reloadData];
    [chart layoutSubviews];

    // Redraw chart
    [chart redrawChartAndGL: YES];
    
    [containerView sendSubviewToBack:loadingView];

}


- (void)initSetup
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    loadingLabel.text = @"Loading Data";
    dispatch_async(backgroundQueue, ^(void) {
        [self getDatasource];
    }); 
    
}

- (void)getDatasource
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    // Initialise the data source we will use for the chart
    if (datasource == nil) 
    {
        datasource = [[GraphDataSource alloc] init];
    }
    else 
    {
        datasource = nil;
        [datasource release];
        
        datasource = [[GraphDataSource alloc] init];

    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self setupGraph];
    });
}

- (void)setupGraph
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        //Create the chart
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, graphView.bounds.size.width, 512)];
        }
        else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
        {
            chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, graphView.bounds.size.width, 700)];
        }    
    } 
    else 
    {
        //Create the chart
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, graphView.bounds.size.width, 211)];
        }
        else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
        {
            chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, graphView.bounds.size.width, graphView.bounds.size.height)];
        }
        
    }
    
    // Set a different theme on the chart
    SChartMidnightTheme *midnight = [[SChartMidnightTheme alloc] init];
    [chart setTheme:midnight];
    [midnight release];

    //As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
    chart.autoresizingMask = ~UIViewAutoresizingNone;
    
    // Initialise the data source we will use for the chart
    // datasource = [[GraphDataSource alloc] init];
    
    // Give the chart the data source
    chart.datasource = datasource;
    
  //  SChartDateRange *xRange = [[SChartDateRange alloc] initWithDateMinimum:date1 andDateMaximum:date];
  //  NSLog(@"dateRange:  %@ - %@", date1, date);
    // Create a date time axis to use as the x axis.    
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] init];
    // Enable panning and zooming on the x-axis.
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    xAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    xAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    
    chart.xAxis = xAxis;
    [xAxis release];
    //[xRange release];
    
    //Create a number axis to use as the y axis.
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    
    //Enable panning and zooming on Y
    yAxis.enableGesturePanning = NO;
    yAxis.enableGestureZooming = NO;
    yAxis.enableMomentumPanning = NO;
    yAxis.enableMomentumZooming = NO;
    //yAxis.axisLabelsAreFixed = YES;
    // yAxis.majorTickFrequency = YES;
    yAxis.titleLabel.textColor = [UIColor grayColor];
    yAxis.titleLabel.text = @"<<<   Low                    Hi    >>>";
    //yAxis.titleLabel.frame
    yAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    yAxis.style.majorTickStyle.showLabels = NO;
    yAxis.style.majorTickStyle.showTicks = YES;
    
    chart.yAxis = yAxis;
    [yAxis release];
    
    
    //Set the chart title
    chart.title = @"Results";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        chart.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:27.0f];
    } else {
        chart.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:17.0f];
    }
    chart.titleLabel.textColor = [UIColor whiteColor];
    
    // If you have a trial version, you need to enter your licence key here:
    //    chart.licenseKey = @"";
    
    
    
    //Additional legend config
    chart.legend.style.font = [UIFont fontWithName:@"Futura" size:12.0f];
    chart.legend.symbolWidth = [NSNumber numberWithInt:75];
    chart.legend.style.borderColor = [UIColor clearColor];
    
    
    //isLegend = legendSwitch.on;
    isSymbol = symbolSwitch.on;
    isGradient = gradientSwitch.on;

    
    [containerView sendSubviewToBack:loadingView];

    t2LogoImageView.hidden = YES;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        int startHeight = 0;
        int menuHeight = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            startHeight = 512;
            menuHeight = 512;

        } 
        else 
        {
            startHeight = 205;
            menuHeight = 205;
        }
        
        [self showButtons:1];
        
        CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
        CGRect menuRect = CGRectMake(0.0,
                                     startHeight,
                                     menuViewSize.width, menuHeight);
        self.menuView.frame = menuRect;
            
        
        // Add the chart to the view controller
        [chart setAlpha:0.0];
        [menuView setAlpha:0.0];
        [legendView setAlpha:0.0];
        menuView.hidden = NO;
        [containerView addSubview:chart];
        [containerView addSubview:menuView];
        [containerView bringSubviewToFront:menuView];


        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [chart setAlpha:1.0];
        [menuView setAlpha:1.0];
        [UIView commitAnimations];
        
        // Update Legend
        if (isLegend) 
        {
            legendView.hidden = NO;
        }
        else 
        {
            legendView.hidden = YES;
        }
        
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        

        [self showButtons:1];
        
        CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
        CGRect menuRect = CGRectMake(0.0,
                                     0.0,
                                     menuViewSize.width, 320);
        self.menuView.frame = menuRect;
        
        
        [containerView addSubview:chart];
        [containerView bringSubviewToFront:legendView];
        [containerView bringSubviewToFront:menuView];
        menuView.hidden = YES;
        menuShowing = NO;
    }
    

   // [self resetLegend];

}

- (void)showButtons:(int)howMany;
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (howMany == 1) 
    {
        self.navigationItem.rightBarButtonItems = nil;
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClick)];
        self.navigationItem.rightBarButtonItem = actionButton;
        [actionButton release];
        

    }
    else 
    {
        self.navigationItem.rightBarButtonItem = nil;

        
        // NavBar Button
        NSMutableArray *barButtonItemsArray = [[NSMutableArray alloc] init];    
        UIImage *image = [UIImage imageNamed:@"icon-settings.png"];
        
        UIBarButtonItem *optionButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(optionButtonClicked)];
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClick)];
        
        
        
        [barButtonItemsArray addObject:optionButton];
        [barButtonItemsArray addObject:actionButton];
        
        self.navigationItem.rightBarButtonItems = barButtonItemsArray;
        [optionButton release];
        [barButtonItemsArray release];
        [actionButton release];
        

        
    }
}

#pragma mark Legend


- (void)legendButtonClicked
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (isMyLegend) 
    {
        [self resignLegend];
        isMyLegend = NO;
    }
    else 
    {
        [self showLegend];
        isMyLegend = YES;
    } 
}

- (IBAction) legendButtonClicked:(id)sender
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [self legendButtonClicked];
}


- (void)resetLegend
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [legendView removeFromSuperview];
    int startWidth = 0;

    NSString *version = [UIDevice currentDevice].systemVersion;
	if ([version compare:@"3.2"] != kCFCompareLessThan) {
		self.legendSwipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)] autorelease];
		self.legendSwipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)] autorelease];
        
        self.legendTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)] autorelease];
        
		self.legendSwipeRight.delegate = self;
		self.legendSwipeLeft.delegate = self;
        
        self.legendTap.delegate = self;
        
		self.legendSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
		
		[legendView addGestureRecognizer:self.legendSwipeRight];
		[legendView addGestureRecognizer:self.legendSwipeLeft];	
        [legendView addGestureRecognizer:self.legendTap];	
        
        [legendSwipeLeft release];
        [legendTap release];
        [legendSwipeRight release];
	}
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        // iPad
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 768;
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 1024;
        }
        //
        // compute the start frame
        CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(startWidth - 46,
                                      0.0,
                                      legendViewSize.width, legendViewSize.height); 
        
        self.legendView.frame = startRect;
    }
    else 
    {
        // iPhone
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 320;
            NSLog(@"PORTRAIT");

            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 480;
            NSLog(@"LANDSCAPE");

        }

        
        //
        // compute the start frame
        CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        NSLog(@"startWidth3: %i", startWidth - 46);
        CGRect startRect = CGRectMake(startWidth - 46,
                                      0.0,
                                      legendViewSize.width, legendViewSize.height);  
        
        self.legendView.frame = startRect;
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
    {
        [containerView addSubview:legendView];
        [containerView bringSubviewToFront:legendView];
        NSLog(@"bring legen view to front");
    }
    else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
    {
        if (!menuShowing) 
        {
            [containerView addSubview:legendView];
            [containerView bringSubviewToFront:legendView];

        }    
    }
    
    NSLog(@"legendSwitch.on2: %i", isLegend);
    if (isLegend) 
    {
        legendView.hidden = NO;
        [legendView setAlpha:1.0];

    }
    else 
    {
        legendView.hidden = YES;
        [legendView setAlpha:1.0];

    }

}

- (void)showLegend
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

  //  NSLog(@"groupsArray: %@", groupsArray);
    //legendView.hidden = NO;
    int legendItemCount = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsKey = @"";
    BOOL val;
    for (Group *aGroup in groupsArray) 
    {
        
        defaultsKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",aGroup.title];
        
        if (![defaults objectForKey:defaultsKey]) 
        {
            val = YES;
        }
        else 
        {
            val = [defaults boolForKey:defaultsKey];				
        }
        
        if (val) 
        {
            legendItemCount++;
        }
	}
    
    int startHeight = 0;
    int addSize = 44 * legendItemCount;
    
    startHeight = startHeight + addSize;
   // NSLog(@"startHeight: %i", startHeight);
    
    if (legendItemCount < 3) 
    {
        startHeight = 44 * 3;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        // iPad
        int startWidth = 0;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 768;
            if (startHeight > 1024) 
            {
                startHeight = 1024;
                _legendTableView.userInteractionEnabled = YES;
                
            }
            else 
            {
                _legendTableView.userInteractionEnabled = NO;
                startHeight = startHeight; 
            }
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 1024;
            if (startHeight > 768) 
            {
                startHeight = 768;
                _legendTableView.userInteractionEnabled = YES;
            }
            else 
            {
                startHeight = startHeight; 
                _legendTableView.userInteractionEnabled = NO;
            }
        }
        
        //
        // compute the start frame
        CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(startWidth - 46,
                                      0.0,
                                      legendViewSize.width, startHeight);
        self.legendView.frame = startRect;
        // compute the end frame
        CGRect endRect = CGRectMake(startWidth - legendViewSize.width,
                                    0.0,
                                    legendViewSize.width,
                                    startHeight);
        
        
        [containerView bringSubviewToFront:legendView]; 
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.legendView.frame = endRect;
        [UIView commitAnimations];
        
        
    } 
    else 
    {
        // iPhone/iPod
        int startWidth = 0;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
      
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 320;
            if (startHeight > 205) 
            {
                startHeight = 205;
                _legendTableView.userInteractionEnabled = YES;
            }
            else 
            {
                startHeight = startHeight; 
                _legendTableView.userInteractionEnabled = NO;
            }
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 480;
            
           // NSLog(@"startWidth2: %i", startWidth);
            if (startHeight > 280) 
            {
                startHeight = 280;
                _legendTableView.userInteractionEnabled = YES;
            }
            else 
            {
                startHeight = startHeight; 
                _legendTableView.userInteractionEnabled = NO;
            }
        }
        //
        // compute the start frame
        CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(startWidth  - 46,
                                      0.0,
                                      legendViewSize.width, startHeight);
        self.legendView.frame = startRect;
        // compute the end frame
        CGRect endRect = CGRectMake(startWidth - legendViewSize.width,
                                    0.0,
                                    legendViewSize.width,
                                    startHeight);
        
        
        [containerView bringSubviewToFront:legendView]; 
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.legendView.frame = endRect;
        [UIView commitAnimations];
        
    }
}

- (void)resignLegend
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        
        int startWidth = 0;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
         
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 768;
            
        }  
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 1024;
            
        }
        
        
        //CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        
        CGRect endFrame = self.legendView.frame;
        endFrame.origin.x = startWidth - 46;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        // [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.legendView.frame = endFrame;
        [UIView commitAnimations];
    } 
    else 
    {
        int startWidth = 0;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            startWidth = 320;
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            startWidth = 480;
            
        }
        
        
        //CGSize legendViewSize = [self.legendView sizeThatFits:CGSizeZero];
        
        CGRect endFrame = self.legendView.frame;
        endFrame.origin.x = startWidth - 46;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        // [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.legendView.frame = endFrame;
        [UIView commitAnimations];
        
    }
    
}

- (void) loadingSymbol
{
    [containerView bringSubviewToFront:loadingView];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self 
                                   selector:@selector(symbolToggle) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void) loadingGradient
{
    
    [containerView bringSubviewToFront:loadingView];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self 
                                   selector:@selector(gradientToggle) 
                                   userInfo:nil 
                                    repeats:NO];
}
    

- (void)legendToggle
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self showButtons:2];
    BOOL storedVal;
    NSString *key;
    key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
    if (![defaults boolForKey:key]) {
        storedVal = NO;
    }
    else {
        storedVal = [defaults boolForKey:key];				
    }
    
    // Update Legend
    if (storedVal) 
    {
        // Reload buttons
        legendView.hidden = NO;
        isLegend = YES;
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            [self showButtons:1];
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            [self showButtons:2];
            
        }
        
    }
    else 
    {
        // Reload buttons
        legendView.hidden = YES;
        isLegend = NO;
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            [self showButtons:1];
            
        }
        else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            [self showButtons:2];
        }   
    }
    
    //doUpdate = YES;
}

- (void)symbolToggle
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    double xMin, xMax, yMin, yMax;
    xMin = [chart.xAxis.axisRange.minimum doubleValue];
    xMax = [chart.xAxis.axisRange.maximum doubleValue];
    yMin = [chart.yAxis.axisRange.minimum doubleValue];
    yMax = [chart.yAxis.axisRange.maximum doubleValue];
    
    // Change series type
    [datasource toggleSymbol];
    
    // Reload data
    [chart reloadData];
    [chart layoutSubviews];
    
    // Restore axes' ranges
    [chart.xAxis setRangeWithMinimum:[NSNumber numberWithDouble: xMin] andMaximum:[NSNumber numberWithDouble: xMax] withAnimation:NO];
    [chart.yAxis setRangeWithMinimum:[NSNumber numberWithDouble: yMin] andMaximum:[NSNumber numberWithDouble: yMax] withAnimation:NO];
    
    // Redraw chart
    [chart redrawChartAndGL: YES];
    [containerView sendSubviewToBack:loadingView];

}

- (void)gradientToggle
{

    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    double xMin, xMax, yMin, yMax;
    xMin = [chart.xAxis.axisRange.minimum doubleValue];
    xMax = [chart.xAxis.axisRange.maximum doubleValue];
    yMin = [chart.yAxis.axisRange.minimum doubleValue];
    yMax = [chart.yAxis.axisRange.maximum doubleValue];
    
    // Change series type
    [datasource toggleGradient];
    
    // Reload data
    [chart reloadData];
    [chart layoutSubviews];
    
    // Restore axes' ranges
    [chart.xAxis setRangeWithMinimum:[NSNumber numberWithDouble: xMin] andMaximum:[NSNumber numberWithDouble: xMax] withAnimation:NO];
    [chart.yAxis setRangeWithMinimum:[NSNumber numberWithDouble: yMin] andMaximum:[NSNumber numberWithDouble: yMax] withAnimation:NO];
    
    // Redraw chart
    [chart redrawChartAndGL: YES];
    [containerView sendSubviewToBack:loadingView];

}

-(void)switchSeriesType 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    double xMin, xMax, yMin, yMax;
    xMin = [chart.xAxis.axisRange.minimum doubleValue];
    xMax = [chart.xAxis.axisRange.maximum doubleValue];
    yMin = [chart.yAxis.axisRange.minimum doubleValue];
    yMax = [chart.yAxis.axisRange.maximum doubleValue];
    
    // Change series type
    [datasource toggleSeriesType];
    
    chart.legend.hidden = NO;
    // Reload data
    [chart reloadData];
    [chart layoutSubviews];
    
    // Restore axes' ranges
    [chart.xAxis setRangeWithMinimum:[NSNumber numberWithDouble: xMin] andMaximum:[NSNumber numberWithDouble: xMax] withAnimation:NO];
    [chart.yAxis setRangeWithMinimum:[NSNumber numberWithDouble: yMin] andMaximum:[NSNumber numberWithDouble: yMax] withAnimation:NO];
    
    // Redraw chart
    [chart redrawChartAndGL: YES];
}

#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        if (!isPortrait) 
        {
            NSLog(@"ORIENTATION: Portrait: %i", isPortrait);

            int chartHeight = 0;
            int menuHeight = 0;
            int menuStart = 0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
            {
                chartHeight = 512;
                menuStart = 512;
                menuHeight = 512;
            } 
            else 
            {
                // iPhone
                chartHeight = 211;
                menuStart = 211;
                menuHeight = 205;
            }
            chart.alpha = 0.0f;
//            [chart removeFromSuperview];
            
            
            CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
            CGRect chartRect = CGRectMake(0.0,
                                          0.0,
                                          chartViewSize.width, chartHeight); 
            
            chart.frame = chartRect;
            [self showButtons:1];
            
            CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
            CGRect menuRect = CGRectMake(0.0,
                                         menuStart,
                                         menuViewSize.width, menuHeight);
            self.menuView.frame = menuRect;
            
            menuView.hidden = NO;
            [menuView setAlpha:1.0];
            chart.alpha = 1.0f;
//            [containerView addSubview:chart];
//            [containerView bringSubviewToFront:legendView];
//            [containerView bringSubviewToFront:menuView];
            
            [self slideDownDidStop];
           // [self resetLegend];
            
            isPortrait = YES;
        }        
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        if (isPortrait) 
        {
            int chartHeight = 0;
            int menuHeight = 0;
            int menuStart = 0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
            {
                chartHeight = 700;
                menuStart = 0;
                menuHeight = 700;
            } 
            else 
            {
                // iPhone
                chartHeight = 260;
                menuStart = 0;
                menuHeight = 320;
            } 
            chart.alpha = 0.0f;
//            [chart removeFromSuperview];

            NSLog(@"ORIENTATION: Landscape: %i", isPortrait);
            CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          0.0,
                                          chartViewSize.width, chartHeight); 
            
            chart.frame = startRect;
            [self showButtons:1];
            
            CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
            CGRect menuRect = CGRectMake(0.0,
                                         menuStart,
                                         menuViewSize.width, menuHeight);
            self.menuView.frame = menuRect;
            
            chart.alpha = 1.0f;
//            [containerView addSubview:chart];
//            [containerView bringSubviewToFront:legendView];
//            [containerView bringSubviewToFront:menuView];
            menuView.hidden = YES;
            menuShowing = NO;
            
            [self slideDownDidStop];
          //  [self resetLegend];
            isPortrait = NO;
        }

    }
    
    
}



#pragma mark switch

-(void)createSwitches 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	if (self.switchDictionary == nil) {
		self.switchDictionary = [NSMutableDictionary dictionary];
		
		NSInteger switchWidth = 96;
		NSInteger height = 24;
		NSInteger xOff = 8;
		NSInteger yOff = 8;
		
		CGRect switchRect = CGRectMake(xOff, yOff , switchWidth, height);
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL storedVal;
		NSString *key;
		
		NSArray *grpArray = [[self.groupsDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		for (NSString *groupTitle in grpArray) {			
			UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchRect];
			key = [NSString stringWithFormat:@"SWITCH_STATE_%@",groupTitle];
			if (![defaults objectForKey:key]) {
				storedVal = YES;
			}
			else {
				storedVal = [defaults boolForKey:key];				
			}
            
			aSwitch.on = storedVal;
			aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
			[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
			
			[self.switchDictionary setValue:aSwitch forKey:groupTitle];
			[aSwitch release];
		}
	}
}

-(void)switchFlipped:(id)sender 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [containerView bringSubviewToFront:loadingView];
    loadingLabel.text = @"";
   //  dispatch_async(backgroundQueue, ^(void) {
   // [self switchProcess];
   //  }); 
    [containerView bringSubviewToFront:loadingView];
    
    
	NSEnumerator *enumerator = [self.switchDictionary keyEnumerator];
	id key;
	
	UISwitch *currentValue;
	NSString *switchTitle = @"";
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
	while ((key = [enumerator nextObject])) 
    {
		currentValue = [self.switchDictionary objectForKey:key];
		if (currentValue == sender) 
        {
			switchTitle = key;
			defaultsKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",switchTitle];
			BOOL val = ((UISwitch *)currentValue).on;
			[defaults setBool:val forKey:defaultsKey];
			[defaults synchronize];
			NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:switchTitle, [NSNumber numberWithBool:val],nil];
			[FlurryUtility report:EVENT_GRAPHRESULTS_SWITCHFLIPPED withData:usrDict]; 
            
		}
	}


    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self 
                                            selector:@selector(switchProcess) 
                                            userInfo:nil 
                                             repeats:NO];
    
}

#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        //    NSLog(@"Ummm.");
        
    } 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    NSLog(@"button press: %i", buttonIndex);
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        // Save
        NSLog(@"Save CSV");
        loadingLabel.text = @"Saving to Photo Gallery";
        [containerView bringSubviewToFront:loadingView]; 
        // Delay to prevent block
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(saveToGallery)
                                       userInfo:nil
                                        repeats:NO];
        
    } 
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        // Email Screenshot
        NSLog(@"Email Screenshot");
        [self emailResults];
        
    }
    
    
}

#pragma mark UI Helper Methods

- (void)saveToGallery
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    UIImage *screenshot = [chart snapshot];
    UIImageWriteToSavedPhotosAlbum(screenshot,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL); // you generally won't need a contextInfo here
    
    [containerView sendSubviewToBack:loadingView];
    
}

- (void)shareClick
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle:@"" 
                                   delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                                   destructiveButtonTitle:nil 
                                   otherButtonTitles:@"Save to Photo Gallery", @"Email Screenshot", nil] autorelease];
    [actionSheet showInView:self.view];  
}



- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInf
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (error) 
    {
        NSLog(@"Error");// Do anything needed to handle the error or display it to the user
    } 
    else 
    {
        NSLog(@"Saved");
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}


#pragma mark Refresh Chart
// Main chart options button 
- (void)optionButtonClicked
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (!menuShowing) 
    {
        menuView.hidden = NO;
        NSLog(@"show menu!");
        // Show
        [menuView setAlpha:0.0];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [menuView setAlpha:1.0];
        
        [UIView commitAnimations];
        
        [containerView bringSubviewToFront:menuView];
        
        
        menuShowing = YES;
        
        
    }
    else 
    {
        
        //Hide
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [menuView setAlpha:0.0];
        
        [UIView commitAnimations];
        
        [NSTimer scheduledTimerWithTimeInterval:0.3
                                         target:self
                                       selector:@selector(sendMenuToBack)
                                       userInfo:nil
                                        repeats:NO];
        
        
        
        
        menuShowing = NO;
        
        menuView.hidden = YES;
        
        [containerView addSubview:legendView];
    }
}

- (void)sendMenuToBack
{
   // [containerView sendSubviewToBack:menuView];
   // [containerView sendSubviewToBack:loadingView];
}


- (void)switchProcess
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    // Change series type
    double xMin, xMax, yMin, yMax;
    xMin = [chart.xAxis.axisRange.minimum doubleValue];
    xMax = [chart.xAxis.axisRange.maximum doubleValue];
    yMin = [chart.yAxis.axisRange.minimum doubleValue];
    yMax = [chart.yAxis.axisRange.maximum doubleValue];
    
    // Change series type
    [datasource toggleSeries];

    // Reload data
    [chart reloadData];
    [chart layoutSubviews];
    
    // Restore axes' ranges
    [chart.xAxis setRangeWithMinimum:[NSNumber numberWithDouble: xMin] andMaximum:[NSNumber numberWithDouble: xMax] withAnimation:NO];
    [chart.yAxis setRangeWithMinimum:[NSNumber numberWithDouble: yMin] andMaximum:[NSNumber numberWithDouble: yMax] withAnimation:NO];
    
    // Redraw chart
    [chart redrawChartAndGL: YES]; 
    
    //[self resetLegend];
    //[legendTableViewController refresh];
    [containerView sendSubviewToBack:loadingView];
    
}


#pragma mark groups

- (void)fillGroupsDictionary 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	if (self.groupsDictionary == nil) {
		NSMutableDictionary *groups = [NSMutableDictionary dictionary];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
        
		NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(showGraph == YES)"];
		NSPredicate *visiblePredicate = [NSPredicate predicateWithFormat:@"(visible == YES)"];
		
		NSArray *finalPredicateArray = [NSArray arrayWithObjects:groupPredicate,visiblePredicate, nil];
		NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
        
        [NSFetchedResultsController deleteCacheWithName:nil]; 
		[fetchRequest setPredicate:finalPredicate];
        
		NSError *error = nil;
		NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			[Error showErrorByAppendingString:@"Unable to get Categories to graph" withError:error];
		}
		
		[fetchRequest release];
		
		for (Group *aGroup in objects) {
			[groups setObject:aGroup forKey:aGroup.title];
		}			
		self.groupsDictionary = [NSDictionary dictionaryWithDictionary:groups];
		
		NSArray *keys = [self.groupsDictionary allKeys];
		NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		
		NSMutableArray *grpArray = [NSMutableArray array];
		for (NSString *groupName in sortedKeys) {
			[grpArray addObject:[self.groupsDictionary objectForKey:groupName]];
		}
		self.groupsArray = [NSArray arrayWithArray:grpArray];
	}
}

#pragma mark colors

-(UIColor *)UIColorForIndex:(NSInteger)index 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	NSArray *colorsArray = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor grayColor], [UIColor brownColor], [UIColor cyanColor], [UIColor magentaColor], [UIColor lightGrayColor], nil];
	
	UIColor *color = nil;
	
    // Perm fix for color bug from v2.0; 5/17/2012 Mel Manzano
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
	}
    else // If index is > color array count, then start over.
    {
        // Split index into digits via array
        NSString *stringNumber = [NSString stringWithFormat:@"%i", index];
        NSMutableArray *digits = [NSMutableArray arrayWithCapacity:[stringNumber length]];
        const char *cstring = [stringNumber cStringUsingEncoding:NSASCIIStringEncoding];
        while (*cstring) {
            if (isdigit(*cstring)) {
                [digits addObject:[NSString stringWithFormat:@"%c", *cstring]];
            }
            cstring++;
        }
        
        // Take Last digit in array and use for color selection
        int lastDigit = [digits count] - 1;
        int overCount = [[digits objectAtIndex:lastDigit] intValue];
        color = [colorsArray objectAtIndex:overCount];
    }
    
	return color;
}


- (void)fillColors 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	if (self.ledgendColorsDictionary == nil) {
		self.ledgendColorsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.groupsDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
			UIColor *color = [self UIColorForIndex:index];
			[self.ledgendColorsDictionary setObject:color forKey:groupTitle];
			index++;
		}
	}
    
    // NSLog(@"colorDict: %@", ledgendColorsDictionary);
}

-(UIImage *)UIImageForIndex:(NSInteger)index 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Symbol_Clover.png"], [UIImage imageNamed:@"Symbol_Club.png"], [UIImage imageNamed:@"Symbol_Cross.png"], [UIImage imageNamed:@"Symbol_Davidstar.png"], [UIImage imageNamed:@"Symbol_Diamondclassic.png"], [UIImage imageNamed:@"Symbol_Diamondring.png"], [UIImage imageNamed:@"Symbol_Doublehook.png"], [UIImage imageNamed:@"Symbol_Fivestar.png"], [UIImage imageNamed:@"Symbol_Heart.png"], [UIImage imageNamed:@"Symbol_Triangle.png"], [UIImage imageNamed:@"Symbol_Circle.png"], [UIImage imageNamed:@"Symbol_Hourglass.png"], [UIImage imageNamed:@"Symbol_Moon.png"], [UIImage imageNamed:@"Symbol_Skew.png"], [UIImage imageNamed:@"Symbol_Pentagon.png"], [UIImage imageNamed:@"Symbol_Spade.png"], nil];	
	UIImage *image = nil;
	//NSLog(@"imageArray: %@", imageArray);
    // Perm fix for color bug from v2.0; 5/17/2012 Mel Manzano
	if (index >=0 && index < [imageArray count]) {
		image = [imageArray objectAtIndex:index];
		[[image retain] autorelease];
	}
    else // If index is > color array count, then start over.
    {
        // Split index into digits via array
        NSString *stringNumber = [NSString stringWithFormat:@"%i", index];
        NSMutableArray *digits = [NSMutableArray arrayWithCapacity:[stringNumber length]];
        const char *cstring = [stringNumber cStringUsingEncoding:NSASCIIStringEncoding];
        while (*cstring) {
            if (isdigit(*cstring)) {
                [digits addObject:[NSString stringWithFormat:@"%c", *cstring]];
            }
            cstring++;
        }
        
        // Take last digit in array and use for color selection
        int lastDigit = [digits count] - 1;
        int overCount = [[digits objectAtIndex:lastDigit] intValue];
        image = [imageArray objectAtIndex:overCount];
    }
    
	return image;
}

#pragma mark Options Dictionary

- (void)fillOptions
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL storedVal;
    NSString *key;
    
    
    // Fetch User Defaults for Legend
    key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
    if (![defaults boolForKey:key]) {
        storedVal = NO;
    }
    else {
        storedVal = [defaults boolForKey:key];				
    }
    isLegend = storedVal;
    NSLog(@"SWITCH_OPTION_STATE_LEGEND: %i", isLegend);

    
}


#pragma mark Symbols Dictionary
- (void)fillSymbols
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	if (self.symbolsDictionary == nil) {
		self.symbolsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.groupsDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
            
			UIImage *image = [self UIImageForIndex:index];
            
			[self.symbolsDictionary setObject:image forKey:groupTitle];
			index++;
		}
	}    
    // NSLog(@"symbolsDictionary: %@", symbolsDictionary);
}

#pragma mark Segment Menu
- (IBAction)segmentIndexChanged 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    switch (segmentButton.selectedSegmentIndex) {
		case 0:
            //  NSLog(@"Categories:");
            if (self.notesTable != nil) {
				self.notesTable.view.hidden = YES;
			}
            isOptions = NO;
            optionView.hidden = YES;
            _tableView.hidden = NO;
            noteView.hidden = YES;
            
            
			break;
		case 1:

            noteView.hidden = NO;
            optionView.hidden = YES;
            _tableView.hidden = YES;	
            
            
            break;
		case 2:
            if (self.notesTable != nil) {
				self.notesTable.view.hidden = YES;
			}
            isOptions = YES;
            optionView.hidden = NO;
            _tableView.hidden = YES;
            noteView.hidden = YES;
            
			break;            
	}
}

#pragma mark Range Picker
- (void)resignPicker
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView_iPad.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView_iPad.frame = endFrame;
        [UIView commitAnimations];
    }
    else 
    {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView.frame = endFrame;
        [UIView commitAnimations];
        
    }
        
    [self showButtons:1];    
	
	NSIndexPath *indexPath = [self._optionsTableView indexPathForSelectedRow];
    [_optionsTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (doUpdate) 
    {
        [self reloadGraph];
    }

}

- (void)slideDownDidStop
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

	// the date picker has finished sliding downwards, so remove it
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        [self.pickerView_iPad removeFromSuperview];
    }
    else 
    {
        [self.pickerView removeFromSuperview];
    }
}
- (IBAction)doneAction:(id)sender
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    [self resignPicker];
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    NSString *pickedRange = [pickerArray objectAtIndex:row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsKey;
    
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_RANGE"];
    NSString *oldRange = [defaults objectForKey:defaultsKey];
    
    [defaults setObject:pickedRange forKey:defaultsKey];
    [defaults synchronize];
    
    // Set to UPDATE if selection changed
    if (![pickedRange isEqualToString:oldRange]) 
    {
        doUpdate = YES;
    }
    
    NSLog(@"picked: %@", [defaults objectForKey:defaultsKey]);
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [pickerArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [pickerArray objectAtIndex:row];
} 

- (void) showPicker
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);    
    
    int startHeight = 0;
    int startWeight = 0;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        startHeight = 280;
        startWeight = 768;
        
        // check if our rangePicker is already on screen
        if (self.pickerView_iPad.superview == nil)
        {
            
            [self.view addSubview: self.pickerView_iPad];
            // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
            //
            // compute the start frame
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGSize pickerSize = [self.pickerView_iPad sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          startWeight, pickerSize.height);
            self.pickerView_iPad.frame = startRect;
            // compute the end frame
            CGRect pickerRect = CGRectMake(0.0,
                                           screenRect.size.height - pickerSize.height - 44,
                                           startWeight,
                                           pickerSize.height);
            // start the slide up animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            
            self.pickerView_iPad.frame = pickerRect;
            
            // shrink the table vertical size to make room for the date picker
            //CGRect newFrame = self.containerView.frame;
            //newFrame.size.height -= self.rangePicker.frame.size.height;
            //self.containerView.frame = newFrame;
            [UIView commitAnimations];
            
            // add the "Done" button to the nav bar
            self.navigationItem.rightBarButtonItem = nil;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey;
            
            defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_RANGE"];
            NSString *theRange = [defaults objectForKey:defaultsKey];
            int whatRow = 3;
            if ([theRange isEqualToString:@"30 days"]) 
            {
                whatRow = 0;
            }
            else if ([theRange isEqualToString:@"90 days"])  
            {
                whatRow = 1;
            }
            else if ([theRange isEqualToString:@"180 days"])  
            {
                whatRow = 2;
            }
            else if ([theRange isEqualToString:@"1 year"]) 
            {
                whatRow = 3;
            }
            else 
            {
                whatRow = 0;
            }
            
            
            [self.rangePicker selectRow:whatRow inComponent:0 animated:YES];
            // self.navigationItem.rightBarButtonItem = self.doneButton;
        }
    }
    else 
    {
        //iPhone
        startHeight = 280;
        startWeight = 320;

        
        // check if our rangePicker is already on screen
        if (self.pickerView.superview == nil)
        {
            
            [self.view addSubview: self.pickerView];
            // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
            //
            // compute the start frame
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          startWeight, pickerSize.height);
            self.pickerView.frame = startRect;
            // compute the end frame
            CGRect pickerRect = CGRectMake(0.0,
                                           screenRect.size.height - pickerSize.height - 44,
                                           startWeight,
                                           pickerSize.height);
            // start the slide up animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            
            self.pickerView.frame = pickerRect;
            
            // shrink the table vertical size to make room for the date picker
            //CGRect newFrame = self.containerView.frame;
            //newFrame.size.height -= self.rangePicker.frame.size.height;
            //self.containerView.frame = newFrame;
            [UIView commitAnimations];
            
            // add the "Done" button to the nav bar
            self.navigationItem.rightBarButtonItem = nil;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey;
            
            defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_RANGE"];
            NSString *theRange = [defaults objectForKey:defaultsKey];
            int whatRow = 3;
            if ([theRange isEqualToString:@"30 days"]) 
            {
                whatRow = 0;
            }
            else if ([theRange isEqualToString:@"90 days"])  
            {
                whatRow = 1;
            }
            else if ([theRange isEqualToString:@"180 days"])  
            {
                whatRow = 2;
            }
            else if ([theRange isEqualToString:@"1 year"]) 
            {
                whatRow = 3;
            }
            else 
            {
                whatRow = 0;
            }
            
            
            [self.rangePicker selectRow:whatRow inComponent:0 animated:YES];
            // self.navigationItem.rightBarButtonItem = self.doneButton;
        }
    }


}


- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color
{
    // Load the image
    // NSString *name = @"Symbol_Clover.png";
    UIImage *img = name;
    
    // Begin new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // Get reference to context created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the fill color
    [color setFill];
    
    // Translate/flip graphics context
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set the blend mode to colorburn, and the original image
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    // Generate a new UIImage from the graphics context we draw onto
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

#pragma mark tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    
    numberOfRows = [self.groupsArray count];
    
    
	return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d, %d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
    
	NSInteger row = [indexPath indexAtPosition:1];
    
    
    Group *group = [self.groupsArray objectAtIndex:row];
    NSString *groupName = group.title;
    UISwitch *aSwitch = [self.switchDictionary objectForKey:groupName];
    
    // Fetch saved user symbols/colors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    // the image
    UIImage *image = [self UIImageForIndex:[[tSymbolDict objectForKey:group.title] intValue]];
    // the color
    NSData *data = [tColorDict objectForKey:group.title];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (data != nil) 
    {
        cell.imageView.image = [self imageNamed:image withColor:color];
        
        // Gesture Recognizer for custom symbol click
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)] autorelease];
        [cell.imageView addGestureRecognizer:tapGesture];
        cell.imageView.userInteractionEnabled = YES;
    }
    
    cell.textLabel.text = groupName;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textAlignment = UITextAlignmentRight;
    
    cell.accessoryView = aSwitch;
    

}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger row = [indexPath indexAtPosition:1];
    
    Group *group = [self.groupsArray objectAtIndex:row];
    NSString *groupName = group.title;
     NSLog(@"before pop");
    SGraphViewController *sGraphViewController = [[SGraphViewController alloc] initWithNibName:@"SGraphViewController" bundle:nil];
    sGraphViewController.groupName = groupName;
    [self.navigationController pushViewController:sGraphViewController animated:YES];
    [sGraphViewController release];
   
    // [self optionButtonClicked];
    
}

- (void) imageTapped:(UITapGestureRecognizer *)gesture
{
    UITableViewCell *cell = [[[gesture view] superview] superview];
    NSIndexPath *tappedIndexPath = [self._tableView indexPathForCell:cell];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UITableViewCell *myCell = [_tableView cellForRowAtIndexPath:tappedIndexPath];
    

    NSString *editGroupName = myCell.textLabel.text;
    
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    NSData *data = [tColorDict objectForKey:editGroupName];
    // the color
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    HRColorPickerViewController* controller;
    controller = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:color];
    controller.groupName = editGroupName;
    controller.subName = @"";
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];    
    
    
    NSLog(@"image tap %@", myCell.textLabel.text);
    
}

#pragma mark Email delegates

- (void)emailResults
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    // Fetch filtered data
    NSLog(@"Fetching data...");
    
    // Open mail view
    MailData *data = [[MailData alloc] init];
    data.mailRecipients = nil;
    NSString *subjectString = @"T2 Mood Tracker App Graph Results";
    data.mailSubject = subjectString;
    NSString *filteredResults = @"";
    NSString *bodyString = @"T2 Mood Tracker App Graph Results:<p>";
    
    data.mailBody = [NSString stringWithFormat:@"%@%@", bodyString, filteredResults];
    
    // [FlurryUtility report:EVENT_EMAIL_RESULTS_PRESSED];
    
    [self sendMail:data];
    [data release];
    
}

-(void)sendMail:(MailData *)data {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) {
			[self displayComposerSheetWithMailData:data];
		}
		else {
			[self launchMailAppOnDeviceWithMailData:data];
		}		
	}
	else {
		[self launchMailAppOnDeviceWithMailData:data];
	}
    
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	if (result  == MFMailComposeResultCancelled) {
		//[FlurryUtility report:EVENT_MAIL_CANCELED];
	}
	else if(result == MFMailComposeResultSaved) {
		//[FlurryUtility report:EVENT_MAIL_SAVED];
	}
	else if(result == MFMailComposeResultSent) {
		//[FlurryUtility report:EVENT_MAIL_SENT];
	}
	else if(result == MFMailComposeResultFailed) {
		//[FlurryUtility report:EVENT_MAIL_ERROR];
	}
	[self dismissModalViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetWithMailData:(MailData *)data
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (data.mailSubject != nil) {
		[picker setSubject:data.mailSubject];
	}
	
	// Set up recipients
	if (data.mailRecipients != nil) {
		[picker setToRecipients:data.mailRecipients];
	}
    
    // Image
    UIImage *screenshot = [chart snapshot];
    NSData *imageData = UIImagePNGRepresentation(screenshot);
    [picker addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot"]; 
    
    
    
	if (data.mailBody != nil) {
		[picker setMessageBody:data.mailBody isHTML:YES];
	}
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDeviceWithMailData:(MailData *)data {
	NSString *body = @"&body=";
	if (data.mailBody != nil) {
		body = [NSString stringWithFormat:@"%@%@",body,data.mailBody];
	}
	
	//TODO: Test on 3.1.2 device
	NSString *recipients = @"";
	if (data.mailRecipients != nil) {
		for (NSString *recipient in data.mailRecipients) {
			if (![recipients isEqual:@""]) {
				recipients = [NSString stringWithFormat:@"%@,%@",recipients,recipient];
			}
			else {
				recipients = [NSString stringWithFormat:@"%@%@",recipients,recipient];	  
			}
		}
	}
	
	recipients = [NSString stringWithFormat:@"mailto:%@",recipients];
	
	NSString *subject = @"&subject=";
	if (data.mailSubject != nil) {
		data.mailSubject = [NSString stringWithFormat:@"%@%@",subject,data.mailSubject];
	}
	
	NSString *email = [NSString stringWithFormat:@"%@%@%@", recipients, subject, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(void)dealloc {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    dispatch_release(backgroundQueue);
    [chart release];
    [datasource release];
    [optionsTableViewController release];
    [notesTableViewController release];
    [legendTableViewController release];
    [managedObjectContext release];
    [switchDictionary release];
	[ledgendColorsDictionary release];
	[groupsDictionary release];
    [groupsArray release];
    [pickerArray release];
    [symbolsDictionary release];
    [legendSwipeRight release];
	[legendSwipeLeft release];
    [legendTap release];
    [super dealloc];
}



@end
