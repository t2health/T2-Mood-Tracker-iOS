//
//  ChartPrintViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 6/28/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "ShinobiCharts/SChartGLView+Screenshot.h"
#import "ShinobiCharts/ShinobiChart+Screenshot.h"
#import "ChartPrintDataSource.h"

@class Saved;

@interface ChartPrintViewController : UIViewController <SChartDelegate>
{
    ShinobiChart            *chart;
    ChartPrintDataSource         *datasource;    
    Saved *saved;

}
@property (nonatomic, retain) Saved *saved;

- (NSData *)setupGraph;

@end
