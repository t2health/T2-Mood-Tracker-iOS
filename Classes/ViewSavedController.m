//
//  ViewSavedController.m
//  VAS002
//
//  Created by Melvin Manzano on 3/28/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "ViewSavedController.h"
#import "Saved.h"
#import "VAS002AppDelegate.h"
#import "Error.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "PDFImageConverter.h"
#import "FlurryUtility.h"
#import "MailData.h"
#import "Constants.h"
#import <QuickLook/QuickLook.h>
#import "ChartPrintViewController.h"


#define kDefaultPageHeight 792
#define kDefaultPageWidth  612
#define kMargin 50


@implementation ViewSavedController

@synthesize saved, activityInd, fileAction;
@synthesize printContentWebView, pdfPath, finalPath, fileName, fileType, groupsScalesDictionary;

int imageName = 0;
double webViewHeight = 0.0;
static bool isPDF = NO;
int rowCount;

- (void)didReceiveMemoryWarning
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"low on memory!!");
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    [super viewDidLoad];

    // [self.view bringSubviewToFront:loadView];
    // Do any additional setup after loading the view from its nib.
    activityInd.hidden = NO;
    NSString *viewTitle = @"";
    NSString *tempTitle = @"";
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.saved) 
    {
        [defaults setObject:self.saved.filename forKey:@"savedName"];
        tempTitle = self.saved.title;
    }
    else 
    {
        [defaults setObject:self.finalPath forKey:@"savedName"];
        tempTitle = self.fileName;
    }
    
    NSArray *components = [tempTitle componentsSeparatedByString:@"("];
    NSString *afterOpenBracket = [components objectAtIndex:1];
    components = [afterOpenBracket componentsSeparatedByString:@")"];
    NSString *numberString = [components objectAtIndex:0];    
    if (self.saved) 
    {
        
        viewTitle = numberString;
        
    }
    else 
    {
        
        viewTitle = self.fileType;
        
    }
    self.title = viewTitle;
    //   backgroundQueue = dispatch_queue_create("org.t2health.moodtracker.bgqueue", NULL);        
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [printContentWebView setDelegate:self];
	pdfPath = [[NSString alloc] initWithString:@"file://"];
    // NavBar Button
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareClick)];
    self.navigationItem.rightBarButtonItem = actionButton;
    [actionButton release];
    
    
    //[defaults synchronize];
    
    if ([viewTitle isEqualToString:@"PDF"]) 
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:groupsScalesDictionary forKey:@"PDF_GroupScaleDictionary"];    
        
        isPDF = YES;
        // NSLog(@"has groupsScalesDictionary: %@", groupsScalesDictionary);
        
        if ([fileAction isEqualToString:@"create"]) 
        {
            //create
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(createPDFDocument) userInfo:nil repeats:NO];
        }
        else 
        {
            //view
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(viewPDF) userInfo:nil repeats:NO];

        }
        
    }   
    else 
    {
        isPDF = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(createWebViewWithHTML) userInfo:nil repeats:NO];
    }
    
}



- (void)shareClick
{
    [self emailResults];
}


- (NSMutableDictionary *) parseNotes:(NSString *)fileContents
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
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

- (void) createPDFDocument 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    PDFService *service = [PDFService instance];
    service.delegate = self;
    [service createPDFFile];   
    activityInd.hidden = YES;
    
}

- (void) createWebViewWithHTML
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *reportName = @"";
    NSString *reportTitle = @"";
    
    if (self.saved) 
    {
        reportName = self.saved.filename;
        reportTitle = self.saved.title;
    }
    else 
    {
        reportName = self.fileName;
        reportTitle = @"need Title";
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = @"";

    if (self.saved) 
    {
        filePath = [NSString stringWithFormat:@"%@%@",documentsDir, saved.filename];

    }
    else 
    {
        filePath = [NSString stringWithFormat:@"%@%@",documentsDir, [defaults objectForKey:@"savedName"]];

    }
    
    NSURL *baseURL = [NSURL fileURLWithPath:documentsDir];
    
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
    
    
    //create the string
    NSMutableString *html = [NSMutableString stringWithString: @"<html><head><title></title>"];
    [html appendString:@"<style type=\"text/css\">"];
    [html appendString:@"td.daterange { font-family:\"Arial\"; color: black; background-color: white }"];
    [html appendString:@"td.date { font-family:\"Arial\"; color: black; background-color: white; font-size:12px; font-style:italic}"];
    [html appendString:@"td.scale { font-family:\"Arial\"; color: black; background-color: white }"];
    [html appendString:@"td.category { font-family:\"Arial\"; color: black; background-color: white }"];
    [html appendString:@"</style>"];
    [html appendString:@"</head><body style=\"background:transparant;\" topmargin='0' leftmargin='0' rightmargin='0'>"];
    NSString *prevDate = @"";
    NSString *prevCat = @"";
    NSString *prevTime = @"";
    //continue building the string
    [html appendString:@"<table cellpadding='3' cellspacing='0' border='0' width='100%'>"];
    [html appendString:[NSString stringWithFormat:@"<tr><td colspan='2' align='center' class='daterange'>T2 MoodTracker Report</td></tr>"]];
    
    [html appendString:[NSString stringWithFormat:@"<tr><td colspan='2' align='center' class='daterange'>Date Range: %@</td></tr>", reportTitle ]];
    [html appendString:[NSString stringWithFormat:@"<tr><td colspan='2' align='center' class='date'>Generated on: %@</td></tr>", dateString ]];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    
    if (isPDF) 
    {
        NSString *pngName = [NSString stringWithFormat:@"%@.png", reportName];
        pngName = [pngName stringByReplacingOccurrencesOfString:@"/" withString:@""];  
        [html appendString:[NSString stringWithFormat:@"<tr><td colspan='2' height='10'>&nbsp;<center><img src='%@'></center></td></tr>",pngName, pngName]];
    }   
    
    
    
    NSArray* allLinedStrings = [[rawDataArray objectAtIndex:0] componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    
    // Start Parsing CSV
    for (int i=0; i < allLinedStrings.count; i++)
    {
        NSString *testString = [allLinedStrings objectAtIndex:i];
        if ([testString length] != 0) 
        {
            NSString *curLine = [allLinedStrings objectAtIndex:i];
            NSArray *curData = [curLine componentsSeparatedByString:@","];
            NSString *testDate = [curData objectAtIndex:0];
            
            
            [dateFormat setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss' 'Z"];
            NSDate *date = [dateFormat dateFromString:testDate];
            [dateFormat setDateStyle:NSDateFormatterLongStyle];
            NSString *dateString = [dateFormat stringFromDate:date];
            [dateFormat setDateFormat:@"HH:mm:ss"];
            NSString *timeString = [dateFormat stringFromDate:date];
            
            if ([prevTime isEqualToString:@""]) 
            {
                //For very first record
                prevTime = timeString;
            }
            
            if (![prevDate isEqualToString:dateString]  ) 
            {
                // Notes
                int b = 0;
                for (NSString *timeStr in noteKeys) 
                {
                    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
                    [dateFormat setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss' 'Z"];
                    NSDate *date = [dateFormat dateFromString:timeStr];
                    [dateFormat setDateStyle:NSDateFormatterLongStyle];
                    NSString *dateString2 = [dateFormat stringFromDate:date];
                    
                    if ([dateString2 isEqualToString:dateString]) 
                    {
                        if (b==0) 
                        {
                            [html appendString:[NSString stringWithFormat:@"<tr><td colspan='2' class='date'>--Notes--</td></tr>"]];
                            b++;
                        }
                        NSString *theNote = [notesDictionary objectForKey:timeStr];
                        
                        [html appendString:[NSString stringWithFormat:@"<tr><td class='scale' colspan='2'>%@</td></tr>", theNote]];
                    }
                }
                
                // the color
                NSData *data = [tColorDict objectForKey:[curData objectAtIndex:1]];
                UIColor *uicolor = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSString *RGBColorString = [self htmlFromUIColor:uicolor];
                
                
                // Print Date and Category Name
                [html appendString:[NSString stringWithFormat:@"<tr><td class='date'>%@</td><td></td></tr>", dateString]];
                [html appendString:[NSString stringWithFormat:@"<tr><td class='category'><b><font color='%@'>%@</font></b></td><td class='date'>%@</td></tr>", RGBColorString, [curData objectAtIndex:1], timeString]];
                [html appendString:[NSString stringWithFormat:@"<tr><td></td><td class='scale'>%@ - %@</td></tr>", [curData objectAtIndex:2], [curData objectAtIndex:3]]];                
                prevDate = dateString;
                prevCat = [curData objectAtIndex:1];
                prevTime = timeString;
            }
            else
            {
                //  NSLog(@"prevTime: %@", prevTime);
                if (![prevTime isEqualToString:timeString]) 
                {
                    if (![prevCat isEqualToString:[curData objectAtIndex:1]]) 
                    {
                        // Print Time; Multiple entries per day 
                        [html appendString:[NSString stringWithFormat:@"<tr><td class='category'><b>%@</b></td><td class='date'>%@</td></tr>", [curData objectAtIndex:1], timeString]];
                        [html appendString:[NSString stringWithFormat:@"<tr><td></td><td class='scale'>%@ - %@</td></tr>", [curData objectAtIndex:2], [curData objectAtIndex:3]]];
                        prevCat = [curData objectAtIndex:1];
                        
                        
                    }
                    else 
                    {
                        [html appendString:[NSString stringWithFormat:@"<tr><td></td><td class='date'>%@</td></tr>", timeString]];
                        [html appendString:[NSString stringWithFormat:@"<tr><td></td><td class='scale'>%@ - %@</td></tr>", [curData objectAtIndex:2], [curData objectAtIndex:3]]];
                        
                    }
                    prevTime = timeString;
                    
                    
                }
                else 
                {
                    // Print Scales and Values
                    [html appendString:[NSString stringWithFormat:@"<tr><td></td><td class='scale'>%@ - %@</td></tr>", [curData objectAtIndex:2], [curData objectAtIndex:3]]];
                    
                }
                
                
            }
        }   
    }
    
    
    
    
    
    [html appendString:@"</table>"];
    [html appendString:@"</body></html>"];
    
    
    //  NSString *finalPath2 = [NSString stringWithFormat:@"%@/htmloutput.html",documentsDir];
    //  [html writeToFile:finalPath2 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    //  NSLog(@"html: %@", html);
    //make the background transparent
    [printContentWebView setBackgroundColor:[UIColor clearColor]];
    
    //pass the string to the webview
    [printContentWebView loadHTMLString:[html description] baseURL:baseURL];
    activityInd.hidden = YES;
    
    // [self.view sendSubviewToBack:loadView];
    
    
}


- (NSString *) htmlFromUIColor:(UIColor *)_color {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    if (CGColorGetNumberOfComponents(_color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(_color.CGColor);
        _color = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(_color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(_color.CGColor))[0]*255.0), (int)((CGColorGetComponents(_color.CGColor))[1]*255.0), (int)((CGColorGetComponents(_color.CGColor))[2]*255.0)];
}



/****************************************************************************/
- (void)drawPageNumber:(NSInteger)pageNum
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	NSString* pageString = [NSString stringWithFormat:@"Page %d", pageNum];
	UIFont* theFont = [UIFont systemFontOfSize:12];
	CGSize maxSize = CGSizeMake(612, 72);
	
	CGSize pageStringSize = [pageString sizeWithFont:theFont
								   constrainedToSize:maxSize
                                       lineBreakMode:UILineBreakModeClip];
	CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
								   720.0 + ((72.0 - pageStringSize.height) / 2.0) ,
								   pageStringSize.width,
								   pageStringSize.height);
	
	[pageString drawInRect:stringRect withFont:theFont];
}

/****************************************************************************/

#pragma mark Show filter view for Email Results
- (void)emailResults
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    activityInd.hidden = YES;
    
    // Fetch filtered data
    //   NSLog(@"Fetching data...");
    
    // Open mail view
    MailData *data = [[MailData alloc] init];
    data.mailRecipients = nil;
    NSString *subjectString = @"My T2 Mood Tracker Results";
    data.mailSubject = subjectString;
    NSString *filteredResults = @"";
    NSString *bodyString = @"My T2 Mood Tracker Results<p>";
    
    data.mailBody = [NSString stringWithFormat:@"%@%@", bodyString, filteredResults];
    
    [self sendMail:data];
    [data release];
    
    
}


#pragma mark Mail Delegate Methods

-(void)sendMail:(MailData *)data {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) {
			[self displayComposerSheetWithMailData:data];
		}
		else {
			[self launchMailAppOnDeviceWithMailData:data];
		}		
	}
	else {
		[self launchMailAppOnDeviceWithMailData:data];
	}
    
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
	[self dismissModalViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetWithMailData:(MailData *)data
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (data.mailSubject != nil) {
		[picker setSubject:data.mailSubject];
	}
	
	// Set up recipients
	if (data.mailRecipients != nil) {
		[picker setToRecipients:data.mailRecipients];
	}
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *myPath = @"";
    
    
    if (self.saved) 
    {
        myPath = [NSString stringWithFormat:@"%@",saved.filename];
       // NSLog(@"smyPath: %@",saved.filename);

        
    }
    else 
    {
        myPath = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"savedName"]];
       // NSLog(@"myPath: %@", [defaults objectForKey:@"savedName"]);

    }
    

    
    if ([self.title isEqualToString:@"PDF"]) 
    {
        myPath = [myPath stringByReplacingOccurrencesOfString:@".csv" withString:@".pdf"];
    }
    NSString *pdfFileName = [NSString stringWithFormat:@"%@%@",documentsDir, myPath];
    [picker addAttachmentData:[NSData dataWithContentsOfFile:pdfFileName]
                         mimeType:@"application/pdf" fileName:myPath];

    
    
	if (data.mailBody != nil) {
		[picker setMessageBody:data.mailBody isHTML:YES];
	}
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDeviceWithMailData:(MailData *)data {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	NSString *body = @"&body=";
	if (data.mailBody != nil) {
		body = [NSString stringWithFormat:@"%@%@",body,data.mailBody];
	}
	
	//TODO: Test on 3.1.2 device
	NSString *recipients = @"";
	if (data.mailRecipients != nil) {
		for (NSString *recipient in data.mailRecipients) {
			if (![recipients isEqual:@""]) {
				recipients = [NSString stringWithFormat:@"%@,%@",recipients,recipient];
			}
			else {
				recipients = [NSString stringWithFormat:@"%@%@",recipients,recipient];	  
			}
		}
	}
	
	recipients = [NSString stringWithFormat:@"mailto:%@",recipients];
	
	NSString *subject = @"&subject=";
	if (data.mailSubject != nil) {
		data.mailSubject = [NSString stringWithFormat:@"%@%@",subject,data.mailSubject];
	}
	
	NSString *email = [NSString stringWithFormat:@"%@%@%@", recipients, subject, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}



#pragma mark PDF
- (void)viewPDF
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, saved.filename];

    
    // Show PDF in WebView
    NSString *path = [filePath stringByReplacingOccurrencesOfString:@".csv" withString:@".pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [printContentWebView loadRequest:request];
    
    activityInd.hidden = YES;

}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // [self setPrintContentWebView:nil];
	[self setPdfPath:nil];
    
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    // Return YES for supported orientations
    return YES;
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	UIDevice *device = [UIDevice currentDevice];
	if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) 
    {
        //[webView reload];
        // [self createWebViewWithHTML];
        
	}
	else if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight)
    {
        
        
	}
    
}

#pragma mark -
#pragma mark PDFService delegate method


- (void)service:(PDFService *)service
didFailedCreatingPDFFile:(NSString *)filePath
        errorNo:(HPDF_STATUS)errorNo
       detailNo:(HPDF_STATUS)detailNo
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    NSString *message = [NSString stringWithFormat:@"Couldn't create a PDF file at %@\n errorNo:0x%04x detalNo:0x%04x",
                         filePath,
                         errorNo,
                         detailNo];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"PDF creation error"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)service:(PDFService *)service 
didFinishCreatingPDFFile:(NSString *)filePath 
       detailNo:(HPDF_STATUS)detailNo
{
    //  NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    activityInd.hidden = YES;

    // Show PDF in WebView
    NSString *path = [filePath stringByReplacingOccurrencesOfString:@".csv" withString:@".pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [printContentWebView loadRequest:request];
    
    
}

@end
