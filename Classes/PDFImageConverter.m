//
//  PDFImageConverter.m
//  VAS002
//
//  Created by Melvin Manzano on 6/27/12.
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
#import "PDFImageConverter.h"

@implementation PDFImageConverter

+ (NSData *) convertImageToPDF: (UIImage *) image {
    return [PDFImageConverter convertImageToPDF: image withResolution: 96];
}

+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution {
    return [PDFImageConverter convertImageToPDF: image withHorizontalResolution: resolution verticalResolution: resolution];
}

+ (NSData *) convertImageToPDF: (UIImage *) image withHorizontalResolution: (double) horzRes verticalResolution: (double) vertRes {
    if ((horzRes <= 0) || (vertRes <= 0)) {
        return nil;
    }
    
    double pageWidth = image.size.width * image.scale * 72 / horzRes;
    double pageHeight = image.size.height * image.scale * 72 / vertRes;
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    // The page size matches the image, no white borders.
    CGRect mediaBox = CGRectMake(0, 0, pageWidth, pageHeight);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    
    CGContextBeginPage(pdfContext, &mediaBox);
    CGContextDrawImage(pdfContext, mediaBox, [image CGImage]);
    CGContextEndPage(pdfContext);
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);
    
    [pdfFile autorelease];
    return pdfFile;
}

+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution maxBoundsRect: (CGRect) boundsRect pageSize: (CGSize) pageSize {
    if (resolution <= 0) {
        return nil;
    }
    
    double imageWidth = image.size.width * image.scale * 72 / resolution;
    double imageHeight = image.size.height * image.scale * 72 / resolution;
    
    double sx = imageWidth / boundsRect.size.width;
    double sy = imageHeight / boundsRect.size.height;
    
    // At least one image edge is larger than maxBoundsRect
    if ((sx > 1) || (sy > 1)) {
        double maxScale = sx > sy ? sx : sy;
        imageWidth = imageWidth / maxScale;
        imageHeight = imageHeight / maxScale;
    }
    
    // Put the image in the top left corner of the bounding rectangle
    CGRect imageBox = CGRectMake(boundsRect.origin.x, boundsRect.origin.y + boundsRect.size.height - imageHeight, imageWidth, imageHeight);
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    
    CGRect mediaBox = CGRectMake(0, 0, pageSize.width, pageSize.height);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    
    CGContextBeginPage(pdfContext, &mediaBox);
    CGContextDrawImage(pdfContext, imageBox, [image CGImage]);
    CGContextEndPage(pdfContext);
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);
    
    [pdfFile autorelease];
    return pdfFile;
}

@end
