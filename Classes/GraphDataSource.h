//
//  GraphDataSource.h
//  VAS002
//
//  Created by Melvin Manzano on 5/2/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>
#import <CoreData/CoreData.h>
#import "VAS002AppDelegate.h"
#import "Result.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Group.h"
#import "ViewNotesViewController.h"
#import "Error.h"
#import "Note.h"
#import "GroupResult.h"
#import "DateMath.h"

@interface GraphDataSource : NSObject <SChartDatasource>
{
    NSCalendar *cal; //Calendar used for constructing date objects.
    BOOL stepLineMode;
    BOOL gradientMode;
    BOOL symbolMode;
    BOOL seriesMode;

    NSManagedObjectContext *managedObjectContext;
    NSInteger chartMonth;
    NSInteger chartYear;
    BOOL dateSet;
    NSMutableDictionary *switchDictionary;
    NSMutableDictionary *ledgendColorsDictionary;
    NSDictionary *groupsDictionary;
    NSArray *groupsArray;
    NSCalendar *gregorian;
    
    NSArray *notesForMonth;
    NSDictionary *valuesArraysForMonth;
    
    NSDictionary *dataDict;
    NSMutableDictionary *dataDictCopy;
    NSMutableDictionary *tempDict;
    NSMutableDictionary *symbolsDictionary;
    NSDictionary *scalesUpdateDict;
    NSMutableArray *hideSeriesArray;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSCalendar* gregorian;
@property (nonatomic, retain) NSArray *notesForMonth;
@property (nonatomic, retain) NSDictionary *valuesArraysForMonth;
@property (nonatomic, assign) NSInteger chartMonth;
@property (nonatomic, assign) NSInteger chartYear;
@property (nonatomic, assign) BOOL dateSet;
@property (nonatomic, retain) NSDictionary *groupsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) NSMutableDictionary *tempDict;
@property (nonatomic, retain) NSMutableArray *seriesData, *seriesDates;
@property (nonatomic, retain) NSDictionary *dataDict;
@property (nonatomic, retain) NSMutableDictionary *dataDictCopy;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSDictionary *scalesUpdateDict;
@property (nonatomic, retain) NSMutableArray *hideSeriesArray;


- (int)getSeriesDataCount:(int) seriesIndex;
- (void)toggleSeriesType;
- (NSDictionary *)getChartDictionary;
- (void)createSwitches;
- (void)fillGroupsDictionary;
- (void)fillColors;
- (void)fillSymbols;
- (void)printData;
- (void)toggleSeries;
- (void)toggleGradient;
- (void)toggleSymbol;


@end
