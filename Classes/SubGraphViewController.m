//
//  SubGraphViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/11/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "SubGraphViewController.h"
#import "VAS002AppDelegate.h"
#import "Result.h"
#import "Group.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Scale.h"
#import "Note.h"
#import "ViewNotesViewController.h"
#import "Error.h"
#import "DateMath.h"
#import "AddNoteViewController.h"

@implementation SubGraphViewController

@synthesize managedObjectContext;

@synthesize graphHost;
@synthesize graph;
@synthesize chartMonth;
@synthesize chartYear;
@synthesize dateSet;
@synthesize switchDictionary;
@synthesize ledgendColorsDictionary;
@synthesize notesTable;
@synthesize scalesDictionary;
@synthesize scalesArray;
@synthesize gregorian;
@synthesize groupName;
@synthesize notesForMonth;
@synthesize valuesArraysForMonth;
@synthesize graphSwipeRight;
@synthesize graphSwipeLeft;
@synthesize userDictionary;

#pragma mark View Events

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	NSString *version = [UIDevice currentDevice].systemVersion;
	if ([version compare:@"3.2"] != kCFCompareLessThan) {
		self.graphSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forwardMonthClicked:)];
		self.graphSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backMonthClicked:)];
		self.graphSwipeRight.delegate = self;
		self.graphSwipeLeft.delegate = self;
		self.graphSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	
		[graphView addGestureRecognizer:self.graphSwipeRight];
		[graphView addGestureRecognizer:self.graphSwipeLeft];
	}
	self.title = [NSString stringWithFormat:@"Graph %@",self.groupName];
	
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
	
	[FlurryUtility report:EVENT_RESULTS_DETAILS_ACTIVITY];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scaleMonthChanged:) name:@"subScaleMonthChanged" object:nil];
    
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Note" style:UIBarButtonItemStylePlain target:self action:@selector(addNote:)];
	self.navigationItem.rightBarButtonItem = plusButton;
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
	
	[self fillScalesDictionary];
	[self fillColors];
	[self createSwitches];
	
	self.notesForMonth = [self getNotesForMonth];
	self.valuesArraysForMonth = [self getValueDictionaryForMonth];
	
	[self showMonth];
	[self setupGraph];
}

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
	NSMutableArray *customTickLocations = [NSMutableArray array];
    //TODO: Make this thing use date math. 
	NSArray *xAxisWeekLabels = [NSArray arrayWithObjects:@"1", @"7", @"14", @"21", @"28", nil];
	
	NSMutableArray *xAxisLabels = [NSMutableArray array];
	for (NSInteger i = 0; i < [xAxisWeekLabels count]; i++) {
		NSInteger weekNumber = [[xAxisWeekLabels objectAtIndex:i] intValue];
		[customTickLocations addObject:[NSNumber numberWithInt:weekNumber]];
		[xAxisLabels addObject:[NSString stringWithFormat:@"%d",weekNumber]];
	}
	
	yAxis.labelingPolicy = CPAxisLabelingPolicyNone;
	NSMutableArray *customYTickLocations = [NSMutableArray array];
	
	NSMutableArray *yAxisLabels = [NSMutableArray array];
	[customYTickLocations addObject:[NSNumber numberWithInt:0]];
	[yAxisLabels addObject:@"Lo"];
	
	[customYTickLocations addObject:[NSNumber numberWithInt:100]];
	[yAxisLabels addObject:@"Hi"];
		
	NSUInteger labelLocation = 0;
	NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
	for (NSNumber *tickLocation in customTickLocations) {
		CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:xAxis.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = xAxis.labelOffset + xAxis.majorTickLength;
		//newLabel.rotation = M_PI / 2;
		[customLabels addObject:newLabel];
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
		
	xAxis.axisLabels =  [NSSet setWithArray:customLabels];
	yAxis.axisLabels = [NSSet setWithArray:customYLabels];
	//Notes Plot
	CPScatterPlot *notesPlot = [[CPScatterPlot alloc] init];
	notesPlot.identifier = @"Notes";
	notesPlot.labelOffset = 5.0f;
	
	CPPlotSymbol *notesPlotSymbol = [CPPlotSymbol trianglePlotSymbol];
	notesPlotSymbol.fill = [CPFill fillWithColor:[CPColor yellowColor]];
	notesPlotSymbol.size = CGSizeMake(8.0, 8.0);
	
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
	[weekendPlot release];
	
	// Do a blue gradient
	CPColor *areaColor1 = [CPColor colorWithComponentRed:0.6 green:0.6 blue:0.8 alpha:0.3];
    CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor whiteColor]];
    areaGradient1.angle = -90.0f;
    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
    weekendPlot.areaFill = areaGradientFill;
    weekendPlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];   
	
	
	NSArray *localScalesArray = [self.scalesDictionary allKeys];
	
	NSInteger index = 0;
	for (NSString *minLabel in localScalesArray) {
		UISwitch *aSwitch = [self.switchDictionary objectForKey:minLabel];
		if (aSwitch.on == YES) {
			CPColor *color = [self.ledgendColorsDictionary objectForKey:minLabel];
			// Create an area with a colored plot
			CPScatterPlot *boundLinePlot = [[CPScatterPlot alloc] init];
			boundLinePlot.identifier = minLabel;
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
	self.userDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithInt:self.chartYear], @"chartYear",
	 [NSNumber numberWithInt:self.chartMonth], @"chartMonth", nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"scaleMonthChanged" object:self userInfo:self.userDictionary];
	
	self.notesForMonth = [self getNotesForMonth];
	self.valuesArraysForMonth = [self getValueDictionaryForMonth];
	
	[self setupGraph];
	[self showMonth];
	[graph reloadData];
}

- (NSDictionary *)getValueDictionaryForMonth {
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	NSSortDescriptor *monthDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:YES];
	NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
	NSSortDescriptor *scaleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scale" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearDescriptor, monthDescriptor,dayDescriptor, scaleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *scalePredicateString = @"";
	
	NSArray *results;
	NSString *groupPredicateString;
	NSPredicate *groupPredicate;
	NSPredicate *scalePredicate;
	NSString *timePredicateString;
	NSPredicate *timePredicate;
	NSArray *finalPredicateArray;
	NSPredicate *finalPredicate;
	for (NSString *scaleMinLabel in self.scalesDictionary) {
		UISwitch *currentSwitch = [switchDictionary objectForKey:scaleMinLabel];
		if (currentSwitch.on == YES) {
			Scale *currentScale = [scalesDictionary objectForKey:scaleMinLabel];
			Group *currentGroup = currentScale.group;
			
			groupPredicateString = [NSString stringWithFormat:@"group.title like %%@"];
			groupPredicate = [NSPredicate predicateWithFormat:groupPredicateString, currentGroup.title];
			scalePredicateString = [NSString stringWithFormat:@"scale.minLabel like %%@"];
			scalePredicate = [NSPredicate predicateWithFormat:scalePredicateString, scaleMinLabel];
			timePredicateString = [NSString stringWithFormat:@"(year == %%@) && (month == %%@)"];
			timePredicate = [NSPredicate predicateWithFormat:timePredicateString, [ NSNumber numberWithInt:self.chartYear], [NSNumber numberWithInt:self.chartMonth]];
			
			finalPredicateArray = [NSArray arrayWithObjects:groupPredicate, scalePredicate, timePredicate, nil];
			
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
				
				for (Result *result in results) {
					double value = [result.value doubleValue];
					double day = [result.day doubleValue] - 1;
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
					//NSLog(@"Scale: %@ Value: %f",currentScale.minLabel, averageValue);
					[summaryArray addObject:[NSNumber numberWithDouble:averageValue]];
				}
				[tempDict setObject:summaryArray forKey:scaleMinLabel];
			}
		}
	}
	
	NSDictionary *valueDictionary = [NSDictionary dictionaryWithDictionary:tempDict];
	
	[yearDescriptor release];
	[monthDescriptor release];
	[dayDescriptor release];
	[scaleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
	
	return valueDictionary;	
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
			graphSwitches.hidden = NO;
			if (self.notesTable != nil) {
				self.notesTable.view.hidden = YES;
			}
			break;
		case 1:
			graphSwitches.hidden = YES;
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
			CGRect notesFrame = notesTable.notesTableView.frame;
			CGRect newFrame = CGRectMake(notesFrame.origin.x, top, notesFrame.size.width, notesFrame.size.height);
			notesTable.notesTableView.frame = newFrame;
			break;
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
		
		CGRect switchRect = CGRectMake(xOff, yOff, switchWidth, height);
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL storedVal;
		NSString *key;
		
		NSArray *localScalesArray = [[self.scalesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		for (NSString *groupTitle in localScalesArray) {
			UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchRect];
			
			key = [NSString stringWithFormat:@"SUB_SWITCH_STATE_%@",groupTitle];
			if (![defaults objectForKey:key]) {
				storedVal = YES;
			}
			else {
				storedVal = [defaults boolForKey:key];				
			}
			
			aSwitch.on = storedVal;
			aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; 
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
			defaultsKey = [NSString stringWithFormat:@"SUB_SWITCH_STATE_%@",switchTitle];
			BOOL val = ((UISwitch *)currentValue).on;
			[defaults setBool:val forKey:defaultsKey];
			[defaults synchronize];
			
			NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:switchTitle, [NSNumber numberWithBool:val],nil];
			[FlurryUtility report:EVENT_SUBGRAPHRESULTS_SWITCHFLIPPED withData:usrDict];

		}
	}
	
	[self monthChanged];
}

#pragma mark colors

-(UIColor *)UIColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor yellowColor], [UIColor brownColor],	[UIColor cyanColor],[UIColor magentaColor],[UIColor grayColor], [UIColor  lightGrayColor], nil];
	
	UIColor *color = nil;
	
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
	}
	return color;
}

-(CPColor *)CPColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[CPColor blueColor], [CPColor greenColor], [CPColor orangeColor], [CPColor redColor], [CPColor purpleColor], [CPColor yellowColor], [CPColor brownColor],	[CPColor cyanColor],[CPColor magentaColor], [CPColor grayColor],[CPColor lightGrayColor], nil];
	
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
		NSArray *objects = [self.scalesDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
			UIColor *color = [self UIColorForIndex:index];
			[self.ledgendColorsDictionary setObject:color forKey:groupTitle];
			index++;
		}
	}
}

#pragma mark groups

- (void)fillScalesDictionary {
	if (self.scalesDictionary == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"group.title like %@",self.groupName];
		NSArray *predicateArray = [NSArray arrayWithObjects:groupPredicate, nil];
		NSPredicate *finalPredicate = [NSCompoundPredicate	andPredicateWithSubpredicates:predicateArray];
		[fetchRequest setPredicate:finalPredicate];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSMutableDictionary *scales = [NSMutableDictionary dictionary];
		NSError *error = nil;
		NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (!error) {
			for (Scale *aScale in objects) {
				[scales setObject:aScale forKey:aScale.minLabel];
			}
			self.scalesDictionary = [NSDictionary dictionaryWithDictionary:scales];
			
			NSArray *keys = [self.scalesDictionary allKeys];
			NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
			
			NSMutableArray *sclArray = [NSMutableArray array];
			for (NSString *minLabel in sortedKeys) {
				[sclArray addObject:[self.scalesDictionary objectForKey:minLabel]];
			}
			self.scalesArray = [NSArray arrayWithArray:sclArray];
		}
		else {
			[Error showErrorByAppendingString:@"Unable to fetch scale data" withError:error];
		}
		
		[fetchRequest release];
	}
}

#pragma mark buttons

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

- (void)addNote:(id)sender {
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	AddNoteViewController *addNoteViewController = [[[AddNoteViewController alloc] initWithNibName:@"AddNoteViewController" bundle:nil] autorelease];	
    
    NSDateComponents *dateComponents = [[[NSDateComponents alloc] init] autorelease];
    [dateComponents setYear:chartYear];
    [dateComponents setMonth:chartMonth];
    [dateComponents setDay:1];
    NSDate *noteDate = [gregorian dateFromComponents:dateComponents];
    addNoteViewController.noteDate = noteDate;

	[appDelegate.navigationController pushViewController:addNoteViewController animated:YES];
}


#pragma mark tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numberOfRows = [self.scalesDictionary count];
	return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	// Configure the cell to show the book's title
	NSInteger row = [indexPath indexAtPosition:1];
	
	Scale *scale = [self.scalesArray objectAtIndex:row];
	NSString *minLabel = scale.minLabel;
	NSString *maxLabel = scale.maxLabel;
	UISwitch *aSwitch = [self.switchDictionary objectForKey:minLabel];
	cell.accessoryView = aSwitch;
	
	cell.backgroundColor = [UIColor blackColor];
	
	cell.textLabel.text = minLabel;
	cell.textLabel.textColor = [self.ledgendColorsDictionary objectForKey:minLabel];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	
	cell.detailTextLabel.text = maxLabel;
	cell.detailTextLabel.textColor = [self.ledgendColorsDictionary objectForKey:minLabel];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
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
	CGRect containterViewFrame = containterView.frame;
	
	NSInteger width = containterViewFrame.size.width;
	NSInteger height = containterViewFrame.size.height;
	
	CGRect graphViewFrame = [graphView bounds];
	CGRect ledgendViewFrame = [ledgendView bounds];
	
	UIDevice *device = [UIDevice currentDevice];
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) {
		graphViewFrame.size.width = width;
		graphViewFrame.size.height = height / 2 ;
		graphView.frame = graphViewFrame;
				
		ledgendViewFrame.origin.x = 0;
		ledgendViewFrame.origin.y = height/2;
		ledgendViewFrame.size.width = width;
		ledgendViewFrame.size.height = height / 2;
		ledgendView.frame = ledgendViewFrame;
	}
	else if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
		graphViewFrame.size.width = width/2;
		graphViewFrame.size.height = height;
		graphView.frame = graphViewFrame;
				
		ledgendViewFrame.origin.x = width/2;
		ledgendViewFrame.origin.y = 0;
		ledgendViewFrame.size.width = width/2;
		ledgendViewFrame.size.height = height;
		ledgendView.frame = ledgendViewFrame;		
	}
}

#pragma mark DateMath

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

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.notesTable = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		
	[self.managedObjectContext release];
	
	[self.notesForMonth release];
	[self.valuesArraysForMonth release];
	
	[self.graphHost release];

	[self.graph release];
	[self.switchDictionary release];
	[self.ledgendColorsDictionary release];
	[self.notesTable release];
	[self.scalesDictionary release];
	[self.scalesArray release];
	[self.gregorian release];
	[self.groupName release];
	
	[self.graphSwipeRight release];
	[self.graphSwipeLeft release];
	[self.userDictionary release];
    [super dealloc];
}

@end