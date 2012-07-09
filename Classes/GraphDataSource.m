//
//  GraphDataSource.m
//  VAS002
//
//  Created by Melvin Manzano on 5/2/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "GraphDataSource.h"
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

@implementation GraphDataSource

@synthesize seriesData, seriesDates, dataDict;
@synthesize managedObjectContext;
@synthesize chartMonth;
@synthesize chartYear;
@synthesize dateSet;
@synthesize groupsDictionary;
@synthesize groupsArray;
@synthesize gregorian;
@synthesize notesForMonth;
@synthesize valuesArraysForMonth;
@synthesize switchDictionary, ledgendColorsDictionary, tempDict;
@synthesize dataDictCopy, symbolsDictionary, scalesUpdateDict,hideSeriesArray;

int seriesCount;
bool gradientOn;
bool symbolOn;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize the calendar
        cal = [[NSCalendar currentCalendar] retain];
        stepLineMode = NO;
        gradientMode = NO;
        gradientOn = NO;
        symbolOn = NO;
        
        UIApplication *app = [UIApplication sharedApplication];
        VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // Setup Data
        [self fillGroupsDictionary];
        [self fillColors];
        [self fillSymbols];
        [self createSwitches];

        
        seriesData = [[NSMutableArray alloc] init];
        seriesDates = [[NSMutableArray alloc] init];
        
        
        // Pull all data; Initial
        if (self.dataDict == nil) 
        {
            self.dataDict = [NSMutableDictionary dictionaryWithDictionary:[self getChartDictionary]];
        }
        
        // Make backup copy of data
        if (self.dataDictCopy == nil) 
        {
            self.dataDictCopy = [NSMutableDictionary dictionaryWithDictionary:dataDict];
        }
        
        seriesCount = [[dataDictCopy allKeys] count];
        
        [self printData];
        
    }
    
    
   // NSLog(@"dataDict: %@",dataDict);
    
    return self;
}

- (void)toggleSeries;
{
    
  //  seriesMode = !seriesName;
    /*
    NSMutableDictionary *tempDictWorking = [NSMutableDictionary dictionaryWithDictionary:dataDictCopy];
    
    NSEnumerator *enumerator = [switchDictionary keyEnumerator];
	id key;
	
	UISwitch *mySwitch;
	
	while ((key = [enumerator nextObject])) 
    {
        
		mySwitch = [switchDictionary objectForKey:key];
        
        if (!mySwitch.on) // is Off
        {
            // Turn Off
            [tempDictWorking removeObjectForKey:key];
        }
        else // is On
        {
            // Turn On
            [tempDictWorking setObject:[dataDict objectForKey:key] forKey:key];
            
        }
        
	}
    
    [dataDictCopy removeAllObjects];
    [dataDictCopy addEntriesFromDictionary:tempDictWorking];
    */
    
    [self createSwitches];
    
}

- (void)toggleGradient
{
    gradientMode = !gradientMode;
}

- (void)toggleSymbol
{
    symbolMode = !symbolMode;
    
}

- (void) printData
{
    //   NSLog(@"dataDict: %@", dataDict);
}

- (NSDate *)dateFromString:(NSString *)str
{

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
    NSDate *myDate = [df dateFromString: str];
    
    
    
    return myDate;
}

#pragma mark Data


#pragma mark Groups
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
        
        // Take last digit in array and use for color selection
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
          //  NSLog(@"groupTitle: %@ - aSwitch: %i",groupTitle,  aSwitch.on);

			[aSwitch release];
		}
	}
}

- (NSDictionary *)getChartDictionary
{
    NSMutableArray *arrayByDate = [[NSMutableArray alloc] init];
    [arrayByDate addObject:@"0"];
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
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
	NSPredicate *visiblePredicate;
	NSArray *finalPredicateArray;
	NSPredicate *finalPredicate;
    
    // NSLog(@"PUKE: %@", groupsDictionary);
    
	for (NSString *groupTitle in self.groupsDictionary) 
    {
		//Group *currentGroup = [self.groupsDictionary objectForKey:groupTitle];
        //NSLog(@"switchDictionary: %@", switchDictionary);
		UISwitch *currentSwitch = [switchDictionary objectForKey:groupTitle];

			groupPredicateString = [NSString stringWithFormat:@"group.title like %%@"];
            
			titlePredicate = [NSPredicate predicateWithFormat:groupPredicateString, groupTitle];
			visiblePredicate = [NSPredicate predicateWithFormat:@"group.visible == TRUE"];
			finalPredicateArray = [NSArray arrayWithObjects:titlePredicate,visiblePredicate, nil];
			finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
			[fetchRequest setPredicate:finalPredicate];
			[fetchRequest setFetchBatchSize:0];
			
			NSError *error = nil;
			results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
			if (error) {
				[Error showErrorByAppendingString:@"could not get result data for graph" withError:error];
			} 
			else 
            {
                NSMutableArray *tempTotalArray = [[NSMutableArray alloc] init];
                NSMutableArray *tempCountArray = [[NSMutableArray alloc] init];
                
                
                if (results.count > 0) 
                { 
                    
                    
                    int value = 0;
                    int day = 0;
                    int month = 0;
                    int year = 0; 
                    NSString *timeStamp = @"";
                    NSString *lastTimeStamp = @"";
                    NSString *nn = @"";
                    
                    int count = 1;
                    int totalCount = 1;
                    int totalValue = 0;
                    bool initRun = YES;
                    int avgValue = 0;
                    
                    // Set up temp arrays for averaging
                    for (Result *groupResult in results) 
                    {
                        timeStamp = [NSString stringWithFormat:@"%@",groupResult.timestamp];
                        value = [groupResult.value intValue];
                        day = [groupResult.day intValue] - 1;
                        month = [groupResult.month intValue];
                        year = [groupResult.year intValue]; 
                        nn = groupResult.group.title;
                        
                        
                        if ([lastTimeStamp isEqualToString:timeStamp]) 
                        {
                            count++;  
                            totalValue = totalValue + value;
                            if (totalCount == results.count) 
                            {
                                //NSLog(@"count: %i totalcount: %i totalvalue: %i", count, results.count, totalValue);
                                
                                //End of Results; Do Average
                                avgValue = totalValue / count;
                                
                                // Format DateTime
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
                                NSDate *date  = [dateFormatter dateFromString:lastTimeStamp];
                                
                                // Convert Date 
                                [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
                                NSString *newDate = [dateFormatter stringFromDate:date];
                                
                                // Add to array
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%@",nn]];
                                
                                [tempCountArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                                [tempCountArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                                [tempCountArray addObject:[NSString stringWithFormat:@"%@",nn]];
                                avgValue = 0;
                            }
                        }
                        else 
                        {
                            if (initRun) 
                            {
                                initRun = NO; 
                                totalValue = value;
                            }
                            else 
                            {
                                // NSLog(@"resultRow: %@ - %@: value=%i totalValue:%i averageValue:%i", nn, timeStamp, value, totalValue, avgValue);
                                
                                //End of common timestamps; Do Average
                                avgValue = totalValue / count;       
                                
                                // Format DateTime
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
                                NSDate *date  = [dateFormatter dateFromString:lastTimeStamp];
                                
                                // Convert Date 
                                [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
                                NSString *newDate = [dateFormatter stringFromDate:date];
                                
                                // Add to array
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                                [tempTotalArray addObject:[NSString stringWithFormat:@"%@",nn]];
                                
                                [tempCountArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                                [tempCountArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                                [tempCountArray addObject:[NSString stringWithFormat:@"%@",nn]];
                                
                                count = 1;
                                totalValue = value;
                                
                            }
                            
                        }
                        
                        totalCount++;
                        lastTimeStamp = timeStamp;
                        
                    }
                    //NSLog(@"tempTotalArray: %@", tempTotalArray);
                    bool doesExist = NO;
                    
                    for (int i = 0; i < tempTotalArray.count; i+=3) 
                    {
                        doesExist = NO;
                        
                        for (int a = 0; a < arrayByDate.count; a++) 
                        {
                            //NSLog(@"arrayByDate:%@ count:%i",[arrayByDate objectAtIndex:a], a);
                            //NSLog(@"tempTotalArray:%@ count:%i",[tempTotalArray objectAtIndex:i], i);
                            
                            
                            
                            if ([[arrayByDate objectAtIndex:a] isEqualToString:[tempTotalArray objectAtIndex:i]] && [[arrayByDate objectAtIndex:a + 3] isEqualToString:[tempTotalArray objectAtIndex:i + 2]])
                            {
                                doesExist = YES;
                                
                                // Update array; Add value to total; 
                                [arrayByDate replaceObjectAtIndex:a + 1 withObject:[NSString stringWithFormat:@"%i",[[arrayByDate objectAtIndex:a + 1] intValue] + [[tempTotalArray objectAtIndex:i + 1] intValue]]];
                                // +1 to value count
                                [arrayByDate replaceObjectAtIndex:a + 2 withObject:[NSString stringWithFormat:@"%i",[[arrayByDate objectAtIndex:a + 2] intValue] + 1]];
                                
                            }
                        }
                        
                        if (!doesExist) 
                        {
                            // Add to array
                            [arrayByDate addObject:[tempTotalArray objectAtIndex:i]];
                            [arrayByDate addObject:[tempTotalArray objectAtIndex:i + 1]];
                            [arrayByDate addObject:@"1"];
                            [arrayByDate addObject:[NSString stringWithFormat:@"%@",nn]];
                        }
                    }
                    
                    
                    
                } // Results    
                
			}			
		
	}
	
    
    // Raw Data rawValuesArray
    
    
    NSArray *objects = [self.groupsDictionary allKeys];
    NSMutableDictionary *chartDictionary = [[NSMutableDictionary alloc] init];
    
    
    for (NSString *groupTitle in objects)
    {
        NSMutableArray *rawValuesArray = [[NSMutableArray alloc] init];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSMutableArray *dateArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
        int averageValue = 0;
        NSString *tempDate = @"";
        
        for (int i = 1; i < [arrayByDate count]; i+=4) 
        {
            // Average
            averageValue = [[arrayByDate objectAtIndex:i + 1] intValue] / [[arrayByDate objectAtIndex:i + 2] intValue];
            tempDate = [arrayByDate objectAtIndex:i];
            [rawValuesArray addObject:[arrayByDate objectAtIndex:i + 3]];
            [rawValuesArray addObject:[arrayByDate objectAtIndex:i]];
            [rawValuesArray addObject:[NSString stringWithFormat:@"%i", averageValue]];
        }
        
        // Build components of final dictionary
        
        // Make arrays
        for (int i = 0; i < [rawValuesArray count]; i+=3) 
        {
            if ([[rawValuesArray objectAtIndex:i] isEqualToString:groupTitle]) 
            {
                [dataArray addObject:[rawValuesArray objectAtIndex:i + 2]];
                [dateArray addObject:[rawValuesArray objectAtIndex:i + 1]];
            }
        }
        
        [valueDict setObject:dataArray forKey:@"data"];
        [valueDict setObject:dateArray forKey:@"date"];
        [chartDictionary setObject:valueDict forKey:groupTitle];
        
    }    
    
    
	[yearDescriptor release];
	[monthDescriptor release];
	[dayDescriptor release];
	[groupTitleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
    [arrayByDate release];
    
    // NSLog(@"chartDictionary:%@",chartDictionary);
    
	return chartDictionary;
}


- (void) dealloc {
	[cal release];
    [scalesUpdateDict release];
    [symbolsDictionary release];
	[super dealloc];
}

-(void)toggleSeriesType {
    stepLineMode = !stepLineMode;
}

- (int) getSeriesDataCount:(int) seriesIndex
{
    int seriesDataCount = 1;
    NSString *grpName = [[groupsArray objectAtIndex:seriesIndex] title];
    
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDict objectForKey:grpName]];
    
    NSArray *tempGrpArray = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"data"]]; 
    
    seriesDataCount = [tempGrpArray count];
    
    // NSLog(@"seriesDataCount: %i", seriesDataCount);
    return seriesDataCount;
}

#pragma mark -
#pragma mark Datasource Protocol Functions

// Returns the number of points for a specific series in the specified chart
- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    //In our example, all series have the same number of points
    int numPoints = 0;  
    
    
    // Limit the points to 500/group
    numPoints = [self getSeriesDataCount:seriesIndex];
    
    return numPoints;
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index 
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *grpName = [[groupsArray objectAtIndex:index] title];
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    
    // Our series are either of type SChartLineSeries or SChartStepLineSeries depending on stepLineMode.
    SChartLineSeries *lineSeries = stepLineMode? 
    [[[SChartStepLineSeries alloc] init] autorelease]:
    [[[SChartLineSeries alloc] init] autorelease];
    
    lineSeries.style.lineWidth = [NSNumber numberWithInt: 2];
    
    // Symbol size depending on device
    NSNumber *symbolSize = [NSNumber numberWithInt:5];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        symbolSize = [NSNumber numberWithInt:8];
    } 
    
    
    NSData *data = [tColorDict objectForKey:grpName];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    UIImage *image = [self UIImageForIndex:[[tSymbolDict objectForKey:grpName] intValue]];
    
    // Symbol
    lineSeries.style.pointStyle.texture = image;
    lineSeries.style.pointStyle.radius = symbolSize;
    lineSeries.style.pointStyle.showPoints = symbolMode?YES:NO;
    
    [lineSeries setTitle:grpName];
    
    

    
    // lineSeries.style.lineColorBelowBaseline = [UIColor colorWithRed:227.f/255.f green:182.f/255.f blue:0.f alpha:1.f];
    //  lineSeries.style.areaColorBelowBaseline = [UIColor colorWithRed:150.f/255.f green:120.f/255.f blue:0.f alpha:1.f];
    
    lineSeries.baseline = [NSNumber numberWithInt:0];
    
    // Gradient
    lineSeries.style.showFill = gradientMode?YES:NO;


    lineSeries.crosshairEnabled = NO;  
   // NSLog(@"switchDictionary: %@", switchDictionary);

    // Series On/Off
    NSString *myKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",grpName];
    BOOL mySwitch = [defaults boolForKey:myKey];
    
    if (!mySwitch) // is Off
    {
         NSLog(@"clearcolor");
        lineSeries.style.pointStyle.color = [UIColor clearColor];
        lineSeries.style.lineColor = [UIColor clearColor];
        lineSeries.style.areaColor = [UIColor clearColor];

    }
    else 
    {
        NSLog(@"normcolor: %@, %@", grpName,color);
        lineSeries.style.lineColor = color;
        lineSeries.style.pointStyle.color = color;
        lineSeries.style.areaColor = color;

    }
	

    
    
    return lineSeries;
}

// Returns the number of series in the specified chart
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart 
{
    return seriesCount;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    
    
    NSString *grpName = [[groupsArray objectAtIndex:seriesIndex] title];
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDict objectForKey:grpName]];
    
   // NSLog(@"grp: %@  - seriesInex: %i", grpName, seriesIndex);
    
    seriesData = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"data"]]; 
    seriesDates = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"date"]]; 
    
    
    
    // Construct a data point to return
    SChartDataPoint *datapoint = [[[SChartDataPoint alloc] init] autorelease];
    
    // For this example, we simply move one day forward for each dataIndex
    NSString * dateString = [seriesDates objectAtIndex:dataIndex];
    NSDate *date = [self dateFromString:dateString];
    
    datapoint.xValue = date;
    // datapoint.xValue = [series2Dates objectAtIndex:dataIndex];
    
    // Construct an NSNumber for the yValue of the data point
    datapoint.yValue = [NSNumber numberWithFloat:[[seriesData objectAtIndex:dataIndex] floatValue]];
    // datapoint.yValue = [NSNumber numberWithFloat:[[series2Data objectAtIndex:dataIndex] floatValue] - 10000.f];
    
    // NSLog(@"series: %i", seriesIndex);
    //NSLog(@"xPlot: %@", date);
    //NSLog(@"yPlot: %@", [NSNumber numberWithFloat:[[seriesData objectAtIndex:dataIndex] floatValue]]);
    
    return datapoint;
}

/*
 - (UIImage *)sChartTextureForPoint:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex
 {
 UIImage *plotImage = [UIImage imageNamed:@"sliderknob.png"];
 
 return plotImage;  
 }
 */
@end
