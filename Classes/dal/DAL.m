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
//
//  dalVAS.m
//  VAS002
//
//  Created by Roger Reeder on 11/11/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "DAL.h"
#import "Group.h"
#import "Scale.h"
#import "Result.h"
#import "Tip.h"
#import "VAS002AppDelegate.h"
#import "Error.h"

@implementation DAL

@synthesize sessionID;

@synthesize parser;

@synthesize currentGroup;
@synthesize currentTip;
@synthesize currentScale;

@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;

- (id) init { 
	if ( (self = [super init]) ) { 
		self.currentGroup = nil;
		self.currentTip = nil;
		self.currentScale = nil;
		[self persistentStoreCoordinator];
		[self managedObjectContext];
	} 
	return self; 
}

- (NSString *)fetchDailyTip {
	NSDate *d =[NSDate date];
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"D"];
	int julianDay = [[df stringFromDate:d] intValue];
	// Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tip" inManagedObjectContext:managedObjectContext_];
	
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	// Fetch the records and handle an error
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (!fetchResults) {
		[Error showErrorByAppendingString:@"Unable to read stored file" withError:error];
	}
	NSString *tip = nil; 
	//Pull diffent tip each day by Julian Day modulus count of tips in system.
	if ([fetchResults count] != 0) {
		int i = (julianDay % [fetchResults count]);
		tip = [NSString stringWithString:((Tip *)[fetchResults objectAtIndex:i]).tip];
	}

	[request release];

	return tip;
}

- (NSMutableArray *) fetchGroups {
	// Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext_];
	
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	// Define how we will sort the records
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Fetch the records and handle an error
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		[Error showErrorByAppendingString:@"Unable to fetch groups from file" withError:error];
	}
	
	[request release];
	return [mutableFetchResults autorelease];
}

- (void)saveContext {    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save data" withError:error];
        } 
    }
}    

- (void)loadXMLByFile:(NSString *)fileString {
	self.parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileString]]];
	self.parser.delegate = self;
	[self.parser parse];
}

/*
- (void)parserDidEndDocument:(NSXMLParser *)parser {
// sent when the parser has completed parsing. If this is encountered, the parse was successful.
	//[parser release];
}
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	if ([elementName isEqualToString:@"tip"]) {
		if (self.currentTip != nil) {
			self.currentTip = nil;
		}
		self.currentTip = (Tip *)[NSEntityDescription insertNewObjectForEntityForName:@"Tip" inManagedObjectContext:self.managedObjectContext];
		NSString *tip = nil;
		for (id key in attributeDict) {
			if ([key isEqualToString:@"text"]) {
				tip = (NSString *)[attributeDict objectForKey:key];
				[self.currentTip setTip:tip];
				[self saveContext];
				break;
			}
		}
	}
	if ([elementName isEqualToString:@"group"]) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSError *error = nil;
		
		NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error != nil) {
			[Error showErrorByAppendingString:@"Unable to fetch groups from file" withError:error];
		}
		[fetchRequest release];
		
		NSString *title = nil;
		for (id key in attributeDict) {
			if ([key isEqualToString:@"title"]) {
				title = (NSString *)[attributeDict objectForKey:key];
				break;
			}
		}
		
		for (Group *aGroup in fetchedObjects) {
			if ([aGroup.title isEqualToString:title]) {
				self.currentGroup = aGroup;
			}
		}
	}
	
	if ([elementName isEqualToString:@"scale"]) {
		self.currentScale = (Scale *)[NSEntityDescription insertNewObjectForEntityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
		NSString *minLabel;
		NSString *maxLabel;
		for (id key in attributeDict) {
			if ([key isEqualToString:@"min"]) {
				minLabel = (NSString *)[attributeDict objectForKey:key];
				[self.currentScale setMinLabel:minLabel];
			}
			if ([key isEqualToString:@"max"]) {
				maxLabel = (NSString *)[attributeDict objectForKey:key];
				[self.currentScale setMaxLabel:maxLabel];
			}
		}
		self.currentScale.weight = [NSNumber numberWithInt:100];
		self.currentScale.group = self.currentGroup;
		[self saveContext];
	}
}

//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
//}
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName  {
//}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
		UIApplication *app = [UIApplication sharedApplication];
		VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
        managedObjectContext = appDeleate.managedObjectContext;
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
	managedObjectModel = appDelegate.managedObjectModel;
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

	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
	persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
	[self.parser release];
	
	[self.currentGroup release];
	[self.currentTip release];
	[self.currentScale release];
		
	[self.managedObjectContext release];
	[self.managedObjectModel release];
	[self.persistentStoreCoordinator release];

    [super dealloc];
}

@end