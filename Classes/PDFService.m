//
//  PDFService.m
//  PDF
//
//  Created by Masashi Ono on 09/10/25.
//  Copyright (c) 2009, Masashi Ono
//  All rights reserved.
//

#import "PDFService.h"

#import "Group.h"
#import "Result.h"
#import "Note.h"
#import "Scale.h"


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

@synthesize delegate;

- (id) init
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
   self = [super init];
    if (self != nil) {
        //init code
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    [super dealloc];
}

+ (PDFService *)instance
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    if (!_instance) {
        _instance = [[PDFService alloc] init];
    }
    return _instance;
}


- (void)createPDFFile
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    // Creates a test PDF file to the specified path.
    // TODO: use UIImage to create non-optimized PNG rather than build target setting
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *reportName = @"";
    NSString *reportTitle = @"";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, [defaults objectForKey:@"savedName"]];
    NSLog(@"filePath is %@", filePath);
    
//    reportName = saved.filename;
//    reportTitle = saved.title;
    
    
    NSString *path = nil;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy h:mm:ss a"];
    const char *pathCString = NULL;
    const int rows = 200;
    const int maxLinesPerPage = 67;
    
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
    
    HPDF_Image image = HPDF_LoadPngImageFromFile(pdf, pathCString);
    NSDate *currentTimestamp;
        
    page = HPDF_AddPage(pdf);
    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_LANDSCAPE);
    HPDF_Page_BeginText(page);
    HPDF_Page_SetFontAndSize(page, fontEn, 27.0);
    HPDF_Page_TextRect(page, dpi(0.25), dpi(8.0), dpi(10.5), dpi(2.0), [[NSString stringWithFormat: @"T2 Mood Tracker Report\nGenerated On: %@",[dateFormat stringFromDate: [NSDate date]]] UTF8String], HPDF_TALIGN_CENTER, nil);
    HPDF_Page_EndText(page);
    HPDF_Page_SetLineWidth(page, 1.0);
    HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
    HPDF_Page_Rectangle(page, dpi(0.25), dpi(0.25), dpi(10.5), dpi(8.0));
    HPDF_Page_Stroke(page);
    HPDF_Page_DrawImage(page, image, dpi(0.5), dpi(0.5), dpi(10.0), dpi(7.5));
    page = HPDF_AddPage(pdf);
    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_LANDSCAPE);
    
    NSDate *currentDate = [[NSDate alloc] init];
    NSString *currentCategory = @"";
    int lineNumber = 0;
    CGFloat linePos = 0.0f;
    /*
    for (Result *aResult in data) {
        if (lineNumber % maxLinesPerPage == 0 || (![currentDate isEqual:aResult.timestamp] && lineNumber > maxLinesPerPage - 2) ) {
            lineNumber = 0;
            pageNumber++;
            page = HPDF_AddPage(pdf);
            HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
            HPDF_Page_BeginText(page);
            HPDF_Page_SetFontAndSize(page, fontEn, 11.0);
            HPDF_Page_TextRect(page, dpi(1.0), dpi(0.25), dpi(7.5), dpi(0.5), [[NSString stringWithFormat:@"Page %d", pageNumber] UTF8String], HPDF_TALIGN_CENTER, nil);
            HPDF_Page_EndText(page);
            HPDF_Page_SetLineWidth(page, 1.0);
            HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
            HPDF_Page_Rectangle(page, dpi(0.25), dpi(0.25), dpi(8.0), dpi(10.5));
            HPDF_Page_Stroke(page);
        }
        HPDF_Page_BeginText(page);
        HPDF_Page_SetFontAndSize(page, fontEn, 12.0);
        if (![currentDate isEqual:aResult.timestamp]) {
            linePos = 10.5f - (0.15f * (CGFloat)lineNumber);
            HPDF_Page_TextRect(page, dpi(0.50), dpi(linePos), dpi(7.5), dpi(0.5), [[NSString stringWithFormat:@"%@",[dateFormat stringFromDate: aResult.timestamp]] UTF8String], HPDF_TALIGN_LEFT, nil);
            currentDate = aResult.timestamp;
            lineNumber++;
        }
        if (![currentCategory isEqual:aResult.group.title]) {
            linePos = 10.5f - (0.15f * (CGFloat)lineNumber);
            HPDF_Page_EndText(page);
            HPDF_Page_SetLineWidth(page, 3.0);
//            HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
            HPDF_Page_SetRGBFill(page, 1.0, 0.0, 0.0);
            HPDF_Page_Rectangle(page, dpi(0.5), dpi(linePos)-dpi(0.175), dpi(0.25), dpi(0.10));
//            HPDF_Page_Stroke(page);
            HPDF_Page_Fill(page);
            HPDF_Page_SetRGBFill(page, 0.0, 0.0, 0.0);
            HPDF_Page_BeginText(page);
            HPDF_Page_TextRect(page, dpi(.750), dpi(linePos), dpi(7.0), dpi(0.5), [aResult.group.title UTF8String], HPDF_TALIGN_LEFT, nil);
            currentCategory = aResult.group.title;
            lineNumber++;
        }
        linePos = 10.5f - (0.15f * (CGFloat)lineNumber);
        HPDF_Page_TextRect(page, dpi(1.0), dpi(linePos), dpi(6.5), dpi(0.5), [[NSString stringWithFormat:@"%@/%@: %@", aResult.scale.minLabel, aResult.scale.maxLabel, aResult.value] UTF8String], HPDF_TALIGN_LEFT, nil);
        HPDF_Page_EndText(page);
        lineNumber++;
    }
   */
/*
    for (int i = 0; i < rows; i++) {
        if(i % maxLinesPerPage == 0)
        {
            if (pageNumber != 0) {
                HPDF_Page_EndText(page);
            }
            pageNumber++;
//            lblInfo.text = [NSString stringWithFormat:@"Creating Page %d", pageNumber];
            page = HPDF_AddPage(pdf);
            HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_LETTER, HPDF_PAGE_PORTRAIT);
            HPDF_Page_BeginText(page);
            HPDF_Page_SetFontAndSize(page, fontEn, 11.0);
            HPDF_Page_TextRect(page, dpi(1.0), dpi(0.25), dpi(7.5), dpi(0.5), [[NSString stringWithFormat:@"Page %d", pageNumber] UTF8String], HPDF_TALIGN_CENTER, nil);
            HPDF_Page_EndText(page);
            HPDF_Page_SetLineWidth(page, 1.0);
            HPDF_Page_SetRGBStroke(page, 0.0, 0, 0);
            HPDF_Page_Rectangle(page, dpi(0.25), dpi(0.25), dpi(8.0), dpi(10.5));
            HPDF_Page_Stroke(page);
            HPDF_Page_DrawImage(page, image, dpi(0.5), dpi(5.5), dpi(7.5), dpi(5.0));
            HPDF_Page_BeginText(page);
            HPDF_Page_SetFontAndSize(page, fontEn, 10.0);
        }
        NSString *lineText = [NSString stringWithFormat:@"Data Line %d", i];
        const char *line = [lineText UTF8String];
        HPDF_Page_TextOut(page, dpi(1.0), dpi(5.25)-(dpi(0.125) * (i%maxLinesPerPage)), line);
        
    }
    HPDF_Page_EndText(page);
    
    // comment out this line intentionally causes an error here to test error handling
    //    path = [[NSBundle mainBundle] pathForResource:@"no_such_file_hogehoge"
    //                                           ofType:@"png"];
*/  
    
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
