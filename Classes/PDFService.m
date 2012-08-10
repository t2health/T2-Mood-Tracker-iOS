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
    
    PDFDataSource *myDataSource = [[PDFDataSource alloc] init];
    NSDictionary *myObjects = [NSDictionary dictionaryWithDictionary:[myDataSource getChartDictionary]];
    NSLog(@"myObjects: %@", myObjects);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   // NSLog(@"groupScaleDictionaryService: %@", [defaults objectForKey:@"PDF_GroupScaleDictionary"]);
    
    NSDictionary *groupScaleDictionary = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"PDF_GroupScaleDictionary"]];
    
    NSString *reportName = @"";
    NSString *reportTitle = @"";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, [defaults objectForKey:@"savedName"]];
   // NSLog(@"filePath is %@", filePath);
    
//    reportName = saved.filename;
//    reportTitle = saved.title;
    
    
    NSString *path = nil;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy h:mm:ss a"];
    const char *pathCString = NULL;
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath 
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *rawDataArray = [fileContents componentsSeparatedByString:@"NOTES,-,-,-"];
    
    // Get Notes
    NSMutableDictionary *notesDictionary = [NSMutableDictionary dictionaryWithDictionary:[self parseNotes:[rawDataArray objectAtIndex:1]]];
    NSArray *noteKeys = [notesDictionary allKeys];
    
    // Today Date
    // get the current date
    NSDate *date = [NSDate date];
    
    // format it
    NSDateFormatter *dateFormatNow = [[NSDateFormatter alloc]init];
    [dateFormatNow setDateFormat:@"HH:mm:ss zzz"];
    
    // convert it to a string
    NSString *dateString = [dateFormatNow stringFromDate:date];
    
    // free up memory
    [dateFormatNow release];
    
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    
    
    

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
    
    
    path = [filePath stringByAppendingString:@".png"];
    NSLog(@"Path for chart image is %@", path);
    pathCString = [path cStringUsingEncoding:NSASCIIStringEncoding];
    
    // Header with date
    /*
    HPDF_Image image = HPDF_LoadPngImageFromFile(pdf, pathCString);
    NSDate *currentTimestamp;
        
    page = HPDF_AddPage(pdf);
    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
    HPDF_Page_BeginText(page);
    HPDF_Page_SetFontAndSize(page, fontEn, 27.0);
    HPDF_Page_TextRect(page, dpi(0.25), dpi(8.0), dpi(8.0), dpi(2.0), [[NSString stringWithFormat: @"T2 Mood Tracker Report\nGenerated On: %@",[dateFormat stringFromDate: [NSDate date]]] UTF8String], HPDF_TALIGN_CENTER, nil);
    HPDF_Page_EndText(page);
    HPDF_Page_SetLineWidth(page, 1.0);
    HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
    HPDF_Page_Rectangle(page, dpi(0.25), dpi(0.25), dpi(8.0), dpi(8.0));
    HPDF_Page_Stroke(page);
*/
    
    /*
    NSDate *currentDate = [[NSDate alloc] init];
    NSString *currentCategory = @"";
    int lineNumber = 0;
    CGFloat linePos = 0.0f;
    NSArray *grpArray = [groupScaleDictionary allKeys];
    */
    
    // Summary Page
    const int maxLinesPerPage = 3;

    NSArray *categoryNameArray = [groupScaleDictionary allKeys];
    
    page = HPDF_AddPage(pdf);
    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
    
    for (int i = 0; i < categoryNameArray.count; i++) 
    {
        if (i == 3) 
        {
            pageNumber++;
            
            // End Page after 3rd Category
            HPDF_Page_BeginText(page);
            HPDF_Page_SetFontAndSize(page, fontEn, 11.0);
            HPDF_Page_TextRect(page, dpi(1.0), dpi(0.25), dpi(7.5), dpi(0.5), [[NSString stringWithFormat:@"Page %d", pageNumber] UTF8String], HPDF_TALIGN_CENTER, nil);
            HPDF_Page_EndText(page);
            // Start New Page
            page = HPDF_AddPage(pdf);
            HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
        }
        
        HPDF_Page_BeginText(page);
        HPDF_Page_SetFontAndSize(page, fontEn, 27.0);
        HPDF_Page_TextRect(page, dpi(0.25), dpi(10.25)-(dpi(3.0) * (i%maxLinesPerPage)), dpi(8.0), dpi(1.0), [[NSString stringWithFormat: @"Category: %@",[categoryNameArray objectAtIndex:i]] UTF8String], HPDF_TALIGN_LEFT, nil);
        HPDF_Page_EndText(page);
        
       ////////////////////////////------------------- GRAPH SUMMARY
        // Pull Data
        NSDictionary *groupDict = [myObjects objectForKey:[categoryNameArray objectAtIndex:i]];
        NSArray *dateArray = [groupDict objectForKey:@"date"];
        NSArray *dataArray = [groupDict objectForKey:@"data"];
        
        // Set Bounderies
        float chart_width = dpi(8.0);
        float chart_height = dpi(2.0);
        float chart_startY = dpi(7.75)-(dpi(3.0) * (i%maxLinesPerPage));
        float chart_startX = dpi(0.25);
        float chart_endX = chart_startX + chart_width;
        float chart_endY = chart_startY + chart_height;
        float xIncrement = chart_width / dataArray.count;
        float yIncrement = chart_height/100;
        
        
        // Draw Border
        HPDF_Page_SetLineWidth(page, 1.0);
        HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
        HPDF_Page_Rectangle(page, chart_startX, chart_startY, chart_width, chart_height);
        HPDF_Page_Stroke(page);
       // NSLog(@"width: %f, height: %f, x: %f-%f, y: %f-%f", chart_width, chart_height, chart_startX, chart_endX, chart_startY, chart_endY);
        
        
        // Draw Points/Lines
        int stepX = chart_startX;
        HPDF_Page_SetRGBStroke(page, 1.0, 0, 0);
        for (int a=0; a < dataArray.count; a++) 
        {
            int value = [[dataArray objectAtIndex:a] intValue];
            
            if (a == 0) 
            {
                HPDF_Page_Circle(page, stepX, chart_startY + value, .1);

            }
            else 
            {
                HPDF_Page_LineTo(page, stepX, chart_startY + value);
            }
            stepX += xIncrement;
        }
        HPDF_Page_Stroke(page);
        

        // Draw Regression/Trend Line
        stepX = chart_startX;
        
        HPDF_Page_SetRGBStroke(page, 0.0, 0, 1.0);
        for (int a=0; a < dataArray.count; a++) 
        {
            if (a == 0) 
            {
                HPDF_Page_Circle(page, stepX, chart_startY + 50, .1);
                
            }
            else 
            {
                HPDF_Page_LineTo(page, stepX, chart_startY + 50);
            }
            stepX += xIncrement;
        }
        HPDF_Page_Stroke(page);
    }
    

    
    ////////////////////////////------------------- GRAPH CATEGORY SCALES
    
    int indentCounter = 0;
    int scaleCounter = 0;
    const int rows = 10;
    
    // Scale Details
    
    
    
    
    
    
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

- (NSMutableDictionary *) parseNotes:(NSString *)fileContents
{
    NSMutableDictionary *notesDictionary = [[NSMutableDictionary alloc] init];
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
            NSArray *curData = [curLine componentsSeparatedByString:@","];
            
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
