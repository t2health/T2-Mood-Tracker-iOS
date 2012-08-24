//
//  OptionsTableViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 7/9/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface OptionsTableViewController : UITableViewController <UINavigationControllerDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *dataSourceArray;
    UINavigationController *myNavController;
    NSString *whichGraph;
    UISwitch *legendSwitch;
    UISwitch *symbolSwitch;
    UISwitch *gradientSwitch;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) UINavigationController *myNavController;
@property (nonatomic, retain) UISwitch *legendSwitch;
@property (nonatomic, retain) UISwitch *symbolSwitch;
@property (nonatomic, retain) UISwitch *gradientSwitch;
@property (nonatomic, retain) NSString *whichGraph;


- (void)legendToggle;
- (void)symbolToggle;
- (void)gradientToggle;

@end
