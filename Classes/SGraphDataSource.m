//
//  GraphDataSource.m
//  VAS002
//
//  Created by Melvin Manzano on 5/2/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "SGraphDataSource.h"
#import "VAS002AppDelegate.h"
#import "Result.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "ViewNotesViewController.h"
#import "Error.h"
#import "Note.h"
#import "Group.h"
#import "Scale.h"
#import "GroupResult.h"
#import "DateMath.h"

@implementation SGraphDataSource

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
@synthesize switchDictionary, ledgendColorsDictionary, tempDict, symbolsDictionary;
@synthesize dataDictCopy, scalesArray, scalesDictionary, groupName, scalesUpdateDict;

int seriesCount;
bool gradientOn;
bool symbolOn;

int seriesCount;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize the calendar
        cal = [[NSCalendar currentCalendar] retain];
        stepLineMode = NO;
        
        UIApplication *app = [UIApplication sharedApplication];
        VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // Setup Data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.groupName = [defaults objectForKey:@"subGraphSelected"];
        
        [self fillScalesDictionary];
        [self fillColors];
        [self fillSymbols];
        [self createSwitches];
        
        seriesData = [[NSMutableArray alloc] init];
        seriesDates = [[NSMutableArray alloc] init];
        
        
        // Pull all data; Initial
        if (self.dataDict == nil) 
        {
            self.dataDict = [NSMutableDictionary dictionaryWithDictionary:[self getChartDictionary]];
            NSLog(@"dataDict: %@", dataDict);        }
        
        // Make backup copy of data
        if (self.dataDictCopy == nil) 
        {
            self.dataDictCopy = [NSMutableDictionary dictionaryWithDictionary:dataDict];
        }
        
        seriesCount = [[dataDictCopy allKeys] count];
        
        [self printData];
        
    }
    return self;
}

- (void)toggleSeriesOn:(NSMutableDictionary *)switchDict
{
    NSMutableDictionary *tempDictWorking = [NSMutableDictionary dictionaryWithDictionary:dataDictCopy];
    
    NSEnumerator *enumerator = [switchDict keyEnumerator];
	id key;
	
	UISwitch *mySwitch;
	
	while ((key = [enumerator nextObject])) 
    {
        
		mySwitch = [switchDict objectForKey:key];
        
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
    
}

- (void)toggleGradient:(bool)isOn
{
    
    if (isOn) 
    {
        gradientOn = YES;
    }
    else 
    {
        gradientOn = NO;
    }
    
}

- (void)toggleSymbol:(bool)isOn
{
    if (isOn) 
    {
        symbolOn = YES;
    }
    else 
    {
        symbolOn = NO;
    }
    
}


- (void) printData
{
    //   NSLog(@"dataDict: %@", dataDict);
}

- (NSDate *)dateFromString:(NSString *)str
{
    static BOOL monthLookupTableInitialised = NO;
    static NSMutableArray *monthIdx;
    static NSArray *monthNames;
    static NSDictionary *months;
    
    if (!monthLookupTableInitialised) {
        monthIdx = [[NSMutableArray alloc] init ];
        for (int i = 1; i <= 12; ++i) {
            [monthIdx addObject:[NSNumber numberWithInt:i]];
        }
        
        monthNames = [[NSArray alloc] initWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
        months = [[NSDictionary alloc] initWithObjects:monthIdx forKeys:monthNames];
        monthLookupTableInitialised = YES;
    }
    
    NSRange dayRange = NSMakeRange(0,2);
    NSString *dayString = [str substringWithRange:dayRange];
    NSUInteger day = [dayString intValue];
    
    NSRange monthRange = NSMakeRange(3, 3);
    NSString *monthString = [str substringWithRange:monthRange];
    NSUInteger month = [[months objectForKey:monthString] unsignedIntValue];
    
    NSRange yearRange = NSMakeRange(7, 4);
    NSString *yearString = [str substringWithRange:yearRange];
    NSUInteger year = [yearString intValue];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components];
    
    [components release];
    [gregorian release];
    
    return date;
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
		for (NSString *gName in sortedKeys) {
			[grpArray addObject:[self.groupsDictionary objectForKey:gName]];
		}
		self.groupsArray = [NSArray arrayWithArray:grpArray];
        // NSLog(@"grpArray: %@", grpArray);
	}
}


#pragma mark fill symbols
- (void)fillSymbols
{
	if (self.symbolsDictionary == nil) {
		self.symbolsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.scalesDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
            
			UIImage *image = [self UIImageForIndex:index];
            
			[self.symbolsDictionary setObject:image forKey:groupTitle];
			index++;
		}
	}    
    // NSLog(@"symbolsDictionary: %@", symbolsDictionary);
}

-(UIImage *)UIImageForIndex:(NSInteger)index {
	NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Symbol_Clover.png"], [UIImage imageNamed:@"Symbol_Club.png"], [UIImage imageNamed:@"Symbol_Cross.png"], [UIImage imageNamed:@"Symbol_Davidstar.png"], [UIImage imageNamed:@"Symbol_Diamondclassic.png"], [UIImage imageNamed:@"Symbol_Diamondring.png"], [UIImage imageNamed:@"Symbol_Doublehook.png"], [UIImage imageNamed:@"Symbol_Fivestar.png"], [UIImage imageNamed:@"Symbol_Heart.png"], [UIImage imageNamed:@"Symbol_Triangle.png"], [UIImage imageNamed:@"Symbol_Circle.png"], [UIImage imageNamed:@"Symbol_Hourglass.png"], [UIImage imageNamed:@"Symbol_Moon.png"], [UIImage imageNamed:@"Symbol_Skew.png"], [UIImage imageNamed:@"Symbol_Pentagon.png"], [UIImage imageNamed:@"Symbol_Spade.png"], nil];
	
	UIImage *image = nil;
	///NSLog(@"imageArray: %@", imageArray);
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

#pragma mark fill scales

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
		
		NSArray *objects = [self.scalesDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
			UIColor *color = [self UIColorForIndex:index];
			[self.ledgendColorsDictionary setObject:color forKey:groupTitle];
			index++;
		}
	}
    
    // NSLog(@"colorDict: %@", ledgendColorsDictionary);
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
		
		NSArray *grpArray = [[self.scalesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
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

#pragma mark Get Chart Dictionary
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
	NSSortDescriptor *scaleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scale" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:yearDescriptor, monthDescriptor,dayDescriptor, scaleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *scalePredicateString = @"";
	
	NSArray *results;
	NSString *groupPredicateString;
	NSPredicate *groupPredicate;
	NSPredicate *scalePredicate;
	//NSString *timePredicateString;
	//NSPredicate *timePredicate;
	NSArray *finalPredicateArray;
	NSPredicate *finalPredicate;
    
    //NSLog(@"1");
	for (NSString *scaleMinLabel in self.scalesDictionary) {
		UISwitch *currentSwitch = [switchDictionary objectForKey:scaleMinLabel];
        
        //   NSLog(@"2");
		if (currentSwitch.on == YES) {
			Scale *currentScale = [scalesDictionary objectForKey:scaleMinLabel];
			Group *currentGroup = currentScale.group;
			
			groupPredicateString = [NSString stringWithFormat:@"group.title like %%@"];
			groupPredicate = [NSPredicate predicateWithFormat:groupPredicateString, currentGroup.title];
			scalePredicateString = [NSString stringWithFormat:@"scale.minLabel like %%@"];
			scalePredicate = [NSPredicate predicateWithFormat:scalePredicateString, scaleMinLabel];
			//timePredicateString = [NSString stringWithFormat:@"(year == %%@) && (month == %%@)"];
			//timePredicate = [NSPredicate predicateWithFormat:timePredicateString, [ NSNumber numberWithInt:self.chartYear], [NSNumber numberWithInt:self.chartMonth]];
			
			finalPredicateArray = [NSArray arrayWithObjects:groupPredicate, scalePredicate, nil];
			
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
                    NSString *nn = @"";
                    NSString *monthStr = @"";
                    NSString *dayStr = @"";
                    
                    // Set up temp arrays for averaging
                    for (GroupResult *groupResult in results) 
                    {
                        value = [groupResult.value intValue];
                        day = [groupResult.day intValue] - 1;
                        month = [groupResult.month intValue];
                        year = [groupResult.year intValue]; 
                        nn = scaleMinLabel;
                        //  NSLog(@"name: %@ value:%i day:%i month:%i year:%i", nn, value, day, month, year);
                        // Yah yah, dateformatter would have been better....
                        if (month == 1) {monthStr = @"Jan";}
                        if (month == 2) {monthStr = @"Feb";}
                        if (month == 3) {monthStr = @"Mar";}
                        if (month == 4) {monthStr = @"Apr";}
                        if (month == 5) {monthStr = @"May";}
                        if (month == 6) {monthStr = @"Jun";}
                        if (month == 7) {monthStr = @"Jul";}
                        if (month == 8) {monthStr = @"Aug";}
                        if (month == 9) {monthStr = @"Sep";}
                        if (month == 10) {monthStr = @"Oct";}
                        if (month == 11) {monthStr = @"Nov";}
                        if (month == 12) {monthStr = @"Dec";}
                        
                        if ([[NSString stringWithFormat:@"%i",day] length] < 2) 
                        {
                            dayStr = [NSString stringWithFormat:@"0%i",day];
                        }
                        else 
                        {
                            dayStr = [NSString stringWithFormat:@"%i",day];
                        }
                        
                        // Convert Date 
                        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%i", dayStr, monthStr, year];
                        
                        
                        [tempTotalArray addObject:[NSString stringWithFormat:@"%@",dateString]];
                        [tempTotalArray addObject:[NSString stringWithFormat:@"%i",value]];
                        [tempTotalArray addObject:[NSString stringWithFormat:@"%@",nn]];
                        
                        [tempCountArray addObject:[NSString stringWithFormat:@"%@",dateString]];
                        [tempCountArray addObject:[NSString stringWithFormat:@"%i",value]];
                        [tempCountArray addObject:[NSString stringWithFormat:@"%@",nn]];
                        
                    }
                    
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
	}
	
    
    // Raw Data rawValuesArray
    //NSLog(@"arrayByDate: %@", arrayByDate);
    
    NSArray *objects = [self.scalesDictionary allKeys];
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
	//[groupTitleDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
    [arrayByDate release];
    
    
    NSLog(@"chartDictionary:%@",chartDictionary);
    
    return chartDictionary;
}


#pragma mark helpers

- (void) dealloc {
	[cal release];
	[super dealloc];
}

-(void)toggleSeriesType {
    stepLineMode = !stepLineMode;
}

- (int) getSeriesDataCount:(int) seriesIndex
{
    int seriesDataCount = 1;
    NSString *grpName = [[scalesArray objectAtIndex:seriesIndex] minLabel];
    
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDictCopy objectForKey:grpName]];
    
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
    
    
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_COLOR_DICTIONARY"]];
    
    NSDictionary *symbolDictionary = [tSymbolDict objectForKey:self.groupName];
    NSDictionary *colorDictionary = [tColorDict objectForKey:self.groupName];
    NSString *grpName = [[scalesArray objectAtIndex:index] minLabel];
    
    
    // the image
    UIImage *image = [self UIImageForIndex:[[symbolDictionary objectForKey:grpName] intValue]];
    // the color
    NSData *data = [colorDictionary objectForKey:grpName];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    
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
    
    if (symbolOn) 
    {
        lineSeries.style.pointStyle.texture = image;
        lineSeries.style.pointStyle.radius = symbolSize;
        lineSeries.style.pointStyle.showPoints = YES;
        lineSeries.style.pointStyle.color = color;
    }
    else 
    {
        lineSeries.style.pointStyle.showPoints = NO;
    }
    lineSeries.style.lineColor = color;
    [lineSeries setTitle:grpName];
    
    
    lineSeries.style.areaColor = color;
    
    // lineSeries.style.lineColorBelowBaseline = [UIColor colorWithRed:227.f/255.f green:182.f/255.f blue:0.f alpha:1.f];
    //  lineSeries.style.areaColorBelowBaseline = [UIColor colorWithRed:150.f/255.f green:120.f/255.f blue:0.f alpha:1.f];
    
    lineSeries.baseline = [NSNumber numberWithInt:0];
    
    if (gradientOn) 
    {
        lineSeries.style.showFill = YES;
    }
    else 
    {
        lineSeries.style.showFill = NO;
    }
    
    
    lineSeries.crosshairEnabled = NO;  
    
    
    return lineSeries;
}

// Returns the number of series in the specified chart
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart 
{
    return seriesCount;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    
    
    NSString *grpName = [[scalesArray objectAtIndex:seriesIndex] minLabel];
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDictCopy objectForKey:grpName]];
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
