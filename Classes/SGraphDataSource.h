//
//  GraphDataSource.h
//  VAS002
//
//  Created by Melvin Manzano on 5/2/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
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

@interface SGraphDataSource : NSObject <SChartDatasource>
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
    NSDictionary *scalesDictionary;
	NSArray *scalesArray;
    NSString *groupName;
    NSMutableDictionary *symbolsDictionary;
    NSDictionary *scalesUpdateDict;

    
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
@property (nonatomic, retain) NSDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSDictionary *scalesUpdateDict;


- (int)getSeriesDataCount:(int) seriesIndex;
- (void)toggleSeriesType;
- (NSDictionary *)getChartDictionary;
- (void)createSwitches;
- (void)fillGroupsDictionary;
- (void)fillScalesDictionary;
- (void)fillColors;
- (void)fillSymbols;
- (void)printData;

- (void)toggleSeries;
- (void)toggleGradient;
- (void)toggleSymbol;

@end
