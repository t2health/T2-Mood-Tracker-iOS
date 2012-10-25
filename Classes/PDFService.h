//
//  PDFService.h
//  PDF
//
//  Created by Masashi Ono on 09/10/25.
//  Copyright (c) 2009, Masashi Ono
//  All rights reserved.
//
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
#import <Foundation/Foundation.h>
#import "hpdf.h"


@class PDFService;


#pragma mark -
#pragma mark PDFServiceDelegate 


@protocol PDFServiceDelegate
- (void)service:(PDFService *)service
didFailedCreatingPDFFile:(NSString *)filePath
        errorNo:(HPDF_STATUS)errorNo
       detailNo:(HPDF_STATUS)detailNo;
@end


#pragma mark -
#pragma mark PDFService


@interface PDFService : NSObject {
    id <PDFServiceDelegate> delegate;
}

+ (PDFService *)instance;
- (void)createPDFFile:(NSString *)filePath;

@property (nonatomic, assign) id<PDFServiceDelegate> delegate;

@end


#pragma mark -
#pragma mark C functions and structures


typedef struct _PDFService_userData {
    HPDF_Doc pdf;
    PDFService *service;
    NSString *filePath;
} PDFService_userData;

void PDFService_errorHandler(HPDF_STATUS   error_no,
                             HPDF_STATUS   detail_no,
                             void         *user_data);
