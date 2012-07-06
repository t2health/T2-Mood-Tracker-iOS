//
//  ChartPrintViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 6/28/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "ChartPrintViewController.h"

@implementation ChartPrintViewController

@synthesize saved;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"chartprint loaded");
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSData *chartScreenShot = [self setupGraph];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Setup Graph
/*--------------------------- Setup Graph to print ---------------------------*/
- (NSData *)setupGraph
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Create the chart
        chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    } else {
        //Create the chart
        chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    
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
 
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString:@"01-06-2012"];
    NSDate *date1 = [dateFormat dateFromString:@"28-06-2012"];
    
    
    SChartDateRange *xRange = [[SChartDateRange alloc] initWithDateMinimum:date andDateMaximum:date1];
    NSLog(@"dateRange:  %@ - %@", date1, date);
    // Create a date time axis to use as the x axis.    
    SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:xRange];
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
    yAxis.titleLabel.text = @"<<<   Low                    Hi    >>>";
    //yAxis.titleLabel.frame
    yAxis.style.majorGridLineStyle.showMajorGridLines = YES;
    yAxis.style.majorTickStyle.showLabels = NO;
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
    
    
    [self.view addSubview:chart];

    // If you have a trial version, you need to enter your licence key here:
    //    chart.licenseKey = @"";
    
    
    // Image
    UIImage *screenshot = [chart snapshot];
    NSData *imageData = UIImagePNGRepresentation(screenshot);
    //[picker addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot"]; 
    
    
    [chart removeFromSuperview];

    
    return imageData;
        
}



@end
