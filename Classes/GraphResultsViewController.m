//
//  GraphResultsViewController.m
//  VAS002
//
//  Created by Hasan Edain on 12/28/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "GraphResultsViewController.h"
#import "SubGraphViewController.h"
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

@implementation GraphResultsViewController

//@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize graphHost;
@synthesize graph;
@synthesize chartMonth;
@synthesize chartYear;
@synthesize dateSet;
@synthesize switchDictionary;
@synthesize ledgendColorsDictionary;
@synthesize notesTable;
@synthesize groupsDictionary;
@synthesize groupsArray;
@synthesize gregorian;

@synthesize notesForMonth;
@synthesize valuesArraysForMonth;

@synthesize graphSwipeRight;
@synthesize graphSwipeLeft;
@synthesize graphTap;

@synthesize graphSwitches;
@synthesize screenShotView;

#pragma mark View Events

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[FlurryUtility report:EVENT_RESULTS_ACTIVITY];
	self.title = @"Graph Results";

	self.gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSString *version = [UIDevice currentDevice].systemVersion;
	if ([version compare:@"3.2"] != kCFCompareLessThan) {
		self.graphSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backMonthClicked:)];
		self.graphSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forwardMonthClicked:)];
        
        self.graphTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
        
		self.graphSwipeRight.delegate = self;
		self.graphSwipeLeft.delegate = self;
        
        self.graphTap.delegate = self;
        
		self.graphSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
		
		[graphView addGestureRecognizer:self.graphSwipeRight];
		[graphView addGestureRecognizer:self.graphSwipeLeft];	
        [graphView addGestureRecognizer:self.graphTap];	
	}
	
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scaleMonthChanged:) name:@"scaleMonthChanged" object:nil];

	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareClick)];
	self.navigationItem.rightBarButtonItem = plusButton;
    
    
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self deviceOrientationChanged:nil];
	
	if (!dateSet) {
		NSDate *now = [NSDate date];
		NSDateComponents *monthComponents = [self.gregorian components:NSMonthCalendarUnit + NSYearCalendarUnit fromDate:now];
		self.chartMonth = [monthComponents month];
		self.chartYear = [monthComponents year];
	}
	[self fillGroupsDictionary];
	[self fillColors];
	[self createSwitches];
    
	self.notesForMonth = [self getNotesForMonth];
	self.valuesArraysForMonth = [self getValueDictionaryForMonth];
	
	[self showMonth];
	[self setupGraph];
	self.dateSet = NO;
}

#pragma mark Share

- (void)shareClick
{
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle:@"" 
                                   delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                                   destructiveButtonTitle:nil 
                                   otherButtonTitles:@"Email Results(PNG)", @"Email Results (PNG+Notes)", @"Email Results(CSV)", nil] autorelease];
    [actionSheet showInView:self.view];  
}

#pragma mark Screenshot

- (void)getScreenShot
{
    // Test Screenshot:
    
    UIImage *screenShotImage = [self screenShot];
    
    if(screenShotImage){
        screenShotView = [[UIImageView alloc] initWithImage:screenShotImage];
        [screenShotView setFrame:CGRectMake(10, 10, 200, 200)];
        [self.view addSubview:screenShotView];
        
        [self.view bringSubviewToFront:screenShotView];
    }else
        NSLog(@"Something went wrong in screenShot method, the image is nil");  
    
}

- (UIImage*)screenShot 
{
    NSLog(@"Shot");
    
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
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

        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(saveResults) userInfo:nil repeats:NO];
        
    } 
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        // Export CSV
        NSLog(@"Email CSV");

        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(saveResults) userInfo:nil repeats:NO];
        
        //[self emailResults];
    }
    /*
     else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) 
     {
     // Export PNG
     NSLog(@"Email PNG");
     [self emailResults];
     }
     */
}

#pragma mark scaleMonh

- (void)scaleMonthChanged:(NSNotification *)notification {
	NSDictionary* usr = [notification userInfo];
	NSNumber *chartYearNumber = [usr objectForKey:@"chartYear"];
	NSNumber *chartMonthNumber = [usr objectForKey:@"chartMonth"];
	self.chartYear = [chartYearNumber intValue];
	self.chartMonth = [chartMonthNumber intValue];
	
	self.dateSet = YES;
}



#pragma mark graph

-(void)setupGraph {
	self.graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	
	CPTheme *theme = [CPTheme themeNamed:kCPPlainBlackTheme];
	//[theme applyThemeToAxisSet:self.graph.axisSet];
	[theme applyThemeToGraph:self.graph];
	self.graphHost.collapsesLayers = YES;
	self.graphHost.hostedGraph = self.graph;
	
	self.graph.frame = self.view.bounds;
	self.graph.paddingRight					= 10.0f;
    self.graph.paddingLeft					= 30.0f;
	self.graph.paddingBottom				= 25.0f;
	self.graph.paddingTop					= 10.0f;
    self.graph.plotAreaFrame.masksToBorder	= NO;
    self.graph.plotAreaFrame.cornerRadius	= 10.0f;
    
	// Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(31.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(100.0)];
	
	// Axes
    CPXYAxisSet *xyAxisSet = (id)self.graph.axisSet;
    CPXYAxis *xAxis = xyAxisSet.xAxis;
    xAxis.axisLineStyle.lineCap = kCGLineCapButt;	
    xAxis.labelingPolicy = CPAxisLabelingPolicyNone;
    xAxis.labelTextStyle.fontSize = 10.0f;
	
    CPXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.axisLineStyle = kCGLineCapButt;
	yAxis.labelingPolicy = CPAxisLabelingPolicyNone;
	
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
    borderLineStyle.lineColor = [CPColor blackColor];
    borderLineStyle.lineWidth = 1.0f;
    self.graph.plotAreaFrame.borderLineStyle = borderLineStyle;
    
	// Define some custom labels for the data elements
	xAxis.labelingPolicy = CPAxisLabelingPolicyNone;
	NSMutableArray *customXTickLocations = [NSMutableArray array];
    //TODO: Make this thing use date math. 
	NSArray *xAxisWeekLabels = [NSArray arrayWithObjects:@"1", @"7", @"14", @"21", @"28", nil];
	
	NSMutableArray *xAxisLabels = [NSMutableArray array];
	
	NSString *weekString;
	NSInteger weekNumber;
	
	for (NSInteger i = 0; i < [xAxisWeekLabels count]; i++) {
		weekString = [xAxisWeekLabels objectAtIndex:i];
		weekNumber = [weekString intValue];
		[customXTickLocations addObject:[NSNumber numberWithInt:weekNumber]];
		[xAxisLabels addObject:weekString];
	}
	
	yAxis.labelingPolicy = CPAxisLabelingPolicyNone;
	NSMutableArray *customYTickLocations = [NSMutableArray array];
	
	NSMutableArray *yAxisLabels = [NSMutableArray array];
	[customYTickLocations addObject:[NSNumber numberWithInt:0]];
	[yAxisLabels addObject:@"Lo"];
	
	[customYTickLocations addObject:[NSNumber numberWithInt:100]];
	[yAxisLabels addObject:@"Hi"];
	
	NSUInteger labelLocation = 0;
	NSMutableArray *customXLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
	for (NSNumber *tickLocation in customXTickLocations) {
		CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:xAxis.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = xAxis.labelOffset + xAxis.majorTickLength;
		//newLabel.rotation = M_PI / 2;
		[customXLabels addObject:newLabel];
		[newLabel release];
	}

	labelLocation = 0;
	NSMutableArray *customYLabels = [NSMutableArray arrayWithCapacity:[yAxisLabels count]];
	for (NSNumber *tickLocation in customYTickLocations) {
		CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText: [yAxisLabels objectAtIndex:labelLocation++] textStyle:yAxis.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = yAxis.labelOffset + yAxis.majorTickLength;
		//newLabel.rotation = M_PI / 2;
		[customYLabels addObject:newLabel];
		[newLabel release];
	}
	
	
	xAxis.axisLabels =  [NSSet setWithArray:customXLabels];
	yAxis.axisLabels = [NSSet setWithArray:customYLabels];
	//Notes Plot
	CPScatterPlot *notesPlot = [[CPScatterPlot alloc] init];
	notesPlot.identifier = @"Notes";
	notesPlot.labelOffset = 5.0f;
   // NSLog(@"tester");
	CPPlotSymbol *notesPlotSymbol = [CPPlotSymbol rectanglePlotSymbol];
	notesPlotSymbol.fill = [CPFill fillWithColor:[CPColor yellowColor]];
	notesPlotSymbol.size = CGSizeMake(16.0, 16.0);

	CPLineStyle *noteSymbolLineStyle = [CPLineStyle lineStyle];
	noteSymbolLineStyle.lineColor = [CPColor blackColor];
	notesPlotSymbol.lineStyle = noteSymbolLineStyle;
	notesPlot.plotSymbol = notesPlotSymbol;
	notesPlot.dataSource = self;
	[self.graph addPlot:notesPlot];
	
	[notesPlot release];
	
	//Weekend Plot
	CPScatterPlot *weekendPlot = [[CPScatterPlot alloc] init];
	weekendPlot.identifier = @"Weekend";
	CPLineStyle *weekendLineStyle = [CPLineStyle lineStyle];
	weekendLineStyle.lineColor = [CPColor clearColor];
	weekendLineStyle.lineWidth = 0.0f;
	weekendPlot.dataSource = self;
	[self.graph addPlot:weekendPlot];
	
	// Do a blue gradient
	CPColor *areaColor1 = [CPColor colorWithComponentRed:0.6 green:0.6 blue:0.8 alpha:0.3];
    CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor whiteColor]];
    areaGradient1.angle = -90.0f;
    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
    weekendPlot.areaFill = areaGradientFill;
    weekendPlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];   
	
	[weekendPlot release];
	
	NSArray *grpArray = [self.groupsDictionary allKeys];
	
	NSInteger index = 0;
	for (NSString *groupTitle in grpArray) {
		UISwitch *aSwitch = [self.switchDictionary objectForKey:groupTitle];
		if (aSwitch.on == YES) {
			CPColor *color = [self.ledgendColorsDictionary objectForKey:groupTitle];
			// Create an area with a colored plot
			CPScatterPlot *boundLinePlot = [[CPScatterPlot alloc] init];
			boundLinePlot.interpolation = CPScatterPlotInterpolationLinear;
			//boundLinePlot.areaFill = [CPFill fillWithColor:color];
			//boundLinePlot.areaFill2 = [CPFill fillWithColor:[CPColor whiteColor]];
			boundLinePlot.identifier = groupTitle;
			CPLineStyle *lineStyle = [CPLineStyle lineStyle];
			lineStyle.lineColor = color;
			lineStyle.lineWidth = 1.0f;
			boundLinePlot.labelOffset = 5.0f;
			boundLinePlot.dataLineStyle.miterLimit = 1.0f;
			boundLinePlot.dataLineStyle.lineWidth = 3.0f;
			boundLinePlot.dataLineStyle.lineColor = color;
			boundLinePlot.dataSource = self;
			[self.graph addPlot:boundLinePlot];
			
			// Add plot symbols
			CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
			symbolLineStyle.lineColor = [CPColor blackColor];
			CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
			plotSymbol.fill = [CPFill fillWithColor:color];
			plotSymbol.lineStyle = symbolLineStyle;
			plotSymbol.size = CGSizeMake(6.0, 6.0);
			boundLinePlot.plotSymbol = plotSymbol;	
		
			[boundLinePlot release];
			
			index++;
		}
	}
}

- (void)monthChanged {
	self.notesForMonth = [self getNotesForMonth];
	self.valuesArraysForMonth = [self getValueDictionaryForMonth];
	
	[self setupGraph];
	[self showMonth];
	[graph reloadData];
}

-(void)showMonth {
	if (self.chartMonth < 0) {
		NSDate *date = [NSDate date];
		NSDateComponents *monthComponents = [self.gregorian components:NSMonthCalendarUnit + NSYearCalendarUnit fromDate:date];
		NSInteger month = [monthComponents month];
		NSInteger year = [monthComponents year];
		self.chartMonth = month;
		self.chartYear =year;
	}
	
	NSString *monthString = [DateMath monthNameFrom:self.chartMonth];
	monthLabel.text = [NSString stringWithFormat:@"%@ %d",monthString,self.chartYear];
}

- (IBAction)segmentIndexChanged {
	switch (segmentButton.selectedSegmentIndex) {
		case 0:
			self.graphSwitches.hidden = NO;
			if (self.notesTable != nil) {
				self.notesTable.view.hidden = YES;
			}
			break;
		case 1:
			self.graphSwitches.hidden = YES;
			if (self.notesTable == nil) {
				self.notesTable = [[ViewNotesViewController alloc] initWithNibName:@"ViewNotesViewController" bundle:nil];
				CGRect wFrame = ledgendView.frame;
				CGRect bFrame = segmentButton.frame;
				NSInteger notesHeight = wFrame.size.height - (bFrame.origin.y + bFrame.size.height + 2);
				CGRect nFrame = CGRectMake(0, wFrame.size.height - notesHeight, wFrame.size.width, notesHeight);
				self.notesTable.view.frame = nFrame;
				[ledgendView addSubview:self.notesTable.view];
			}
			
			self.notesTable.view.hidden = NO;
			NSInteger top = segmentButton.frame.origin.y + segmentButton.frame.size.height;
			CGRect notesFrame = self.notesTable.notesTableView.frame;
			CGRect newFrame = CGRectMake(notesFrame.origin.x, top, notesFrame.size.width, notesFrame.size.height);
			self.notesTable.notesTableView.frame = newFrame;
			break;
	}
}

#pragma mark Drill Down
- (IBAction)drillDownClicked:(id)sender {
	if ([sender isKindOfClass:[UIButton class]] ){
		NSString *title = ((UIButton *)sender).titleLabel.text;
		SubGraphViewController *subGraphViewController = [[SubGraphViewController alloc] initWithNibName:@"SubGraphViewController" bundle:nil];
		subGraphViewController.groupName = title;
		subGraphViewController.dateSet = YES;
		subGraphViewController.chartYear = self.chartYear;
		subGraphViewController.chartMonth = chartMonth;
		[self.navigationController pushViewController:subGraphViewController animated:YES];
		[subGraphViewController release];
	}
}
#pragma mark Switches

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

-(void)switchFlipped:(id)sender {
	NSEnumerator *enumerator = [self.switchDictionary keyEnumerator];
	id key;
	
	UISwitch *currentValue;
	NSString *switchTitle = @"";
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
	
	while ((key = [enumerator nextObject])) {
		currentValue = [self.switchDictionary objectForKey:key];
		if (currentValue == sender) {
			switchTitle = key;
			defaultsKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",switchTitle];
			BOOL val = ((UISwitch *)currentValue).on;
			[defaults setBool:val forKey:defaultsKey];
			[defaults synchronize];
			NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:switchTitle, [NSNumber numberWithBool:val],nil];
			[FlurryUtility report:EVENT_GRAPHRESULTS_SWITCHFLIPPED withData:usrDict];
		}
	}
	
	[self monthChanged];
}

#pragma mark colors

-(UIColor *)UIColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor grayColor], [UIColor brownColor],	[UIColor cyanColor],[UIColor magentaColor],  nil];
	
	UIColor *color = nil;
	
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
	}
	return color;
}

-(CPColor *)CPColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[CPColor blueColor], [CPColor greenColor], [CPColor orangeColor], [CPColor redColor], [CPColor purpleColor], [CPColor grayColor], [CPColor brownColor],	[CPColor cyanColor],[CPColor magentaColor],  nil];
	
	CPColor *color = nil;
	
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
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
    
    NSLog(@"colorDict: %@", ledgendColorsDictionary);
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
       // NSLog(@"grpArray: %@", grpArray);
	}
}

#pragma mark buttons

-(void)tapClicked:(id)sender 
{
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Note" style:UIBarButtonItemStylePlain target:self action:@selector(addNote:)];
	self.navigationItem.rightBarButtonItem = plusButton;
 
}

-(void)backMonthClicked:(id)sender {
	BOOL takeAction = YES;
	
	if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
		CGPoint where = [((UISwipeGestureRecognizer *)sender)locationInView:self.view];
		CGRect graphFrame = self.graphHost.frame;
		NSInteger hostBottom = graphFrame.origin.y + graphFrame.size.height;
		if (where.y > hostBottom) {
			takeAction = NO;
		}
	}
	
	if (takeAction) {
		
		self.chartMonth--;
		if (self.chartMonth < 1) {
			self.chartMonth = 12;
			self.chartYear--;
		}
		
		[self monthChanged];
	}
}

-(void)forwardMonthClicked:(id)sender {
	BOOL takeAction = YES;
	
	if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
		CGPoint where = [((UISwipeGestureRecognizer *)sender)locationInView:self.view];
		CGRect graphFrame = self.graphHost.frame;
		NSInteger hostBottom = graphFrame.origin.y + graphFrame.size.height;
		if (where.y > hostBottom) {
			takeAction = NO;
		}
	}
	
	if (takeAction) {
		self.chartMonth++;
		if(self.chartMonth > 12) {
			self.chartMonth = 1;
			self.chartYear++;
		}
		
		[self monthChanged];
	}
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numberOfRows = [self.groupsDictionary count];
	return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the book's title
	NSInteger row = [indexPath indexAtPosition:1];
	
	Group *group = [self.groupsArray objectAtIndex:row];
	NSString *groupName = group.title;
	UISwitch *aSwitch = [self.switchDictionary objectForKey:groupName];
	cell.accessoryView = aSwitch;
	
	cell.textLabel.text = groupName;
	cell.textLabel.textColor = [self.ledgendColorsDictionary objectForKey:groupName];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	cell.textLabel.textAlignment = UITextAlignmentRight;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath indexAtPosition:1];
	
	Group *group = [self.groupsArray objectAtIndex:row];
	NSString *groupName = group.title;

	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	SubGraphViewController *subGraphViewController = [[SubGraphViewController alloc] initWithNibName:@"SubGraphViewController" bundle:nil];
	subGraphViewController.groupName = groupName;
	[appDelegate.navigationController pushViewController:subGraphViewController animated:YES];
	[subGraphViewController release];
}

#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	BOOL shouldRotate = NO;	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		shouldRotate = YES;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		shouldRotate = YES;
	}
	
	return shouldRotate;
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
    UIApplication *app = [UIApplication sharedApplication];
    VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
    
	CGRect containterViewFrame = containterView.frame;
	
	NSInteger width = containterViewFrame.size.width;
	NSInteger height = containterViewFrame.size.height;
	
	CGRect graphViewFrame = [graphView bounds];
	CGRect ledgendViewFrame = [ledgendView bounds];

	UIDevice *device = [UIDevice currentDevice];
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        //[appDelegate.navigationController setNavigationBarHidden:NO];
		graphViewFrame.size.width = width;
		graphViewFrame.size.height = height / 2 ;
		graphView.frame = graphViewFrame;
		
        ledgendView.hidden = NO;
		ledgendViewFrame.origin.x = 0;
		ledgendViewFrame.origin.y = height/2;
		ledgendViewFrame.size.width = width;
		ledgendViewFrame.size.height = height / 2;
		ledgendView.frame = ledgendViewFrame;
	}
	else if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){

        
        //[appDelegate.navigationController setNavigationBarHidden:YES];
		graphViewFrame.size.width = width;
		graphViewFrame.size.height = height;
		graphView.frame = graphViewFrame;
        
        ledgendView.hidden = YES;
        
        // Show right icon bar
        
        
			/*	
		ledgendViewFrame.origin.x = width/2;
		ledgendViewFrame.origin.y = 0;
		ledgendViewFrame.size.width = width/2;
		ledgendViewFrame.size.height = height;
		ledgendView.frame = ledgendViewFrame;	*/	
	}
}

#pragma mark Data

- (NSDictionary *)getValueDictionaryForMonth {
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupResult" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	NSSortDescriptor *monthDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:YES];
	NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
	NSSortDescriptor *groupTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"group.title" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearDescriptor, monthDescriptor,dayDescriptor, groupTitleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *groupPredicateString = @"";
	
	NSArray *results;
	NSPredicate *titlePredicate;
	NSString *timePredicateString;
	NSPredicate *timePredicate;
	NSPredicate *visiblePredicate;
	NSArray *finalPredicateArray;
	NSPredicate *finalPredicate;
	for (NSString *groupTitle in self.groupsDictionary) {
		Group *currentGroup = [self.groupsDictionary objectForKey:groupTitle];
		UISwitch *currentSwitch = [switchDictionary objectForKey:groupTitle];
		if (currentSwitch.on == YES) {
			groupPredicateString = [NSString stringWithFormat:@"group.title like %%@"];
			titlePredicate = [NSPredicate predicateWithFormat:groupPredicateString, groupTitle];
			timePredicateString = [NSString stringWithFormat:@"(year == %%@) && (month == %%@)"];
			timePredicate = [NSPredicate predicateWithFormat:timePredicateString, [ NSNumber numberWithInt:self.chartYear], [NSNumber numberWithInt:self.chartMonth]];
			visiblePredicate = [NSPredicate predicateWithFormat:@"group.visible == TRUE"];
		
			finalPredicateArray = [NSArray arrayWithObjects:titlePredicate, timePredicate,visiblePredicate, nil];
		    
			finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];

			[fetchRequest setPredicate:finalPredicate];
	
			[fetchRequest setFetchBatchSize:31];
			
			NSError *error = nil;
			results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            
			if (error) {
				[Error showErrorByAppendingString:@"could not get result data for graph" withError:error];
			} 
			else {
				NSMutableArray *tempTotalArray = [NSMutableArray arrayWithCapacity:31];
				NSMutableArray *tempCountArray = [NSMutableArray arrayWithCapacity:31];
				for (NSInteger i=0; i<31; i++) {
					[tempTotalArray addObject:[NSNumber numberWithInt:0]];
					[tempCountArray addObject:[NSNumber numberWithInt:0]];
				}
				
				for (GroupResult *groupResult in results) {
					double value = [groupResult.value doubleValue];
					double day = [groupResult.day doubleValue] - 1;
					double totalValue = [[tempTotalArray objectAtIndex:day] doubleValue] + value;
					double count = [[tempCountArray objectAtIndex:day] doubleValue] + 1;
					[tempTotalArray replaceObjectAtIndex:day withObject:[NSNumber numberWithDouble:totalValue]];
					[tempCountArray replaceObjectAtIndex:day withObject:[NSNumber numberWithDouble:count]];
				}
				
				NSMutableArray *summaryArray = [NSMutableArray arrayWithCapacity:31];
				for (NSInteger i = 0; i<31; i++) {
					double value = [[tempTotalArray objectAtIndex:i] doubleValue];
					double count = [[tempCountArray objectAtIndex:i] doubleValue];
					double averageValue = -1;
					if(count > 0) {
						averageValue = value/count;
						if (![currentGroup.positiveDescription boolValue] == NO) {
							averageValue = 100 - averageValue;
						}
					}
					[summaryArray addObject:[NSNumber numberWithDouble:averageValue]];
                    
				}
				[tempDict setObject:summaryArray forKey:groupTitle];
			}
		}
	}
	
	NSDictionary *valueDictionary = [NSDictionary dictionaryWithDictionary:tempDict];

	[yearDescriptor release];
	[monthDescriptor release];
	[dayDescriptor release];
	[groupTitleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];

     
    
	return valueDictionary;
}

- (NSArray *)getNotesForMonth {
	NSFetchRequest *notesFetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	[notesFetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"noteYear" ascending:YES];
	NSSortDescriptor *monthDescriptor = [[NSSortDescriptor alloc] initWithKey:@"noteMonth" ascending:YES];
	NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"noteDay" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearDescriptor, monthDescriptor, dayDescriptor, nil];
	[notesFetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *timePredicateString = [NSString stringWithFormat:@"(noteMonth == %%@) && (noteYear == %%@)"];
	NSPredicate *timePredicate = [NSPredicate predicateWithFormat:timePredicateString, [NSNumber numberWithInt:self.chartMonth], [NSNumber numberWithInt:self.chartYear]];
	[notesFetchRequest setPredicate:timePredicate];
	
	[notesFetchRequest setFetchBatchSize:120];

	NSError *error = nil;
	NSArray *objects = [self.managedObjectContext executeFetchRequest:notesFetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Error fetching notes for month" withError:error];
	}
	
	[yearDescriptor release];
	[monthDescriptor release];
	[dayDescriptor release];
	[sortDescriptors release];
	[notesFetchRequest release];
	
	NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:31];
	
	NSNumber *nilNum = [NSNumber numberWithInt:-1];
	for (NSInteger i = 0; i < 31; i++) {
		[tempArray addObject:nilNum];
	}
	
	for (Note *aNote in objects) {
		[tempArray replaceObjectAtIndex:([aNote.noteDay intValue]-1) withObject:[NSNumber numberWithInt:98]];
	}
	
		 NSArray *noteDays = [NSArray arrayWithArray:tempArray];
		 
	return noteDays;
}

-(NSArray *)getMondayArrayForMonth:(NSInteger)month andYear:(NSInteger)year {
	NSDateComponents *startComps = [[NSDateComponents alloc] init];
	[startComps setWeekday:1];
	[startComps setWeekdayOrdinal:1];
	[startComps setMonth:month];
	[startComps setYear:year];
	NSDate *date = [self.gregorian dateFromComponents:startComps];
	[startComps release];
	
	NSDateComponents *mondayComponents = [self.gregorian components:NSDayCalendarUnit fromDate:date];
	NSInteger day = [mondayComponents day];
	NSRange numberOfDaysRange = [self.gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	
	NSInteger numberOfDays = numberOfDaysRange.length;
	
	NSMutableArray *mondays = [NSMutableArray array];
	
	while (day < numberOfDays) {
		[mondays addObject:[NSNumber numberWithInt:day]];
		day += 7;
	}
	
	NSArray *returnVal = [NSArray arrayWithArray:mondays];
	return returnVal;
}

#pragma mark Chart Protocol
//TODO: Make this thing use date math. 
-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	int monthDays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
	float daysInMonth = monthDays[(self.chartMonth -1)];
	NSInteger numberDaysInMonth = daysInMonth;
	
    return numberDaysInMonth;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
	NSNumber *num = nil;
	
	if (fieldEnum == 0) {
		num = [NSNumber numberWithInt:index];
	}
	else {
		if (plot.identifier == @"Weekend") {
			NSDateComponents *startComps = [[NSDateComponents alloc] init];
			[startComps setDay:index];
			[startComps setMonth:self.chartMonth];
			[startComps setYear:self.chartYear];
			NSDate *date = [self.gregorian dateFromComponents:startComps];
			[startComps release];
			
			NSDateComponents *weekdayComponents  = [self.gregorian components:NSWeekdayCalendarUnit fromDate:date];
			NSInteger weekday = [weekdayComponents weekday];
			if (weekday == 1 || weekday == 7) {
				num = [NSNumber numberWithInt:101];
			}
		}
		else if(plot.identifier == @"Notes") {
			num = [self.notesForMonth objectAtIndex:index];
		}
		else {
			UISwitch *currentSwitch = [self.switchDictionary objectForKey:plot.identifier];
			
			if (currentSwitch.on) {
				NSArray *objects = [self.valuesArraysForMonth objectForKey:plot.identifier];
				NSNumber *tempNumber = [objects objectAtIndex:index];
				if (tempNumber != nil && [tempNumber intValue] >= 0) {
					NSInteger temp = [tempNumber intValue];
					temp = 100 - temp; // Need to invert to show scale correctly
					num = [NSNumber numberWithInt:temp];
				}
			}		
		}		
	}

	if (num == [NSNumber numberWithInt:-1]) {
		num = nil;
	}
			
	return [[num retain] autorelease];
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.notesTable = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.notesTable release];
	[self.managedObjectContext release];

	[self.notesForMonth release];
	[self.valuesArraysForMonth release];
	
	[self.graphHost release];
	
	[self.graph release];
	
	[self.graphSwitches release];
	
	[self.gregorian release];
	
	[self.graphSwipeRight release];
	[self.graphSwipeLeft release];
	
	[self.switchDictionary release];
	[self.ledgendColorsDictionary release];

	[self.groupsDictionary release];
	[self.groupsArray release];
	
    [super dealloc];
}

@end
