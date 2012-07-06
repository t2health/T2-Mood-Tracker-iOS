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
#import "HRColorUtil.h"
#import "LegendTableViewController.h"
#import "NotesTableViewController.h"

@implementation GraphViewController

@synthesize menuView, containerView, graphView, notesTable, noteView;
@synthesize managedObjectContext;

@synthesize switchDictionary, menuBar, loadingLabel;
@synthesize ledgendColorsDictionary, legendTap, legendSwipeRight, legendSwipeLeft;
@synthesize groupsDictionary, groupsArray;
@synthesize t2LogoImageView, loadingView, symbolsDictionary,legendButton;
@synthesize _tableView, optionView, legendSwitch, symbolSwitch, gradientSwitch;
@synthesize optionsDictionary, legendView, legendTableViewController, _legendTableView, notesTableViewController, _notesTableView;

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

#pragma mark - Load/Init
- (void)viewDidLoad
{
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
    
    backgroundQueue = dispatch_queue_create("org.t2health.moodtracker.bgqueue", NULL);        
    [containerView bringSubviewToFront:loadingView];

    [self initSetup];
    
}

- (void)initSetup
{
    dispatch_async(backgroundQueue, ^(void) {
        [self getDatasource];
    }); 
    
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) 
    {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
    }
    [super viewWillDisappear:animated];
}


#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        //    NSLog(@"Ummm.");
        
    } 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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
    UIImage *screenshot = [chart snapshot];
    UIImageWriteToSavedPhotosAlbum(screenshot,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL); // you generally won't need a contextInfo here
    
    [containerView sendSubviewToBack:loadingView];
    
}

- (void)shareClick
{
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

#pragma mark Custom Chart
- (void)customChartClick
{
    ChartOptionsViewController *chartOptionsViewController = [[ChartOptionsViewController alloc] initWithNibName:@"ChartOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:chartOptionsViewController animated:YES];
    [chartOptionsViewController release];
    
    isRefreshTable = YES;
    
    
    
}

- (IBAction) customChartButtonClick:(id)sender
{
    [self customChartClick];
}


#pragma mark Refresh Chart
// Main chart options button 
- (void)optionButtonClicked
{
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
        /*
        if (doUpdate) 
        {
            loadingLabel.text = @"Updating Chart";
            [containerView bringSubviewToFront:loadingView]; 
             [self resignLegend];
            dispatch_async(backgroundQueue, ^(void) {
                [self getDatasourceReload];
            });   
            doUpdate = NO;
        }
         */
    }
}

- (void)sendMenuToBack
{
    [containerView sendSubviewToBack:menuView];
}



#pragma mark Graph Menu 

- (void)getDatasourceReload
{
    datasource = [[GraphDataSource alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self reloadData];
    });
    
}

- (void)reloadData
{
    double xMin, xMax, yMin, yMax;
    xMin = [chart.xAxis.axisRange.minimum doubleValue];
    xMax = [chart.xAxis.axisRange.maximum doubleValue];
    yMin = [chart.yAxis.axisRange.minimum doubleValue];
    yMax = [chart.yAxis.axisRange.maximum doubleValue];
    
    // Give the chart the data source
    chart.datasource = datasource;
    
    // Update Series
    if (doSeries) 
    {
        if ([[switchDictionary allKeys] count] > 0) 
        {
            [datasource toggleSeriesOn:switchDictionary];
        }
    }
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSString *defaultsKey;
    [legendTableViewController refresh];
    
    // defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_SYMBOL"];
    isLegend = legendSwitch.on;
    isSymbol = symbolSwitch.on;
    isGradient = gradientSwitch.on;
    
   // [self resetLegend];

    
    // Update Legend
    if (isLegend) 
    {
        // Reload buttons
        legendView.hidden = NO;
        [self showButtons:1];
    }
    else 
    {
        // Reload buttons
        legendView.hidden = YES;
        [self showButtons:1];
    }
    
    // Update Gradient
    if (isGradient) 
    {
       // [datasource toggleGradient:YES];
    }
    else 
    {
      //  [datasource toggleGradient:NO];
    }    
    
    // Update Symbols
    if (isSymbol) 
    {
       // [datasource toggleSymbol:YES];
    }
    else 
    {
        //[datasource toggleSymbol:NO];
    }    
    
    // Reload data
    [chart reloadData];
    [chart layoutSubviews];
    
    // Restore axes' ranges
    [chart.xAxis setRangeWithMinimum:[NSNumber numberWithDouble: xMin] andMaximum:[NSNumber numberWithDouble: xMax] withAnimation:NO];
    [chart.yAxis setRangeWithMinimum:[NSNumber numberWithDouble: yMin] andMaximum:[NSNumber numberWithDouble: yMax] withAnimation:NO];
    
    // Redraw chart
    [chart redrawChartAndGL: YES];
    
    [containerView sendSubviewToBack:loadingView];
    
    [self resetLegend];

}

- (void)setupGraph
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Create the chart
        chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, graphView.bounds.size.width, graphView.bounds.size.height)];
    } else {
        //Create the chart
        
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
        
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
    
    
    // Zooming with Range
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
    [components setDay:([components day] - ([components weekday] - 1))]; 
    [components setDay:([components day] - 7)];
    [components setDay:([components day] - ([components day] -1))]; 
    NSDate *thisMonth = [cal dateFromComponents:components];
    
    
    // Subtract 40 years because of some calendar thing with the chart...i dunno
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:today];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    year = year - 41;
    
    NSDateComponents *dateComponents1 = [calendar components:unitFlags fromDate:thisMonth];
    NSInteger year1 = [dateComponents1 year];
    NSInteger month1 = [dateComponents1 month];
    NSInteger day1 = [dateComponents1 day];
    year1 = year1 - 41;
    
    [calendar release];
    NSString *monthStr = @"";
    NSString *monthStr1 = @"";
    NSString *dayStr = @"";
    NSString *dayStr1 = @"";
    
    
    if ([[NSString stringWithFormat:@"%i",day] length] < 2) 
    {
        dayStr = [NSString stringWithFormat:@"0%i",day];
    }
    else 
    {
        dayStr = [NSString stringWithFormat:@"%i",day];
    }
    
    if ([[NSString stringWithFormat:@"%i",day1] length] < 2) 
    {
        dayStr1 = [NSString stringWithFormat:@"0%i",day1];
    }
    else 
    {
        dayStr1 = [NSString stringWithFormat:@"%i",day1];
    }
    
    if ([[NSString stringWithFormat:@"%i",month] length] < 2) 
    {
        monthStr = [NSString stringWithFormat:@"0%i",month];
    }
    else 
    {
        monthStr = [NSString stringWithFormat:@"%i",month];
    }
    
    if ([[NSString stringWithFormat:@"%i",month1] length] < 2) 
    {
        monthStr1 = [NSString stringWithFormat:@"0%i",month1];
    }
    else 
    {
        monthStr1 = [NSString stringWithFormat:@"%i",month1];
    }
    
    
    NSString *string = [NSString stringWithFormat:@"%@-%@-%i", dayStr, monthStr, year];   
    NSString *string1 = [NSString stringWithFormat:@"%@-%@-%i", dayStr1, monthStr1, year1];  
    
    // Fix for January and first of month bug 
    if ([string isEqualToString:string1]) 
    {
        
        if ([monthStr1 isEqualToString:@"01"]) 
        {
            monthStr1 = @"12";
        }
        else 
        {
            monthStr1 = [NSString stringWithFormat:@"%i",[monthStr1 intValue] - 1];
        }
        string1 = [NSString stringWithFormat:@"%@-%@-%i", dayStr, monthStr1, year];  
    }
    
    
    //This is a sample date. The Z stands for GMT timezone
    //The 0901 is 09h 01m on a 24 hour clock not 12.
    //As long as I can get the hours/min & date from the string I can deal with the time zone later
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString:string];
    NSDate *date1 = [dateFormat dateFromString:string1];
    
    
    SChartDateRange *xRange = [[SChartDateRange alloc] initWithDateMinimum:date1 andDateMaximum:date];
    NSLog(@"dateRange:  %@ - %@", date1, date);
    // Create a date time axis to use as the x axis.    
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:xRange];
    // Enable panning and zooming on the x-axis.
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    xAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    xAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    
    chart.xAxis = xAxis;
    [xAxis release];
    [xRange release];
    
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
    
    
    isLegend = legendSwitch.on;
    isSymbol = symbolSwitch.on;
    isGradient = gradientSwitch.on;

    
    
    
    [containerView sendSubviewToBack:loadingView];
    // Add the chart to the view controller
    /*
    [chart setAlpha:0.0];
    [containerView addSubview:chart];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [chart setAlpha:1.0];
    [UIView commitAnimations];
    //[containerView bringSubviewToFront:legendView]; 
    */
    t2LogoImageView.hidden = YES;
    
    
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        [self showButtons:1];
        
        
        // Add the chart to the view controller
        [chart setAlpha:0.0];
        [menuView setAlpha:0.0];
        [legendView setAlpha:0.0];
        menuView.hidden = NO;
        [containerView addSubview:chart];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [chart setAlpha:1.0];
        [menuView setAlpha:1.0];
        [UIView commitAnimations];
        
        // Update Legend
        NSLog(@"isLEgend: %i", isLegend);
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
        

        [self showButtons:2];
        
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
    

    [self resetLegend];


}

- (void)showButtons:(int)howMany;
{
    if (howMany == 1) 
    {
        self.navigationItem.rightBarButtonItems = nil;
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClick)];
        self.navigationItem.rightBarButtonItem = actionButton;
        [actionButton release];
        
        NSLog(@"how many 1");
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
        
        NSLog(@"how many 2");
        
    }
}

- (void)legendButtonClicked
{
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
    [self legendButtonClicked];
}


- (void)resetLegend
{
    [legendView removeFromSuperview];
    int startWidth = 0;

    NSString *version = [UIDevice currentDevice].systemVersion;
	if ([version compare:@"3.2"] != kCFCompareLessThan) {
		self.legendSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)];
		self.legendSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)];
        
        self.legendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(legendButtonClicked)];
        
		self.legendSwipeRight.delegate = self;
		self.legendSwipeLeft.delegate = self;
        
        self.legendTap.delegate = self;
        
		self.legendSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
		
		[legendView addGestureRecognizer:self.legendSwipeRight];
		[legendView addGestureRecognizer:self.legendSwipeLeft];	
        [legendView addGestureRecognizer:self.legendTap];	
	}
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        // iPad
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
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
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
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
    
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
    {
        [containerView addSubview:legendView];
        [containerView bringSubviewToFront:legendView];
    }
    else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
    {
        if (!menuShowing) 
        {
            [containerView addSubview:legendView];
            [containerView bringSubviewToFront:legendView];

        }    
    }
    

}

- (void)showLegend
{
    NSLog(@"groupsArray: %@", groupsArray);
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
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
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
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
      
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        
        int startWidth = 0;
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
         
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
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
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

- (void)getDatasource
{
    // Initialise the data source we will use for the chart
    datasource = [[GraphDataSource alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self setupGraph];
    });
}


- (void)legendToggle
{
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
    BOOL val = legendSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    
    
    // Update Legend
    if (val) 
    {
        // Reload buttons
        legendView.hidden = NO;
        [self showButtons:1];
    }
    else 
    {
        // Reload buttons
        legendView.hidden = YES;
        [self showButtons:1];
    }
    
    //doUpdate = YES;
}

- (void)symbolToggle
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_SYMBOL"];
    BOOL val = symbolSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    
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
}

- (void)gradientToggle
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_GRADIENT"];
    BOOL val = gradientSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    
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

}

-(void)switchSeriesType {
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
    // Return YES for supported orientations.
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	BOOL shouldRotate = NO;	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
		shouldRotate = YES;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
    {
		shouldRotate = YES;
	}
	
	return shouldRotate;
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;

    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        NSLog(@"OrientationCHANGE: PORTRAIT");
        
        [chart removeFromSuperview];
        

        CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
        CGRect chartRect = CGRectMake(0.0,
                                      0.0,
                                      chartViewSize.width, 211); 
        
        chart.frame = chartRect;
        [self showButtons:1];
        
        CGSize menuViewSize = [self.menuView sizeThatFits:CGSizeZero];
        CGRect menuRect = CGRectMake(0.0,
                                      211,
                                      menuViewSize.width, 205);
        self.menuView.frame = menuRect;
        
        menuView.hidden = NO;
        [menuView setAlpha:1.0];
        [containerView addSubview:chart];
        [containerView bringSubviewToFront:legendView];
        [containerView bringSubviewToFront:menuView];


        
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        [chart removeFromSuperview];

        NSLog(@"OrientationCHANGE: LANDSCAPE");
        CGSize chartViewSize = [chart sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      0.0,
                                      chartViewSize.width, 260); 
        
        chart.frame = startRect;
        [self showButtons:2];
        
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

    /*
     if (menuShowing && segmentButton.selectedSegmentIndex == 1) 
     {
     [notesTable.view removeFromSuperview];
     notesTable = nil;
     if (self.notesTable == nil) 
     {
     self.notesTable = [[ViewNotesViewController alloc] initWithNibName:@"ViewNotesViewController" bundle:nil];
     CGRect wFrame = menuView.frame;
     CGRect bFrame = menuBar.frame;
     NSInteger notesHeight =  wFrame.size.height - (bFrame.origin.y + bFrame.size.height);
     CGRect nFrame = CGRectMake(0, wFrame.size.height - notesHeight, wFrame.size.width, notesHeight);
     self.notesTable.view.frame = nFrame;
     [menuView addSubview:self.notesTable.view];
     }
     //   NSLog(@"segment: %i", segmentButton.selectedSegmentIndex);
     self.notesTable.view.hidden = NO;
     NSInteger top = 0;
     CGRect notesFrame = self.notesTable.notesTableView.frame;
     CGRect newFrame = CGRectMake(notesFrame.origin.x, top, notesFrame.size.width, notesFrame.size.height);
     self.notesTable.notesTableView.frame = newFrame;
     }
     */
    
}



#pragma mark switch

-(void)createSwitches {
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

- (void)switchProcess
{
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
    
    [self resetLegend];

    [containerView sendSubviewToBack:loadingView];

}


#pragma mark groups

- (void)fillGroupsDictionary {
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

-(UIColor *)UIColorForIndex:(NSInteger)index {
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


- (void)fillColors {
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

-(UIImage *)UIImageForIndex:(NSInteger)index {
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL storedVal;
    NSString *key;
    
    
    // Fetch User Defaults for Legend
    key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
    if (![defaults objectForKey:key]) {
        storedVal = NO;
    }
    else {
        storedVal = [defaults boolForKey:key];				
    }
    legendSwitch.on = storedVal;
    legendSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
    [legendSwitch addTarget:self action:@selector(legendToggle) forControlEvents:UIControlEventValueChanged];
    
    
    // Fetch User Defaults for Symbol
    key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_SYMBOL"];
    if (![defaults objectForKey:key]) {
        storedVal = NO;
    }
    else {
        storedVal = NO;//[defaults boolForKey:key];				
    }
    symbolSwitch.on = storedVal;
    symbolSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
    [symbolSwitch addTarget:self action:@selector(symbolToggle) forControlEvents:UIControlEventValueChanged];
    
    // Fetch User Defaults for Gradient
    key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_GRADIENT"];
    if (![defaults objectForKey:key]) {
        storedVal = NO;
    }
    else {
        storedVal = NO;//[defaults boolForKey:key];				
    }
    NSLog(@"storedVal: %i", storedVal);
    gradientSwitch.on = storedVal;
    gradientSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
    [gradientSwitch addTarget:self action:@selector(gradientToggle) forControlEvents:UIControlEventValueChanged];  
    
}


#pragma mark Symbols Dictionary
- (void)fillSymbols
{
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
            
            if (isRefreshTable) 
            {
                [_tableView reloadData];
                doUpdate = YES;
                isRefreshTable = NO;
            }
            
			break;
		case 1:
            // NSLog(@"Notes:");
            
            /*
             [notesTable.view removeFromSuperview];
             notesTable = nil;
             if (self.notesTable == nil) {
             self.notesTable = [[ViewNotesViewController alloc] initWithNibName:@"ViewNotesViewController" bundle:nil];
             CGRect wFrame = menuView.frame;
             CGRect bFrame = menuBar.frame;
             NSInteger notesHeight =  wFrame.size.height - (bFrame.origin.y + bFrame.size.height);
             CGRect nFrame = CGRectMake(0, wFrame.size.height - notesHeight, wFrame.size.width, notesHeight);
             self.notesTable.view.frame = nFrame;
             [menuView addSubview:self.notesTable.view];
             }
             
             self.notesTable.view.hidden = NO;
             NSInteger top = 0;
             CGRect notesFrame = self.notesTable.notesTableView.frame;
             CGRect newFrame = CGRectMake(notesFrame.origin.x, top, notesFrame.size.width, notesFrame.size.height);
             self.notesTable.notesTableView.frame = newFrame;
             */
            
            noteView.hidden = NO;
            optionView.hidden = YES;
            _tableView.hidden = YES;	
            
            
            break;
		case 2:
           // NSLog(@"legend: %i  symbol: %i  gradient: %i", isLegend, isSymbol, isGradient);
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

- (void)openPicker:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"Tag = %d", gesture.view.tag);
    
    
    HRColorPickerViewController* controller;
    controller = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor redColor]];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)setSelectedColor:(UIColor*)color{
    [self.view setBackgroundColor:color];
    // [hexColorLabel setText:[NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)]];
}



#pragma mark tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    
    numberOfRows = [self.groupsDictionary count];
    
    
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    Group *group = [self.groupsArray objectAtIndex:row];
    NSString *groupName = group.title;
    UISwitch *aSwitch = [self.switchDictionary objectForKey:groupName];
    
    NSData *data = [tColorDict objectForKey:groupName];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    cell.textLabel.text = groupName;
    cell.textLabel.textColor = color;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.textAlignment = UITextAlignmentRight;
    
    cell.accessoryView = aSwitch;
    
    /* Clickable imageView
     cell.imageView.userInteractionEnabled = YES;
     cell.imageView.tag = indexPath.row;
     cell.imageView.image = image;
     
     UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPicker:)];
     tapped.numberOfTapsRequired = 1;
     [cell.imageView addGestureRecognizer:tapped];
     [tapped release];
     */
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	NSInteger row = [indexPath indexAtPosition:1];
    
    Group *group = [self.groupsArray objectAtIndex:row];
    NSString *groupName = group.title;
    
    SGraphViewController *sGraphViewController = [[SGraphViewController alloc] initWithNibName:@"SGraphViewController" bundle:nil];
    sGraphViewController.groupName = groupName;
    [self.navigationController pushViewController:sGraphViewController animated:YES];
    //   NSLog(@"groupName: %@", groupName);
    [sGraphViewController release];
    
    // [self optionButtonClicked];
    
}

#pragma mark Email delegates

- (void)emailResults
{
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
    dispatch_release(backgroundQueue);
    [chart release];
    [datasource release];
    [super dealloc];
}



@end
