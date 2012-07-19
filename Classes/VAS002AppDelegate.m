//
//  VAS002AppDelegate.m
//  VAS002
//
//  Created by Hasan Edain on 12/20/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VAS002AppDelegate.h"
#import "RootViewController.h"
#import "DAL.h"
#import "Group.h"
#import "Scale.h"
#import "Error.h"
#import "FlurryAPI.h"
#import "AddNoteViewController.h"
#import "GraphMenuViewController.h"
#import "PasswordViewController.h"


@implementation VAS002AppDelegate

@synthesize managedObjectModel;
@synthesize managedObjectContext;	   
@synthesize persistentStore;
@synthesize persistentStoreCoordinator;

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;




#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler); 
	   
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
	
	[FlurryAPI startSession:@"61LDTFTR6XGJZA437D5W"];
	

	if (![self doesDatabaseHaveData]) {
        NSLog(@"dsfd");
		[self fillDefaultGroups];
		DAL *dal = [[[DAL alloc] init] autorelease];
		dal.managedObjectContext = self.managedObjectContext;
		dal.managedObjectModel = self.managedObjectModel;
		dal.persistentStoreCoordinator = self.persistentStoreCoordinator;
		[dal loadXMLByFile:@"data.xml"];
	}
	NSLog(@"5555");

	RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.managedObjectContext = self.managedObjectContext;
	
	// Add the navigation controller's view to the window and display.
  //  [self.window addSubview:navigationController.view];
  //  [self.window makeKeyAndVisible];

    // Add the tabbar controller's view to the window and display.

    [self.window addSubview:tabBarController.view];
     [self.window makeKeyAndVisible];
	
    application.applicationIconBadgeNumber = 0;
	
	[self setFirstLauchPreferences];
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	UIAlertView *immutableAlert = [[[UIAlertView alloc]initWithTitle:@"Reminder:" message:notification.alertBody delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
	[immutableAlert show];
	
    application.applicationIconBadgeNumber = 0;
}

- (void)setFirstLauchPreferences {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL hasLauchedBefore = [defaults boolForKey:@"HAS_LAUNCHED_BEFORE"];
	
	if (hasLauchedBefore == NO) {
		[defaults setBool:YES forKey:@"HAS_LAUNCHED_BEFORE"];
		[defaults setBool:YES forKey:@"SHOW_TIPS_ON_STARTUP"];
		
		
		//Default the reminders to 8:00AM every day of the week.
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		[components setHour:8];
		[components setMinute:0];
		NSDate *storedDate = [gregorian dateFromComponents:components];
		[defaults setBool:YES forKey:@"MORNING_REMINDER_STATE"];
		[defaults setObject:storedDate forKey:@"MORNING_REMINDER_TIME"];
		
		[defaults setBool:YES forKey:@"SUNDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"MONDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"TUESDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"WEDNESDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"THURSDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"FRIDAY_REMINDER_STATE"];
		[defaults setBool:YES forKey:@"SATURDAY_REMINDER_STATE"];
		
		
		[defaults synchronize];
		[gregorian release];
	}
}

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)doesDatabaseHaveData {
	BOOL hasData = NO;
	NSLog(@"pop");
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSLog(@"pop1");
	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to load Category data." withError:error];
	}
	NSLog(@"pop2");
	if (fetchedObjects != nil) {
		if ([fetchedObjects count] > 0) {
			hasData = YES;			
		}
	}
	NSLog(@"pop3");
	[fetchRequest release];
	
	return hasData;
}

- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *localManagedObjectContext = self.managedObjectContext;
    if (localManagedObjectContext != nil) {
        if ([localManagedObjectContext hasChanges] && ![localManagedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save changes." withError:error];
        } 
    }
}    

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveContext];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckPin" object: nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		[Error showErrorByAppendingString:@"Unable to complete save." withError:error];
    }
}

#pragma mark -
#pragma mark Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext == nil) {
		NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
		if (coordinator != nil) {
			managedObjectContext = [[NSManagedObjectContext alloc] init];
			[managedObjectContext setPersistentStoreCoordinator: coordinator];
			managedObjectContext.undoManager = nil;
		}
    }
	
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSURL *storeUrl = [self getStoreURL];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	NSError *error = nil;
	self.persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
	if (!self.persistentStore) {
		NSLog(@"Error: %@",error);
		[Error showErrorByAppendingString:@"Unable to find database file." withError:error];
    }    

    return persistentStoreCoordinator;
}

-(NSURL *)getStoreURL {
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: SQL_FILE_NAME];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:SQL_FILE_BASE ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	return storeUrl;
}

#pragma mark Add Notes Methods
- (void)addNote
{

    NSString *nibName = @"AddNoteViewController";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        // ipad
        nibName = @"AddNoteViewController-iPad";
    }
}



#pragma mark Default Data
-(void)fillDefaultGroups {	
	
	Group *anxiety = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	anxiety.section = @"Rate";
	anxiety.title = @"Anxiety";
	anxiety.groupDescription = @"Lorem ipsum dolor sit amet";
	anxiety.visible = [NSNumber numberWithBool:YES];
	anxiety.rateable = [NSNumber numberWithBool:YES];
	anxiety.immutable = [NSNumber numberWithBool:YES];
	anxiety.showGraph = [NSNumber numberWithBool:YES];
	anxiety.menuIndex = [NSNumber numberWithInt:1];
	anxiety.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *depression = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	depression.section = @"Rate";
	depression.title = @"Depression";
	depression.groupDescription = @"Lorem ipsum dolor sit amet";
	depression.visible = [NSNumber numberWithBool:YES];
	depression.rateable = [NSNumber numberWithBool:YES];
	depression.immutable = [NSNumber numberWithBool:YES];
	depression.showGraph = [NSNumber numberWithBool:YES];
	depression.menuIndex = [NSNumber numberWithInt:2];
	depression.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *wellness = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	wellness.section = @"Rate";
	wellness.title = @"General Well-Being";
	wellness.groupDescription = @"Lorem ipsum dolor sit amet";
	wellness.visible = [NSNumber numberWithBool:YES];
	wellness.rateable = [NSNumber numberWithBool:YES];
	wellness.immutable = [NSNumber numberWithBool:YES];
	wellness.showGraph = [NSNumber numberWithBool:YES];
	wellness.menuIndex = [NSNumber numberWithInt:3];
	wellness.positiveDescription = [NSNumber numberWithBool:YES];
	
	Group *headInjury = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	headInjury.section = @"Rate";
	headInjury.title = @"Head Injury";
	headInjury.groupDescription = @"Lorem ipsum dolor sit amet";
	headInjury.visible = [NSNumber numberWithBool:YES];
	headInjury.rateable = [NSNumber numberWithBool:YES];
	headInjury.immutable = [NSNumber numberWithBool:YES];
	headInjury.showGraph = [NSNumber numberWithBool:YES];
	headInjury.menuIndex = [NSNumber numberWithInt:4];
	headInjury.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *pTS = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	pTS.section = @"Rate";
	pTS.title = @"PTS (Post-traumatic Stress)";
	pTS.groupDescription = @"Lorem ipsum dolor sit amet";
	pTS.visible = [NSNumber numberWithBool:YES];
	pTS.rateable = [NSNumber numberWithBool:YES];
	pTS.immutable = [NSNumber numberWithBool:YES];
	pTS.showGraph = [NSNumber numberWithBool:YES];
	pTS.menuIndex = [NSNumber numberWithInt:5];
	pTS.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *stress = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	stress.section = @"Rate";
	stress.title = @"Stress";
	stress.groupDescription = @"Lorem ipsum dolor sit amet";
	stress.visible = [NSNumber numberWithBool:YES];
	stress.rateable = [NSNumber numberWithBool:YES];
	stress.immutable = [NSNumber numberWithBool:YES];
	stress.showGraph = [NSNumber numberWithBool:YES];
	stress.menuIndex = [NSNumber numberWithInt:6];
	stress.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *graph = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	graph.section = @"Results";
	graph.title = @"Graph Results";
	graph.groupDescription = @"Lorem ipsum dolor sit amet";
	graph.visible = [NSNumber numberWithBool:YES];
	graph.rateable = [NSNumber numberWithBool:NO];
	graph.immutable = [NSNumber numberWithBool:YES];
	graph.showGraph = [NSNumber numberWithBool:NO];
	graph.menuIndex = [NSNumber numberWithInt:1];;
	graph.positiveDescription = [NSNumber numberWithBool:NO];
    
    Group *results = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	results.section = @"Results";
	results.title = @"Export Results";
	results.groupDescription = @"Lorem ipsum dolor sit amet";
	results.visible = [NSNumber numberWithBool:YES];
	results.rateable = [NSNumber numberWithBool:NO];
	results.immutable = [NSNumber numberWithBool:YES];
	results.showGraph = [NSNumber numberWithBool:NO];
	results.menuIndex = [NSNumber numberWithInt:2];;
	results.positiveDescription = [NSNumber numberWithBool:NO];
    
    Group *savedresults = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	savedresults.section = @"Results";
	savedresults.title = @"Saved Results";
	savedresults.groupDescription = @"Lorem ipsum dolor sit amet";
	savedresults.visible = [NSNumber numberWithBool:YES];
	savedresults.rateable = [NSNumber numberWithBool:NO];
	savedresults.immutable = [NSNumber numberWithBool:YES];
	savedresults.showGraph = [NSNumber numberWithBool:NO];
	savedresults.menuIndex = [NSNumber numberWithInt:3];;
	savedresults.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *notes = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	notes.section = @"Results";
	notes.title = @"View Notes";
	notes.groupDescription = @"Lorem ipsum dolor sit amet";
	notes.visible = [NSNumber numberWithBool:YES];
	notes.rateable = [NSNumber numberWithBool:NO];
	notes.immutable = [NSNumber numberWithBool:YES];
	notes.showGraph = [NSNumber numberWithBool:NO];
	notes.menuIndex = [NSNumber numberWithInt:4];
	notes.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *about = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	about.section = @"Support";
	about.title = @"About T2 Mood Tracker";
	about.groupDescription = @"Lorem ipsum dolor sit amet";
	about.visible = [NSNumber numberWithBool:YES];
	about.rateable = [NSNumber numberWithBool:NO];
	about.immutable = [NSNumber numberWithBool:YES];
	about.showGraph = [NSNumber numberWithBool:NO];
	about.menuIndex = [NSNumber numberWithInt:1];
	about.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *help = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	help.section = @"Support";
	help.title = @"Help";
	help.groupDescription = @"Lorem ipsum dolor sit amet";
	help.visible = [NSNumber numberWithBool:YES];
	help.rateable = [NSNumber numberWithBool:NO];
	help.immutable = [NSNumber numberWithBool:YES];
	help.showGraph = [NSNumber numberWithBool:NO];
	help.menuIndex = [NSNumber numberWithInt:2];
	help.positiveDescription = [NSNumber numberWithBool:NO];
    
    Group *feedback = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	feedback.section = @"Support";
	feedback.title = @"Feedback";
	feedback.groupDescription = @"Lorem ipsum dolor sit amet";
	feedback.visible = [NSNumber numberWithBool:YES];
	feedback.rateable = [NSNumber numberWithBool:NO];
	feedback.immutable = [NSNumber numberWithBool:YES];
	feedback.showGraph = [NSNumber numberWithBool:NO];
	feedback.menuIndex = [NSNumber numberWithInt:3];
	feedback.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *rate = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	rate.section = @"Support";
	rate.title = @"Rate App";
	rate.groupDescription = @"Lorem ipsum dolor sit amet";
	rate.visible = [NSNumber numberWithBool:YES];
	rate.rateable = [NSNumber numberWithBool:NO];
	rate.immutable = [NSNumber numberWithBool:YES];
	rate.showGraph = [NSNumber numberWithBool:NO];
	rate.menuIndex = [NSNumber numberWithInt:4];
	rate.positiveDescription = [NSNumber numberWithBool:NO];
	
	Group *tell = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	tell.section = @"Support";
	tell.title = @"Tell A Friend";
	tell.groupDescription = @"Lorem ipsum dolor sit amet";
	tell.visible = [NSNumber numberWithBool:YES];
	tell.rateable = [NSNumber numberWithBool:NO];
	tell.immutable = [NSNumber numberWithBool:YES];
	tell.showGraph = [NSNumber numberWithBool:NO];
	tell.menuIndex = [NSNumber numberWithInt:5];
	tell.positiveDescription = [NSNumber numberWithBool:NO];
	
    Group *local = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	local.section = @"Support";
	local.title = @"Local Resources/Help";
	local.groupDescription = @"Lorem ipsum dolor sit amet";
	local.visible = [NSNumber numberWithBool:YES];
	local.rateable = [NSNumber numberWithBool:NO];
	local.immutable = [NSNumber numberWithBool:YES];
	local.showGraph = [NSNumber numberWithBool:NO];
	local.menuIndex = [NSNumber numberWithInt:6];
	local.positiveDescription = [NSNumber numberWithBool:NO];

	
#ifdef DEBUG
	Group *data = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	data.section = @"Support";
	data.title = @"Create Data";
	data.groupDescription = @"Creates ratings and Notes data";
	data.visible = [NSNumber numberWithBool:YES];
	data.rateable = [NSNumber numberWithBool:NO];
	data.immutable = [NSNumber numberWithBool:YES];
	data.showGraph = [NSNumber numberWithBool:NO];
	data.menuIndex = [NSNumber numberWithInt:7];
	data.positiveDescription = [NSNumber numberWithBool:NO];
	
#endif
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Error creating default menu." withError:error];
	}
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[self.managedObjectContext release],self.managedObjectContext = nil;
    [self.managedObjectModel release], self.managedObjectModel = nil;
    [self.persistentStoreCoordinator release], self.persistentStoreCoordinator = nil;
	[self.persistentStore release], self.persistentStore = nil;
	
	[self.navigationController release],self.navigationController = nil;
	[self.window release], self.window = nil;
	
	[super dealloc];
}

@end