//
//  PDFService.m
//  PDF
//
//  Created by Masashi Ono on 09/10/25.
//  Copyright (c) 2009, Masashi Ono
//  All rights reserved.
//

#import "PDFService.h"
#import "PDFDataSource.h"

#import "Group.h"
#import "Result.h"
#import "Note.h"
#import "Scale.h"
#import "Result.h"



static PDFService *_instance;


void PDFService_defaultErrorHandler(HPDF_STATUS   error_no,
                                    HPDF_STATUS   detail_no,
                                    void         *user_data)
{
    PDFService_userData *userData = (PDFService_userData *)user_data;
    HPDF_Doc pdf = userData->pdf;
    PDFService *service = userData->service;
    NSString *filePath = userData->filePath;
    
    //  HPDF_ResetError(pdf)
    HPDF_Free(pdf);
    
    if (service.delegate) {
        [service.delegate service:service
         didFailedCreatingPDFFile:filePath
                          errorNo:error_no
                         detailNo:detail_no];
    }
}


@implementation PDFService
@synthesize managedObjectContext;
@synthesize delegate;

- (id) init
{
    //NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    self = [super init];
    if (self != nil) {
        //init code
    }
    return self;
}

- (void) dealloc
{
    // NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    [super dealloc];
}

+ (PDFService *)instance
{
    // NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    if (!_instance) {
        _instance = [[PDFService alloc] init];
    }
    return _instance;
}


- (void)createPDFFile
{
    // NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    // Creates a test PDF file to the specified path.
    // TODO: use UIImage to create non-optimized PNG rather than build target setting
    
    PDFDataSource *myDataSource = [[[PDFDataSource alloc] init] autorelease];
    NSDictionary *myObjects = [NSDictionary dictionaryWithDictionary:[myDataSource getChartDictionary]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // NSLog(@"groupScaleDictionaryService: %@", [defaults objectForKey:@"PDF_GroupScaleDictionary"]);
    
    NSDictionary *groupScaleDictionary = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"PDF_GroupScaleDictionary"]];
    
    // NSString *reportName = @"";
    // NSString *reportTitle = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, [defaults objectForKey:@"savedName"]];
    // NSLog(@"filePath is %@", filePath);
    
    //    reportName = saved.filename;
    //    reportTitle = saved.title;
    
    const char *pathCString = NULL;
    
    NSString *path = nil;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy h:mm:ss a"];
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath 
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *rawDataArray = [fileContents componentsSeparatedByString:@"NOTES,-,-,-"];
    // Get Notes
    NSMutableDictionary *notesDictionary = [NSMutableDictionary dictionaryWithDictionary:[self parseNotes:[rawDataArray objectAtIndex:1]]];
    NSArray *noteKeys = [notesDictionary allKeys];
    // NSLog(@"myObjects: %@", myObjects);
    
    
    // Today Date
    // get the current date
    NSDate *date = [NSDate date];
    
    // format it
    NSDateFormatter *dateFormatNow = [[NSDateFormatter alloc]init];
    [dateFormatNow setDateFormat:@"dd-MMM-yyyy hh:mm aaa"];
    
    // convert it to a string
    NSString *dateString = [dateFormatNow stringFromDate:date];
    
    // free up memory
    [dateFormatNow release];
    [dateFormat release];

    PDFService_userData userData;
    HPDF_Doc pdf = HPDF_New(PDFService_defaultErrorHandler, &userData);
    userData.pdf = pdf;
    userData.service = self;
    userData.filePath = filePath;
    int pageNumber = 0;
    HPDF_Page page;
    HPDF_UseJPFonts (pdf);
    HPDF_UseJPEncodings (pdf);
    HPDF_Font fontEn = HPDF_GetFont(pdf, "Helvetica", "StandardEncoding");
    
    
    const int maxLinesPerPage = 6;
    const int maxLinesPerSubPage = 10;
    const int maxLinesPerNotePage = 10;
    
    if (![[rawDataArray objectAtIndex:0] isEqualToString:@""]) 
    {
        
        // Summary Page
        NSArray *categoryNameArray = [groupScaleDictionary allKeys];
        
        page = HPDF_AddPage(pdf);
        HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
        HPDF_UINT16 DASH_MODE1[2];
        
        
        HPDF_Page_BeginText(page);
        HPDF_Page_SetFontAndSize(page, fontEn, 16.0);
        HPDF_Page_TextRect(page, dpi(0.25), dpi(10.75), dpi(8.0), dpi(2.0), [[NSString stringWithFormat: @"T2 Mood Tracker Report\nGenerated On: %@",dateString] UTF8String], HPDF_TALIGN_CENTER, nil);
        HPDF_Page_EndText(page);
        int counter = 0;
        
        for (int i = 0; i < categoryNameArray.count; i++) 
        {
            
            ////////////////////////////------------------- GRAPH SUMMARY
            // Pull Data
            NSDictionary *groupDict = [myObjects objectForKey:[categoryNameArray objectAtIndex:i]];
            NSArray *dateArray = [groupDict objectForKey:@"date"];
            NSArray *dataArray = [groupDict objectForKey:@"data"];
          //  NSLog(@"Category:%@ - %@",[categoryNameArray objectAtIndex:i], dataArray);
            
            int topValue = 0;
            NSString *topDateStr = @"";
            float topX = 0.0;
            float topY = 0.0;
            
            int lowValue = 100;
            NSString *lowDateStr = @"";
            float lowX = 0.0;
            float lowY = 0.0;
            
            
                // Check when to start new page
                if (counter == 6) 
                {
                    pageNumber++;
                    page = HPDF_AddPage(pdf);
                    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
                    counter = 0;
                }
                
                NSString *catName = @"";
            
                if (dataArray != nil && dataArray.count > 1) 
                {
                    catName = [NSString stringWithFormat:@"%@", [categoryNameArray objectAtIndex:i]];
                }
                else 
                {
                    catName = [NSString stringWithFormat:@"%@ (No Data)", [categoryNameArray objectAtIndex:i]];
                }
                
                HPDF_Page_BeginText(page);
                HPDF_Page_SetFontAndSize(page, fontEn, 18.0);
                HPDF_Page_TextRect(page, dpi(0.25), dpi(9.75)-(dpi(1.6) * (i%maxLinesPerPage)), dpi(8.0), dpi(1.0), [[NSString stringWithFormat: @"%@",catName] UTF8String], HPDF_TALIGN_LEFT, nil);
                HPDF_Page_EndText(page);
                
                
                
                // Set Bounderies
                float chart_width = dpi(8.0);
                float chart_height = dpi(1.2);
                float chart_startY = dpi(8.2)-(dpi(1.6) * (i%maxLinesPerPage));
                float chart_startX = dpi(0.25);
                //float chart_endX = chart_startX + chart_width;
                //float chart_endY = chart_startY + chart_height;
                float xIncrement = chart_width / dataArray.count;
                //float yIncrement = chart_height/100;
                
                
                // Draw Border
                HPDF_Page_SetDash(page, NULL, 0, 0); 
                
                HPDF_Page_SetLineWidth(page, 1.0);
                HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
                HPDF_Page_Rectangle(page, chart_startX, chart_startY, chart_width, chart_height);
                HPDF_Page_Stroke(page);
                // NSLog(@"width: %f, height: %f, x: %f-%f, y: %f-%f", chart_width, chart_height, chart_startX, chart_endX, chart_startY, chart_endY);
                
            if (dataArray != nil && dataArray.count > 1) 
            {         
                // Draw Points/Lines
                float stepX = chart_startX;
                HPDF_Page_SetRGBStroke(page, 1.0, 0, 0);
                for (int a=0; a < dataArray.count; a++) 
                {
                    float value = [[dataArray objectAtIndex:a] floatValue];
                    int intVal = [[dataArray objectAtIndex:a] intValue];
                    if (a == 0) 
                    {
                        HPDF_Page_Circle(page, stepX, chart_startY + value/2, .1);
                        
                    }
                    else 
                    {
                        HPDF_Page_LineTo(page, stepX, chart_startY + value/2);
                    }
                    
                    // Capture top/low values
                    
                    if (intVal > topValue) 
                    {
                        topValue = value;
                        topDateStr = [NSString stringWithFormat:@"%@",[dateArray objectAtIndex:a]];
                        topX = stepX;
                        topY = chart_startY + value/2;
                    }
                    
                    if (intVal < lowValue) 
                    {
                        lowValue = value;
                        lowDateStr = [NSString stringWithFormat:@"%@",[dateArray objectAtIndex:a]];
                        lowX = stepX;
                        lowY = chart_startY + value/2;
                        
                    }
                    
                    stepX += xIncrement;
                }
                HPDF_Page_Stroke(page);
                
                // Hi/Low Dates
             //   NSLog(@"hi: %i - %@: %f,%f", topValue, topDateStr, topX, topY);
             //   NSLog(@"low: %i - %@: %f,%f", lowValue, lowDateStr, lowX, lowY);
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss ZZZ"];
                NSDate *dateTop  = [dateFormatter dateFromString:topDateStr];
                NSDate *dateLow  = [dateFormatter dateFromString:lowDateStr];
                
                [dateFormatter setDateFormat:@"dd-MMM-yyyy hh:mm aaa"];
                NSString *topDate = [dateFormatter stringFromDate:dateTop];
                NSString *lowDate = [dateFormatter stringFromDate:dateLow];
                
                
                HPDF_Page_SetRGBStroke(page, 0.0, 1.0, 0.0);
                HPDF_Page_Circle(page, topX, topY, .5);
                HPDF_Page_Circle(page, lowX, lowY, .5);
                HPDF_Page_Stroke(page);
                
                HPDF_Page_BeginText(page);
                HPDF_Page_SetFontAndSize(page, fontEn, 8.0);
                HPDF_Page_TextRect(page, topX + 10, topY + 10, dpi(7.5), dpi(0.5), [[NSString stringWithFormat: @"%@",topDate] UTF8String], HPDF_TALIGN_LEFT, nil);
                HPDF_Page_SetFontAndSize(page, fontEn, 8.0);
                HPDF_Page_TextRect(page, lowX + 10, lowY + 10, dpi(7.5), dpi(0.5), [[NSString stringWithFormat: @"%@",lowDate
                                                                                     ] UTF8String], HPDF_TALIGN_LEFT, nil);
                HPDF_Page_EndText(page);
                
                // Draw Regression/Trend Line
                
                NSInteger theNumber = dataArray.count;
                
                float sumY = 0.0;
                float sumX = 0.0;
                float sumXY = 0.0;
                float sumX2 = 0.0;
                float sumY2 = 0.0;
                
                
                stepX = chart_startX;
                for (int c=0;c < dataArray.count;c++) 
                {
                    float stepY = [[dataArray objectAtIndex:c] floatValue];
                    sumX += stepX;
                    sumY += stepY;
                    sumXY += (stepX * stepY);
                    sumX2 += (stepX * stepX);
                    sumY2 += (stepY * stepY);
                    stepX += xIncrement;
                }
                
                float slope = ((theNumber * sumXY) - sumX * sumY) / ((theNumber * sumX2) - (sumX * sumX))/2;
                float intercept = ((sumY - (slope * sumX))/theNumber)/2;

                
                
             //   NSLog(@"slope: %f", slope);
              //  NSLog(@"intercept: %f", intercept);
              //  NSLog(@"correlation: %f", correlation);
              //  NSLog(@"reg_xs: %f", chart_startX);
              //  NSLog(@"reg_ys: %f", chart_startY + intercept);
              //  NSLog(@"reg_x: %f", chart_startX + chart_width);
              //  NSLog(@"reg_y: %f", ((chart_startY + intercept) + (slope * (chart_width/xIncrement))));
                
                DASH_MODE1[0] = 3;
                DASH_MODE1[1] = 3;
                
                float endPoint =((chart_startY + intercept) + (dpi(slope) * (chart_width/xIncrement)));
                float topBorder = chart_startY + chart_height;
                float bottomBorder = chart_startY;
                
                if (endPoint > topBorder) {
                    endPoint = topBorder;
                }
                if (endPoint < bottomBorder) {
                    endPoint = bottomBorder;
                }
                
                HPDF_Page_SetDash(page, DASH_MODE1, 1, 1);
                
                HPDF_Page_SetRGBStroke(page, 0.0, 0, 1.0);
                HPDF_Page_Circle(page, chart_startX, chart_startY + intercept, .1);
                HPDF_Page_LineTo(page, chart_startX + chart_width, endPoint);
                
                HPDF_Page_Stroke(page);
                
                
                

                
            }
            counter++;

            
        }
        
        ////////////////////////////------------------- GRAPH CATEGORY SCALES
        
        // Scale Details
        for (int i = 0; i < categoryNameArray.count; i++) 
        {
            
            // Pull Data
            NSDictionary *groupDict = [myObjects objectForKey:[categoryNameArray objectAtIndex:i]];
            NSArray *dataArray = [groupDict objectForKey:@"data"];
            
            
            if (dataArray != nil && dataArray.count > 1) 
            {
                // Create a new page for each scale
                page = HPDF_AddPage(pdf);
                HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
                
                
                HPDF_Page_BeginText(page);
                HPDF_Page_SetFontAndSize(page, fontEn, 20.0);
                HPDF_Page_TextRect(page, dpi(0.25), dpi(10.85), dpi(8.0), dpi(2.0), [[NSString stringWithFormat: @"%@",[categoryNameArray objectAtIndex:i]] UTF8String], HPDF_TALIGN_CENTER, nil);
                HPDF_Page_EndText(page);
                
                
                NSDictionary *myScaleDict = [NSDictionary dictionaryWithDictionary:[myDataSource getScaleDictionary:[categoryNameArray objectAtIndex:i]]];
                NSArray *scaleKeys = [myScaleDict allKeys];

                for (int a = 0; a < scaleKeys.count; a++) 
                {
                    

                    
                    // Check if empty scale and more than 1 value
                    if (![[scaleKeys objectAtIndex:a] isEqualToString:@"/"]) 
                    {
                        // Pull Data
                        NSDictionary *containerArray = [NSDictionary dictionaryWithDictionary:[myScaleDict objectForKey:[scaleKeys objectAtIndex:a]]];
                        
                        //NSArray *dateArray = [NSArray arrayWithArray:[containerArray objectForKey:@"date"]];
                        NSArray *dataArray = [NSArray arrayWithArray:[containerArray objectForKey:@"data"]];
                        NSLog(@"dataArray: %@", dataArray);
                        if (dataArray.count > 1) 
                        {
                            
                            NSLog(@"booyah");

                            // Set Bounderies
                            float chart_width = dpi(6.0);
                            float chart_height = dpi(0.75);
                            float chart_startY = dpi(9.48)-(dpi(1.00) * (a%maxLinesPerSubPage));
                            float chart_startX = dpi(2.0);
                            float xIncrement = chart_width / dataArray.count;
                            
                            
                            
                            // NSString *rawDataName = [scaleKeys objectAtIndex:a];
                            NSArray *rawDataName = [[scaleKeys objectAtIndex:a] componentsSeparatedByString:@"/"];
                            NSString *minLabel = [rawDataName objectAtIndex:0];
                            NSString *maxLabel = [rawDataName objectAtIndex:1];
                            
                            HPDF_Page_BeginText(page);
                            HPDF_Page_SetFontAndSize(page, fontEn, 14.0);
                            HPDF_Page_TextRect(page, dpi(0.25), dpi(9.80)-(dpi(1.0) * (a%maxLinesPerSubPage)), dpi(1.8), dpi(1.0), [[NSString stringWithFormat: @"%@",minLabel] UTF8String], HPDF_TALIGN_RIGHT, nil);
                            HPDF_Page_TextRect(page, dpi(0.25), dpi(9.80)-(dpi(1.0) * (a%maxLinesPerSubPage)) + 40, dpi(1.8), dpi(1.0), [[NSString stringWithFormat: @"%@",maxLabel] UTF8String], HPDF_TALIGN_RIGHT, nil);            
                            HPDF_Page_EndText(page);
                            
                            
                            // Draw Border
                            HPDF_Page_SetDash(page, NULL, 0, 0); 
                            
                            HPDF_Page_SetLineWidth(page, 1.0);
                            HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
                            HPDF_Page_Rectangle(page, chart_startX, chart_startY, chart_width, chart_height);
                            HPDF_Page_Stroke(page);
                            
                            float stepX = chart_startX;
                            
                            
                            // Draw Points/Lines
                            HPDF_Page_SetRGBStroke(page, 1.0, 0, 0);
                            for (int c=0; c < dataArray.count; c++) 
                            {
                                float value = [[dataArray objectAtIndex:c] floatValue];
                                
                                if (c == 0) 
                                {
                                    HPDF_Page_Circle(page, stepX, chart_startY + value/2, .1);
                                    
                                }
                                else 
                                {
                                    HPDF_Page_LineTo(page, stepX, chart_startY + value/2);
                                }
                                stepX += xIncrement;
                            }
                            HPDF_Page_Stroke(page);
                            
                            
                            // Draw Regression/Trend Line
                            
                            NSInteger theNumber = dataArray.count;
                            
                            float sumY = 0.0;
                            float sumX = 0.0;
                            float sumXY = 0.0;
                            float sumX2 = 0.0;
                            float sumY2 = 0.0;
                            
                            
                            stepX = chart_startX;
                            for (int c=0;c < dataArray.count;c++) 
                            {
                                float stepY = [[dataArray objectAtIndex:c] doubleValue];
                                sumX += stepX;
                                sumY += stepY;
                                sumXY += (stepX * stepY);
                                sumX2 += (stepX * stepX);
                                sumY2 += (stepY * stepY);
                                stepX += xIncrement;
                            }
                            
                            float slope = ((theNumber * sumXY) - sumX * sumY) / ((theNumber * sumX2) - (sumX * sumX))/2;
                            float intercept = ((sumY - (slope * sumX))/theNumber)/2;
                            // float correlation = fabs((theNumber * sumXY) - (sumX * sumY)) / (sqrt((theNumber * sumX2 - sumX * sumX) * (theNumber * sumY2 - (sumY * sumY))));
                            DASH_MODE1[0] = 3;
                            DASH_MODE1[1] = 3;
                            
                            HPDF_Page_SetDash(page, DASH_MODE1, 1, 1);
                            
                            HPDF_Page_SetRGBStroke(page, 0.0, 0, 1.0);

                            
                            float endPoint =((chart_startY + intercept) + (dpi(slope) * (chart_width/xIncrement)));
                            float topBorder = chart_startY + chart_height;
                            float bottomBorder = chart_startY;
                            
                            if (endPoint > topBorder) {
                                endPoint = topBorder;
                            }
                            if (endPoint < bottomBorder) {
                                endPoint = bottomBorder;
                            }
                            
                            HPDF_Page_Circle(page, chart_startX, chart_startY + intercept, .1);
                            
                            HPDF_Page_LineTo(page, chart_startX + chart_width, endPoint);

                            
                            HPDF_Page_Stroke(page);
                        
                        }                        
                    }
                }
            }
        }
    }
    
    
    ////////////////////////////------------------- NOTES
    
    
    // Create a new page Notes
    NSString *noteOn = [defaults objectForKey:@"PDF_Notes_On"];
    
    if ([noteOn isEqualToString:@"YES"]) 
    {
        page = HPDF_AddPage(pdf);
        int pageHeight = 0;
        
        
        for (int b=0; b < noteKeys.count; b++) 
        {
            if (pageHeight >= dpi(10.0)) 
            {
                // Start New Page
                page = HPDF_AddPage(pdf);
                HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
                pageHeight = 0;
            }
            
            
            NSString *noteTime = [noteKeys objectAtIndex:b];
            NSString *noteData = [notesDictionary objectForKey:noteTime];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-mm-dd HH:mm:ss ZZZ"];
            NSDate *noteDate = [dateFormat dateFromString:noteTime];
            [dateFormat setDateFormat:@"MMM d, yyyy h:mm:ss aaa"];
            noteTime = [dateFormat stringFromDate:noteDate];
            [dateFormat release];
            float textHeight = dpi(1.0);//[self getTextHeight:noteData];
            
            NSLog(@"textHeight: %f", textHeight);
            
            HPDF_Page_BeginText(page);
            HPDF_Page_SetFontAndSize(page, fontEn, 14.0);            
            HPDF_Page_TextRect(page, dpi(0.25), dpi(10.00)-(textHeight * (b%maxLinesPerNotePage)) + 20, dpi(8.0), dpi(1.0), [[NSString stringWithFormat: @"%@",noteTime] UTF8String], HPDF_TALIGN_LEFT, nil);
            HPDF_Page_SetFontAndSize(page, fontEn, 8.0);            
            HPDF_Page_TextRect(page, dpi(0.25), dpi(10.00)-(textHeight * (b%maxLinesPerNotePage)), dpi(8.0), dpi(1.0), [[NSString stringWithFormat: @"%@",noteData] UTF8String], HPDF_TALIGN_LEFT, nil);              
            HPDF_Page_EndText(page);
            pageHeight += textHeight;
        }
        
    }
    
    // Save PDF
    path = [filePath stringByReplacingOccurrencesOfString:@".csv" withString:@".pdf"];
    pathCString = [path cStringUsingEncoding:1];
    NSLog(@"Saving PDF to %@", path);
    HPDF_SaveToFile(pdf, pathCString);
    if (HPDF_HasDoc(pdf)) {
        HPDF_Free(pdf);
    }
    
    //  HPDF_ResetError(pdf)
    //HPDF_Free(pdf);
    
    if ([self delegate]) {
        [self.delegate service:self didFinishCreatingPDFFile:filePath detailNo:0];
    }
    
}

- (float)getTextHeight:(NSString *)data
{
    float textHeight = dpi(1.0);
    int textWidth = [data length];
    float lineMultiplier = textWidth/160; //80 char per line
    NSLog(@"data: %@ - %i", data, textWidth);
    
    textHeight = dpi(1.0) * lineMultiplier;
    
    return textHeight;
}

- (NSMutableDictionary *) parseNotes:(NSString *)fileContents
{
    NSMutableDictionary *notesDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    // first, separate by new line
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    // Start Parsing CSV
    for (int i=0; i < allLinedStrings.count; i++)
    {
        NSString *testString = [allLinedStrings objectAtIndex:i];
        if ([testString length] != 0) 
        {
            NSString *curLine = [allLinedStrings objectAtIndex:i];
            NSArray *curData = [curLine componentsSeparatedByString:@"||"];
            
            //  NSLog(@"curData: %@",[curData objectAtIndex:0]);
            
            if ([[curData objectAtIndex:0] isEqualToString:@"NOTES"]) 
            {
                NSString *noteDate = [curData objectAtIndex:1];
                NSString *noteText = [curData objectAtIndex:2];
                [notesDictionary setObject:noteText forKey:noteDate];
                
            }
        }
    }
    
    
    return notesDictionary;
}

@end
