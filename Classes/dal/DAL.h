//
//  dalVAS.h
//  VAS002
//
//  Created by Roger Reeder on 11/11/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Group;
@class Tip;
@class Scale;

@interface DAL : NSObject <NSXMLParserDelegate> {
	int	sessionID;
	
	NSXMLParser *parser;

	Group *currentGroup;
	Tip *currentTip;
	Scale *currentScale;

    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;	
}

@property (nonatomic, assign) int sessionID;

@property (nonatomic, retain) NSXMLParser *parser;

@property (nonatomic, retain) Group *currentGroup;
@property (nonatomic, retain) Tip *currentTip;
@property (nonatomic, retain) Scale *currentScale;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *) fetchDailyTip;
- (NSMutableArray *) fetchGroups;

-(void)loadXMLByFile:(NSString *)fileString;
-(void)saveContext;
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end