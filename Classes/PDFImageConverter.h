//
//  PDFImageConverter.h
//  VAS002
//
//  Created by Melvin Manzano on 6/27/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PDFImageConverter : NSObject {
    
}

+ (NSData *) convertImageToPDF: (UIImage *) image;
+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution;
+ (NSData *) convertImageToPDF: (UIImage *) image withHorizontalResolution: (double) horzRes verticalResolution: (double) vertRes;
+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution maxBoundsRect: (CGRect) boundsRect pageSize: (CGSize) pageSize;

@end
