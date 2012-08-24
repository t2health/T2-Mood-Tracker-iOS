//
//  PDFDataSource.h
//  VAS002
//
//  Created by Melvin Manzano on 8/10/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Saved;
@interface PDFDataSource : NSObject
{
    Saved *saved;
    NSDictionary *dataDict;
    NSArray *groupsArray;
}
@property (nonatomic, retain) Saved *saved;
@property (nonatomic, retain) NSDictionary *dataDict;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) NSMutableArray *seriesData, *seriesDates;

- (NSDictionary *)getChartDictionary;
- (NSDictionary *)getScaleDictionary:(NSString *)groupName;

@end

