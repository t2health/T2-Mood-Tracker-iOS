//
//  PDFDataSource.m
//  VAS002
//
//  Created by Melvin Manzano on 8/10/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "PDFDataSource.h"

#import "Saved.h"



@implementation PDFDataSource
@synthesize dataDict, groupsArray;
@synthesize saved, seriesData, seriesDates;

int seriesCount;
//static int seriesCount;


- (id)init
{
    self = [super init];
    if (self) {
        
        /*
         self.dataDict = [NSMutableDictionary dictionaryWithDictionary:[self getChartDictionary]];
         NSLog(@"dataDict: %@", dataDict);
         // NSLog(@"groupsArray: %@", groupsArray);
         
         seriesData = [[NSMutableArray alloc] init];
         seriesDates = [[NSMutableArray alloc] init];
         
         
         seriesCount = [[dataDict allKeys] count];
         */
    }
    return self;
}

- (NSDictionary *)getScaleDictionary:(NSString *)groupName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempFileName = [defaults objectForKey:@"savedName"];
    
    NSMutableDictionary *dataScalesDict = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableArray *dataArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *dateArray = [[[NSMutableArray alloc] init] autorelease];
    
    NSDictionary *groupScaleDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"PDF_GroupScaleDictionary"]];
    
    
    NSArray *scalesArray = [groupScaleDict objectForKey:groupName];
    
    
    // Open CSV File
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, tempFileName];
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath 
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *arrayByDate = [[[NSMutableArray alloc] init] autorelease];
    [arrayByDate addObject:@"0"];
    
    NSArray *rawDataArray = [fileContents componentsSeparatedByString:@"NOTES,-,-,-"];
    NSArray* allLinedStrings = [[rawDataArray objectAtIndex:0] componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    // Add lines that match scaleName to tempDataDict
    //  NSLog(@"allLinedStrings: %@", allLinedStrings);
    
    int value = 0;
    NSString *timeStamp = @"";
    NSString *nn = @"";
    NSString *scale;
    //  int positiveDesc = 0;
    
    // Loop over each scale in groupName
    for (int a=0; a < scalesArray.count; a++) 
    {
        NSString *scaleName = [scalesArray objectAtIndex:a];
        NSMutableDictionary *scaleDictTemp = [[NSMutableDictionary alloc] init];
        [scaleDictTemp setObject:dataArray forKey:@"data"];
        [scaleDictTemp setObject:dateArray forKey:@"date"];
        
        [dataScalesDict setObject:scaleDictTemp forKey:scaleName];
        [scaleDictTemp release];
    } 
    
    // Loop over all lines in CSV
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
            //positiveDesc = [[list objectAtIndex:4] intValue];
            
            // Format DateTime
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
            NSDate *date  = [dateFormatter dateFromString:timeStamp];
            
            // Convert Date 
            [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
            NSString *newDate = [dateFormatter stringFromDate:date];
            [dateFormatter release];        
            if ([groupName isEqualToString:nn]) 
            {
                NSMutableDictionary *tempDataDictionary = [NSMutableDictionary dictionaryWithDictionary:[dataScalesDict objectForKey:scale]];
                NSMutableArray *dataTempArray = [NSMutableArray arrayWithArray:[tempDataDictionary objectForKey:@"data"]];
                NSMutableArray *dateTempArray = [NSMutableArray arrayWithArray:[tempDataDictionary objectForKey:@"date"]];
                
                /*
                if ([[list objectAtIndex:4] intValue] == 0) 
                {
                    value = 100 - value;
                }
                */
                [dataTempArray addObject:[NSString stringWithFormat:@"%i",value]];
                [dateTempArray addObject:[NSString stringWithFormat:@"%@",newDate]];
                [tempDataDictionary setObject:dataTempArray forKey:@"data"];
                [tempDataDictionary setObject:dateTempArray forKey:@"date"];
                
                [dataScalesDict setObject:tempDataDictionary forKey:scale];
                
            }           
            // NSLog(@"%@ Row: %@-%i-%@", groupName, scale, value, newDate);
            
        }
        
    }
    
    return dataScalesDict;
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
    
    NSMutableArray *arrayByDate = [[[NSMutableArray alloc] init] autorelease];
    [arrayByDate addObject:@"0"];
    
    NSArray *rawDataArray = [fileContents componentsSeparatedByString:@"NOTES,-,-,-"];
    NSArray* allLinedStrings = [[rawDataArray objectAtIndex:0] componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    
    NSMutableArray *tempTotalArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *tempCountArray = [[[NSMutableArray alloc] init] autorelease];
    
    
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
    // NSString *scale;
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
            // scale = [list objectAtIndex:2];
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
                    [dateFormatter release];
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
                    [dateFormatter release];
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
    NSMutableDictionary *chartDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *groupTitle in groupNames)
    {
        NSMutableArray *rawValuesArray = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *dataArray = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *dateArray = [[[NSMutableArray alloc] init] autorelease];
        NSMutableDictionary *valueDict = [[[NSMutableDictionary alloc] init] autorelease];
        int averageValue = 0;
        NSString *tempDate = @"";
        
        for (int i = 1; i < [arrayByDate count]; i+=5) 
        {
            // Average
            averageValue = [[arrayByDate objectAtIndex:i + 1] intValue] / [[arrayByDate objectAtIndex:i + 2] intValue];
            // NSLog(@"positive:  %i", [[arrayByDate objectAtIndex:i + 4] intValue]);
            
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
    [df release];
    
    
    return myDate;
}



@end
