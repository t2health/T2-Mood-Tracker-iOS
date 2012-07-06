//
//  ChartPrintDataSource.m
//  VAS002
//
//  Created by Melvin Manzano on 6/28/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "ChartPrintDataSource.h"
#import "Saved.h"

@implementation ChartPrintDataSource
@synthesize dataDict;
@synthesize saved, seriesData, seriesDates;

static int seriesCount;


- (id)init
{
    self = [super init];
    if (self) {
        
        self.dataDict = [NSMutableDictionary dictionaryWithDictionary:[self getChartDictionary]];
    
        NSLog(@"chartData: %@", dataDict);
        
        seriesData = [[NSMutableArray alloc] init];
        seriesDates = [[NSMutableArray alloc] init];
        

    }
    return self;
}

#pragma mark Images for Symbols

-(UIImage *)UIImageForIndex:(NSInteger)index {
	NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Symbol_Clover.png"], [UIImage imageNamed:@"Symbol_Club.png"], [UIImage imageNamed:@"Symbol_Cross.png"], [UIImage imageNamed:@"Symbol_Davidstar.png"], [UIImage imageNamed:@"Symbol_Diamondclassic.png"], [UIImage imageNamed:@"Symbol_Diamondring.png"], [UIImage imageNamed:@"Symbol_Doublehook.png"], [UIImage imageNamed:@"Symbol_Fivestar.png"], [UIImage imageNamed:@"Symbol_Heart.png"], [UIImage imageNamed:@"Symbol_Triangle.png"], [UIImage imageNamed:@"Symbol_Circle.png"], [UIImage imageNamed:@"Symbol_Hourglass.png"], [UIImage imageNamed:@"Symbol_Moon.png"], [UIImage imageNamed:@"Symbol_Skew.png"], [UIImage imageNamed:@"Symbol_Pentagon.png"], [UIImage imageNamed:@"Symbol_Spade.png"], nil];
	
	UIImage *image = nil;
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

- (int)getSeriesDataCount:(int) seriesIndex
{
    int seriesCount = 0;
    
 //   NSString *grpName = [[groupsArray objectAtIndex:seriesIndex] title];
    
  //  NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDictCopy objectForKey:grpName]];
    
  //  NSArray *tempGrpArray = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"data"]]; 
    
   // seriesDataCount = [tempGrpArray count];

    
    return seriesCount;
}

- (NSDictionary *)getChartDictionary
{
    // Open CSV File
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, saved.filename];
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath 
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *tempAnxietyDate = [NSArray arrayWithObjects:@"06/23/2012", @"06/24/2012",  @"06/26/2012", nil];
    NSArray *tempAnxietyData = [NSArray arrayWithObjects:@"30", @"70",@"10", nil];
    
    
    NSArray *keysA = [NSArray arrayWithObjects:@"Data", @"Date", nil];
    NSArray *objectsA = [NSArray arrayWithObjects:tempAnxietyData, tempAnxietyDate, nil];
    NSDictionary *anxDict = [NSDictionary dictionaryWithObjects:objectsA 
                                                        forKeys:keysA];
    
    
    
    NSArray *tempDepressionDate = [NSArray arrayWithObjects:@"06/23/2012", @"06/24/2012",  @"06/26/2012", nil];
    NSArray *tempDepressionData = [NSArray arrayWithObjects:@"20", @"50",@"70", nil];

    
    NSArray *keysD = [NSArray arrayWithObjects:@"Data", @"Date", nil];
    NSArray *objectsD = [NSArray arrayWithObjects:tempDepressionData, tempDepressionDate, nil];
    NSDictionary *depDict = [NSDictionary dictionaryWithObjects:objectsD 
                                                                forKeys:keysD];
    
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"Anxiety", @"Depression", nil];
    NSArray *objects = [NSArray arrayWithObjects:anxDict, depDict, nil];
    NSDictionary *chartDictionary = [NSDictionary dictionaryWithObjects:objects 
                                                                forKeys:keys];

    
    return chartDictionary;
}


#pragma mark -
#pragma mark Datasource Protocol Functions

// Returns the number of points for a specific series in the specified chart
- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    //In our example, all series have the same number of points
    int numPoints = 0;  
    
    
    // Limit the points to 500/group
   // numPoints = [self getSeriesDataCount:seriesIndex];
    
    return 3;//numPoints;
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index 
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *grpName = @"placeholder";//[[groupsArray objectAtIndex:index] title];
    
    if (index == 0) 
    {
         grpName = @"Anxiety";//[[groupsArray objectAtIndex:index] title];
    }
    else 
    {
        grpName = @"Depression";//[[groupsArray objectAtIndex:index] title];

    }
    
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    
    // Our series are either of type SChartLineSeries or SChartStepLineSeries depending on stepLineMode.
    SChartLineSeries *lineSeries = [[[SChartLineSeries alloc] init] autorelease];
    
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
    lineSeries.style.pointStyle.texture = image;
    lineSeries.style.pointStyle.radius = symbolSize;
    lineSeries.style.pointStyle.showPoints = YES;
    lineSeries.style.pointStyle.color = color;
    
    lineSeries.style.lineColor = color;
    [lineSeries setTitle:grpName];
    
    
    lineSeries.style.areaColor = color;
    
    lineSeries.baseline = [NSNumber numberWithInt:0];
    
    lineSeries.style.showFill = NO;
    
    
    
    lineSeries.crosshairEnabled = NO;  
    
    
    return lineSeries;
}

// Returns the number of series in the specified chart
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart 
{
    return 2;//seriesCount;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex 
{
    // Construct a data point to return
    SChartDataPoint *datapoint = [[[SChartDataPoint alloc] init] autorelease];
    
    
    //NSString *grpName = [[groupsArray objectAtIndex:seriesIndex] title];
    
    
    NSString *grpName = @"placeholder";//[[groupsArray objectAtIndex:index] title];
    
    if (seriesIndex == 0) 
    {
        grpName = @"Anxiety";//[[groupsArray objectAtIndex:index] title];
    }
    else 
    {
        grpName = @"Depression";//[[groupsArray objectAtIndex:index] title];
        
    }

    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDict objectForKey:grpName]];
     seriesData = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"Data"]]; 
    seriesDates = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"Date"]]; 
    
  //  seriesData = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"data"]]; 
  //  seriesDates = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"date"]]; 

  //  NSLog(@"tempGrpDict: %@", tempGrpDict);
   // NSLog(@"seriesDates: %@", seriesDates);

    
    // For this example, we simply move one day forward for each dataIndex
    
    NSString * dateString = [seriesDates objectAtIndex:dataIndex];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    NSDate *myDate = [df dateFromString: dateString];
    [df setDateFormat:@"dd-MMM-yyyy"];
    NSString *dd = [df stringFromDate:myDate];
    myDate = [df dateFromString: dd];
    NSLog(@"myDate: %@", myDate);

    datapoint.xValue = myDate;
    
    // Construct an NSNumber for the yValue of the data point
    datapoint.yValue = [NSNumber numberWithFloat:[[seriesData objectAtIndex:dataIndex] floatValue]];
    
    return datapoint;
}


@end
