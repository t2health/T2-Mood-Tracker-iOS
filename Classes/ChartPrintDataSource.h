//
//  ChartPrintDataSource.h
//  VAS002
//
//  Created by Melvin Manzano on 6/28/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>

@class Saved;

@interface ChartPrintDataSource : NSObject <SChartDatasource>
{
    Saved *saved;
    NSDictionary *dataDict;
}
@property (nonatomic, retain) Saved *saved;
@property (nonatomic, retain) NSDictionary *dataDict;
@property (nonatomic, retain) NSMutableArray *seriesData, *seriesDates;


- (int)getSeriesDataCount:(int) seriesIndex;
- (NSDictionary *)getChartDictionary;

@end
