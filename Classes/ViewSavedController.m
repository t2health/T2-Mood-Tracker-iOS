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

@synthesize saved, activityInd;
@synthesize printContentWebView, pdfPath, finalPath, fileName, fileType;

int imageName = 0;
double webViewHeight = 0.0;
static bool emailPDF = YES;
static bool isPDF = NO;
int rowCount;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"low on memory!!");
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [self.view bringSubviewToFront:loadView];
    // Do any additional setup after loading the view from its nib.
    activityInd.hidden = NO;
    NSString *viewTitle = @"";
    NSString *tempTitle = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (saved) 
    {
        [defaults setObject:self.saved.filename forKey:@"savedName"];
        tempTitle = saved.title;
    }
    else 
    {
        [defaults setObject:finalPath forKey:@"savedName"];
         tempTitle = self.fileName;
    }
    
    NSArray *components = [tempTitle componentsSeparatedByString:@"("];
    NSString *afterOpenBracket = [components objectAtIndex:1];
    components = [afterOpenBracket componentsSeparatedByString:@")"];
    NSString *numberString = [components objectAtIndex:0];    
    NSLog(@"numberString: %@", numberString);
    if (saved) 
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
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(shareClick)];
    self.navigationItem.rightBarButtonItem = actionButton;
    [actionButton release];
    
    
    //[defaults synchronize];
    
    if ([viewTitle isEqualToString:@"PDF"]) 
    {
        isPDF = YES;

        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(getScreenShot) userInfo:nil repeats:NO];
    }   
    else 
    {
        isPDF = NO;

        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(createWebViewWithHTML) userInfo:nil repeats:NO];
    }

}

- (void) finishSetup
{
    
    NSData *imageData;
    for (int i = 0; i < 2; i++) 
    {
        UIImage *screenshot = [chart snapshot];
        imageData = UIImagePNGRepresentation(screenshot);
    }
    
    NSString *reportName = @"";
    if (saved) 
    {
        reportName = saved.filename;
    }
    else 
    {
        reportName = self.finalPath;
    }
    
    NSString *thisFileName = [NSString stringWithFormat:@"%@.png", reportName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: 
                      [NSString stringWithString: thisFileName] ];

    [imageData writeToFile:path atomically:YES];
    NSLog(@"path: %@", path);
    [self createWebViewWithHTML];
    
}


- (void)shareClick
{
    
    if (isPDF) 
    {
        
        
        // Email PDF
        emailPDF = YES;
      //  [self makePDF];

        activityInd.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(makePDF) userInfo:nil repeats:NO];
        
        
        
    } 
    else
    {
        // Email CSV
        emailPDF = NO;
        [self emailResults];
        
    }
    
    
    
    /*
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle:@"" 
                                   delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                                   destructiveButtonTitle:nil 
                                   otherButtonTitles:@"Email PDF", @"Email CSV", nil] autorelease];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];  
     */
    
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

- (void) createWebViewWithHTML
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *reportName = @"";
    NSString *reportTitle = @"";

    if (saved) 
    {
        reportName = saved.filename;
        reportTitle = saved.title;
    }
    else 
    {
        reportName = self.fileName;
        reportTitle = @"need Title";
    }
        NSLog(@"reportName: %@", reportName);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@",documentsDir, [defaults objectForKey:@"savedName"]];

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
    
    NSLog(@"theCount: %i", allLinedStrings.count);
    
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
    activityInd.hidden = YES;

// Fetch filtered data
//   NSLog(@"Fetching data...");

// Open mail view
MailData *data = [[MailData alloc] init];
data.mailRecipients = nil;
NSString *subjectString = @"T2 Mood Tracker App Results";
data.mailSubject = subjectString;
NSString *filteredResults = @"";
NSString *bodyString = @"T2 Mood Tracker App Results:<p>";

data.mailBody = [NSString stringWithFormat:@"%@%@", bodyString, filteredResults];

[self sendMail:data];
[data release];


}


#pragma mark Mail Delegate Methods

-(void)sendMail:(MailData *)data {
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

	[self dismissModalViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetWithMailData:(MailData *)data
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (data.mailSubject != nil) {
		[picker setSubject:data.mailSubject];
	}
	
	// Set up recipients
	if (data.mailRecipients != nil) {
		[picker setToRecipients:data.mailRecipients];
	}
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];

    if (emailPDF) 
    {
        NSLog(@"pdfPath: %@", pdfPath);
        
        [picker addAttachmentData:[NSData dataWithContentsOfFile:self.pdfPath]
                               mimeType:@"application/pdf" fileName:@"Results.pdf"];


    }
    else 
    {
        NSString *Path = [documentsDir stringByAppendingString:saved.filename];
        NSData *myData = [NSData dataWithContentsOfFile:Path];
        [picker addAttachmentData:myData mimeType:@"text/plain" fileName:saved.filename];

    }
    
    
    
	if (data.mailBody != nil) {
		[picker setMessageBody:data.mailBody isHTML:YES];
	}
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDeviceWithMailData:(MailData *)data {
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


#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        //    NSLog(@"Ummm.");
        
    } 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"button press: %i", buttonIndex);
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 0) 
    {
        // Email PDF
        emailPDF = YES;
        
       [self makePDF];
        activityInd.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(makePDF) userInfo:nil repeats:NO];

        
        
    } 
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
    {
        // Email CSV
        emailPDF = NO;
        [self emailResults];

    }
    
    
}

#pragma mark PDF
- (void)makePDF
{
    
    NSLog(@"webviewload");
    
    
    
	/* 
     Idea and partial code from : http://itsbrent.net/2011/06/printing-converting-uiwebview-to-pdf/
     Credit where credit's due.
	 */
	
    /*
	// Store off the original frame so we can reset it when we're done
	CGRect origframe = printContentWebView.frame;
    NSString *heightStr = [printContentWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"]; // Get the height of our webView
    int height = [heightStr intValue];
    
	// Size of the view in the pdf page
    CGFloat maxHeight	= kDefaultPageHeight - 2*kMargin;
	CGFloat maxWidth	= kDefaultPageWidth - 2*kMargin;
	int pages = ceil(height / maxHeight);
	
	[printContentWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
	
	// Normally we'd want a temp directory and a unique file name, but I want to see the final pdf from Simulator
	//NSString *path = NSTemporaryDirectory();
	//self.pdfPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.pdf", [[NSDate date] timeIntervalSince1970] ]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *path = [paths objectAtIndex:0]; 
    self.pdfPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"Results.pdf"]];
    NSLog(@"pdfPath: %@", pdfPath);
	// Set up we the pdf we're going to be generating is
	UIGraphicsBeginPDFContextToFile(self.pdfPath, CGRectZero, nil);
	int i = 0;
	for ( ; i < pages; i++) 
	{
		if (maxHeight * (i+1) > height) { // Check to see if page draws more than the height of the UIWebView
            CGRect f = [printContentWebView frame];
            f.size.height -= (((i+1) * maxHeight) - height);
            [printContentWebView setFrame: f];
        }
		// Specify the size of the pdf page
		UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
		[self drawPageNumber:(i+1)];
		// Move the context for the margins
        CGContextTranslateCTM(currentContext, kMargin, kMargin);
		// offset the webview content so we're drawing the part of the webview for the current page
        [[[printContentWebView subviews] lastObject] setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];
		// draw the layer to the pdf, ignore the "renderInContext not found" warning. 
        [printContentWebView.layer renderInContext:currentContext];
    }
	// all done with making the pdf
    UIGraphicsEndPDFContext();
	// Restore the webview and move it to the top. 
	[printContentWebView setFrame:origframe];
	[[[printContentWebView subviews] lastObject] setContentOffset:CGPointMake(0, 0) animated:NO];
    
    [self emailResults];
     */
}


- (void) drawPDF:(UIImage *)reportImage;
{
    /*
    CGSize pageSize = CGSizeMake(612, 792);
    CGRect imageBoundsRect = CGRectMake(50, 50, 512, 692);

    NSData *pdfData = [PDFImageConverter convertImageToPDF:reportImage withResolution:300 maxBoundsRect:imageBoundsRect pageSize:pageSize];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",@"ResultsPDF"]];

    [pdfData writeToFile:pdfPath atomically:YES];
    [self emailResults];
*/
}


- (void) getScreenShot
{
#pragma mark - Setup Graph
/*--------------------------- Setup Graph to print ---------------------------*/
    chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
/*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Create the chart
        chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    } else {
        //Create the chart
        chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
 */   
    // Set a different theme on the chart
    SChartMidnightTheme *midnight = [[SChartMidnightTheme alloc] init];
    [chart setTheme:midnight];
    [midnight release];
    
    
    
    //As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
    chart.autoresizingMask = ~UIViewAutoresizingNone;
    
    // Initialise the data source we will use for the chart
    // datasource = [[GraphDataSource alloc] init];
    
    // Give the chart the data source
    datasource = [[ChartPrintDataSource alloc] init];
    
    chart.datasource = datasource;
    
    SChartDateRange *xRange = [[SChartDateRange alloc] init];
    // Create a date time axis to use as the x axis.    
    //SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:xRange];
    
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] init];

    // Enable panning and zooming on the x-axis.
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    xAxis.enableMomentumPanning = YES;
    xAxis.enableMomentumZooming = YES;
    xAxis.axisPositionValue = [NSNumber numberWithInt: 0];
    xAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    
    chart.xAxis = xAxis;
    [xAxis release];
    [xRange release];
    
    //Create a number axis to use as the y axis.
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    
    //Enable panning and zooming on Y
    yAxis.enableGesturePanning = NO;
    yAxis.enableGestureZooming = NO;
    yAxis.enableMomentumPanning = NO;
    yAxis.enableMomentumZooming = NO;
    //yAxis.axisLabelsAreFixed = YES;
    // yAxis.majorTickFrequency = YES;
    yAxis.titleLabel.textColor = [UIColor grayColor];
   // yAxis.titleLabel.text = @"<<<   Low                    Hi    >>>";
    //yAxis.titleLabel.frame
    yAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    yAxis.style.majorTickStyle.showLabels = YES;
    yAxis.style.majorTickStyle.showTicks = YES;
    
    chart.yAxis = yAxis;
    [yAxis release];
    
    //Set the chart title
    chart.title = @"Results";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        chart.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:27.0f];
    } else {
        chart.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:17.0f];
    }
    chart.titleLabel.textColor = [UIColor whiteColor];
   // [self.view addSubview:chart];
    
    
    //dispatch_async(dispatch_get_main_queue(), ^(void) {
       // [self finishSetup];
   // });
    
    [self.view insertSubview:printContentWebView aboveSubview:chart];


    NSLog(@"after que");
   // dispatch_async(dispatch_get_main_queue(), ^(void) {
  //  });
    
    [self finishSetup];
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
    // Return YES for supported orientations
    return YES;
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
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


@end
