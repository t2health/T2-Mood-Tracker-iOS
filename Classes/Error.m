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

#import "Error.h"
#import "VAS002AppDelegate.h"
#import "ErrorViewController.h"

@implementation Error

+ (void)showErrorWithString:(NSString *)message withError:(NSError *)error {
#ifdef DEBUG
	id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
	
	if (!sub) {
		sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
	}
	
	if(!sub) {
		NSLog(@"%@:%@ Erro Received: %@", [self class], _cmd, [error localizedDescription]);
		return;
	}
	
	if ([sub isKindOfClass:[NSArray class]] || [sub isKindOfClass:[NSSet class]]) {
		for (NSError *subError in sub) {
			NSLog(@"%@:%@ SubError: %@", [self class], _cmd, [subError localizedDescription]);
		}
	}
	else { 
		NSLog(@"%@:%@ exception %@", [self class], _cmd, [sub description]);
	}	
#endif	
	
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	ErrorViewController *errorViewController = [[[ErrorViewController alloc] initWithNibName:@"ErrorViewController" bundle:nil] autorelease];
	[appDelegate.navigationController pushViewController:errorViewController animated:YES];		
}

+ (void)showErrorByAppendingString:(NSString *)message withError:(NSError *)error {
#ifdef DEBUG
	id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
	
	if (!sub) {
		sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
	}
		
	if(!sub) {
		NSLog(@"%@:%@ Erro Received: %@", [self class], _cmd, [error localizedDescription]);
		return;
	}
		
	if ([sub isKindOfClass:[NSArray class]] || [sub isKindOfClass:[NSSet class]]) {
		for (NSError *subError in sub) {
			NSLog(@"%@:%@ SubError: %@", [self class], _cmd, [subError localizedDescription]);
		}
	}
	else {
		NSLog(@"%@:%@ exception %@", [self class], _cmd, [sub description]);
	}	
#endif
	
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	ErrorViewController *errorViewController = [[[ErrorViewController alloc] initWithNibName:@"ErrorViewController" bundle:nil] autorelease];
	[errorViewController addStringToMessage:message];
	[appDelegate.navigationController pushViewController:errorViewController animated:YES];			
}

@end
