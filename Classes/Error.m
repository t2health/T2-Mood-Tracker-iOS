//
//  Error.m
//  VAS002
//
//  Created by Hasan Edain on 1/21/11.
//  Copyright 2011 GDIT. All rights reserved.
//

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
