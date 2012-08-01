//
//  VAS002AppDelegate.h
//  VAS002
//
//  Created by Hasan Edain on 12/20/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FlurryUtility.h"

@interface VAS002AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSPersistentStore *persistentStore;
		
    UIWindow *window;


    UINavigationController *navigationController;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStore *persistentStore;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;



- (IBAction)saveAction:sender;
- (void)fillDefaultGroups;
- (BOOL)doesDatabaseHaveData;
- (NSURL *)getStoreURL;
- (void)setFirstLauchPreferences;
- (void)saveContext;

- (void)addNote;

void uncaughtExceptionHandler(NSException *exception);

#define SQL_FILE_BASE @"VAS002"
#define SQL_FILE_NAME @"VAS002.sqlite"
#define SECURITY_PIN_SETTING @"Security_Pin_Setting"


// Flury Unique ID: 61LDTFTR6XGJZA437D5W

@end