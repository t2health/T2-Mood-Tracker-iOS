//
//  PDFService.h
//  PDF
//
//  Created by Masashi Ono on 09/10/25.
//  Copyright (c) 2009, Masashi Ono
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hpdf.h"
#import "Saved.h"

#define dpi(inches) (inches*72.0f)

@class PDFService;


#pragma mark -
#pragma mark PDFServiceDelegate 


@protocol PDFServiceDelegate
- (void)service:(PDFService *)service
didFailedCreatingPDFFile:(NSString *)filePath
        errorNo:(HPDF_STATUS)errorNo
       detailNo:(HPDF_STATUS)detailNo;

- (void)service:(PDFService *)service
didFinishCreatingPDFFile:(NSString *)filePath
       detailNo:(HPDF_STATUS)detailNo;

@end


#pragma mark -
#pragma mark PDFService


@interface PDFService : NSObject {
    id <PDFServiceDelegate> delegate;
}

+ (PDFService *)instance;
- (void)createPDFFile;
- (NSMutableDictionary *) parseNotes:(NSString *)fileContents;

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
