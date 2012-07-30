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
@synthesize dataDict, groupsArray;
@synthesize saved, seriesData, seriesDates;

int seriesCount;
//static int seriesCount;


- (id)init
{
    self = [super init];
    if (self) {


        self.dataDict = [NSMutableDictionary dictionaryWithDictionary:[self getChartDictionary]];
        NSLog(@"dataDict: %@", dataDict);
       // NSLog(@"groupsArray: %@", groupsArray);
        
        seriesData = [[NSMutableArray alloc] init];
        seriesDates = [[NSMutableArray alloc] init];
        
        
        seriesCount = [[dataDict allKeys] count];
        
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
    
    NSString *grpName = [groupsArray objectAtIndex:seriesIndex];
    
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDict objectForKey:grpName]];
    
    NSArray *tempGrpArray = [NSArray arrayWithArray:[tempGrpDict objectForKey:@"data"]]; 
    
    seriesCount = [tempGrpArray count];

    
    return seriesCount;
}

- (NSDictionary *)getChartDictionary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempFileName = [defaults objectForKey:@"savedName"];

    
    
    // Open CSV File
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, tempFileName];
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath 
                                                       encoding:NSUTF8StringEncoding error:nil];

    NSMutableArray *arrayByDate = [[NSMutableArray alloc] init];
    [arrayByDate addObject:@"0"];
    
    NSArray *rawDataArray = [fileContents componentsSeparatedByString:@"NOTES,-,-,-"];
    NSArray* allLinedStrings = [[rawDataArray objectAtIndex:0] componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    
    
    NSMutableArray *tempTotalArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempCountArray = [[NSMutableArray alloc] init];
    

    int value = 0;
    NSString *timeStamp = @"";
    NSString *lastTimeStamp = @"";
    NSString *nn = @"";
    NSString *lastGroupName = @"";
    int count = 1;
    int totalCount = 1;
    int totalValue = 0;
    bool initRun = YES;
    int avgValue = 0;
    NSString *scale;
    int positiveDesc = 0;
    NSMutableArray *groupNames = [[NSMutableArray alloc] init];

    
    
    // Set up temp arrays for averaging
    for (int i=0; i < allLinedStrings.count; i++)
    {
        
        NSString *tempString1 = [allLinedStrings objectAtIndex:i];
        NSArray * list = [tempString1 componentsSeparatedByString:@","];

        if (list.count != 1) 
        {
            
            
            timeStamp = [NSString stringWithFormat:@"%@",[list objectAtIndex:0]];
            value = [[list objectAtIndex:3] intValue];
            scale = [list objectAtIndex:2];
            nn = [list objectAtIndex:1];
            positiveDesc = [[list objectAtIndex:4] intValue];
            //  NSLog(@"positive: %@ - %@", nn,positiveDesc);
            
           // NSLog(@"row: %@, %@, %@, %i", timeStamp, nn, scale, value);
            
            // Check if Group exists
            if (![groupNames containsObject:nn]) 
            {
                [groupNames addObject:nn];
            }

          
            if ([lastTimeStamp isEqualToString:timeStamp]) 
            {
              //  NSLog(@"isEqual");

                count++;  
                totalValue = totalValue + value;

                if (totalCount == allLinedStrings.count - 1) 
                {
                    //End of Results; Do Average
                    avgValue = totalValue / count;
                    
                    // Format DateTime
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
                    NSDate *date  = [dateFormatter dateFromString:timeStamp];
                    
                    // Convert Date 
                    [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
                    NSString *newDate = [dateFormatter stringFromDate:date];
                    
                    // Add to array
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%@",nn]];
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%i",positiveDesc]];

                    
                    [tempCountArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%@",nn]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%i",positiveDesc]];

                    avgValue = 0;
                }
            }
            else 
            {
              //  NSLog(@"notEqual");
                if (initRun) 
                {
                 //   NSLog(@"group:%@", nn);

                    initRun = NO; 
                    totalValue = value;
                }
                else 
                {
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
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%@",lastGroupName]];
                    [tempTotalArray addObject:[NSString stringWithFormat:@"%i",positiveDesc]];
                    
                    [tempCountArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%i",avgValue]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%@",lastGroupName]];
                    [tempCountArray addObject:[NSString stringWithFormat:@"%i",positiveDesc]];
                    
                    count = 1;
                    totalValue = value;
                    
                }
                
            }


      
        }
        totalCount++;
        lastTimeStamp = timeStamp;
        lastGroupName = nn;

    }
    
    
    bool doesExist = NO;

    for (int i = 0; i < tempTotalArray.count; i+=4) 
    {
        doesExist = NO;
        
        for (int a = 0; a < arrayByDate.count; a++) 
        {
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
            [arrayByDate addObject:[tempTotalArray objectAtIndex:i + 2]];
            [arrayByDate addObject:[tempTotalArray objectAtIndex:i + 3
                                    ]];

            
        }
    }
   // NSLog(@"arrayByDate:%@", arrayByDate);
    NSMutableDictionary *chartDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *groupTitle in groupNames)
    {
        NSMutableArray *rawValuesArray = [[NSMutableArray alloc] init];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSMutableArray *dateArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
        int averageValue = 0;
        NSString *tempDate = @"";
        
        for (int i = 1; i < [arrayByDate count]; i+=5) 
        {
            // Average
            averageValue = [[arrayByDate objectAtIndex:i + 1] intValue] / [[arrayByDate objectAtIndex:i + 2] intValue];
            // NSLog(@"positive: %i", [[arrayByDate objectAtIndex:i + 4] intValue]);
            
            if ([[arrayByDate objectAtIndex:i + 4] intValue] == 0) 
            {
                averageValue = 100 - averageValue;
            }
            
            
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
    

    
  //  NSLog(@"chartDictionary: %@",chartDictionary);
    self.groupsArray = [NSArray arrayWithArray:groupNames];
    [groupNames release];
    return chartDictionary;
}

- (NSDate *)dateFromString:(NSString *)str
{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
    NSDate *myDate = [df dateFromString: str];
    
    
    
    return myDate;
}


#pragma mark -
#pragma mark Datasource Protocol Functions

// Returns the number of points for a specific series in the specified chart
- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    //In our example, all series have the same number of points
    int numPoints = 0;  
    //NSLog(@"numberdatapoints");
    
    // Limit the points to 500/group
    numPoints = [self getSeriesDataCount:seriesIndex];
    
    return numPoints;
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index 
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *grpName = [groupsArray objectAtIndex:index];
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
    
    // Symbol
    lineSeries.style.pointStyle.texture = image;
    lineSeries.style.pointStyle.radius = symbolSize;
    lineSeries.style.pointStyle.showPoints = YES;
    
    [lineSeries setTitle:grpName];
    
    lineSeries.baseline = [NSNumber numberWithInt:0];
    
    // Gradient
    lineSeries.style.showFill = NO;
    
    lineSeries.crosshairEnabled = NO;  

    
    lineSeries.style.lineColor = color;
    lineSeries.style.pointStyle.color = color;
    lineSeries.style.areaColor = color;

    return lineSeries;
}

// Returns the number of series in the specified chart
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart 
{
    return seriesCount;//seriesCount;
    
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex 
{
    NSString *grpName = [groupsArray objectAtIndex:seriesIndex];
    NSDictionary *tempGrpDict = [NSDictionary dictionaryWithDictionary:[dataDict objectForKey:grpName]];
   // NSLog(@"forseriesatindex");

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


@end
