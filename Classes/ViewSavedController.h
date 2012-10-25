//
//  ViewSavedController.h
//  VAS002
//
//  Created by Melvin Manzano on 3/28/12.
/*
 *
 * T2 Mood Tracker
 *
 * Copyright © 2009-2012 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright © 2009-2012 Contributors. All Rights Reserved.
 *
 * THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
 * REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
 * COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
 * AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
 * THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
 * INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
 * REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
 * DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
 * HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
 * RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: T2MoodTracker002
 * Government Agency Original Software Title: T2 Mood Tracker
 * User Registration Requested. Please send email
 * with your contact information to: robert.kayl2@us.army.mil
 * Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
 *
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "ShinobiCharts/SChartGLView+Screenshot.h"
#import "ShinobiCharts/ShinobiChart+Screenshot.h"
#import "ChartPrintDataSource.h"
#import <dispatch/dispatch.h>


#define kBorderInset            20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0

//Line drawing
#define kLineWidth              1.0


@class Saved;
@class MailData;

@interface ViewSavedController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, SChartDelegate>
{
    ShinobiChart            *chart;
    ChartPrintDataSource         *datasource;    
    dispatch_queue_t backgroundQueue;
    Saved *saved;
    IBOutlet UIWebView *printContentWebView;
    NSString *pdfPath;
    IBOutlet UIActivityIndicatorView *activityInd;
    NSString *finalPath;
    NSString *fileName;
    NSString *fileType;

}

@property (nonatomic, retain) Saved *saved;
@property (nonatomic, retain) UIWebView *printContentWebView;
@property (nonatomic, retain) NSString *pdfPath;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityInd;
@property (nonatomic, retain) NSString *finalPath;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileType;


- (void)sendMail:(MailData *)mailData;
- (void)displayComposerSheetWithMailData:(MailData *)data;
- (void)launchMailAppOnDeviceWithMailData:(MailData *)data;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
- (void)emailResults;
- (void) finishSetup;
- (void) getScreenShot;
- (void) createWebViewWithHTML;
- (NSMutableDictionary *) parseNotes:(NSString *)fileContents;
- (void) shareClick;
- (void) makePDF;
- (void) drawPDF:(UIImage *)reportImage;

- (void)drawPageNumber:(NSInteger)pageNum;

@end
