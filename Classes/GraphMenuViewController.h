//
//  GraphMenuViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 5/11/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface GraphMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSManagedObjectContext *managedObjectContext;
    
    NSMutableDictionary *switchDictionary;
	NSMutableDictionary *ledgendColorsDictionary;
	NSDictionary *groupsDictionary;
    NSArray *groupsArray;
    

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableDictionary *switchDictionary;
@property (nonatomic, retain) NSMutableDictionary *ledgendColorsDictionary;
@property (nonatomic, retain) NSDictionary *groupsDictionary;
@property (nonatomic, retain) NSArray *groupsArray;



- (IBAction)cancelMenu:sender;
- (void)createSwitches;
- (void)fillGroupsDictionary;
- (void)fillColors;

- (void)deviceOrientationChanged:(NSNotification *)notification;
@end
