//
//  FlurryUtility.m
//  VAS002
//
//  Created by Hasan Edain on 1/26/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "FlurryUtility.h"
#import "FlurryAPI.h"

@implementation FlurryUtility

+ (void)report:(NSString *)activityString {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL useFlurry = [defaults boolForKey:@"DEFAULTS_USE_FLURRY"];
	if (useFlurry == YES) {
		[FlurryAPI logEvent:activityString];
	}
}

+ (void)report:(NSString *)activityString withData:(NSDictionary *)userData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL useFlurry = [defaults boolForKey:@"DEFAULTS_USE_FLURRY"];
	if (useFlurry == YES) {
		[FlurryAPI logEvent:activityString withParameters:userData];
	}
}

+ (void)startTimed:(NSString *)activityString {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL useFlurry = [defaults boolForKey:@"DEFAULTS_USE_FLURRY"];
	if (useFlurry == YES) {
		[FlurryAPI logEvent:activityString timed:YES];
	}
}

+ (void)endTimed:(NSString *)activityString {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL useFlurry = [defaults boolForKey:@"DEFAULTS_USE_FLURRY"];
	if (useFlurry == YES) {
		[FlurryAPI endTimedEvent:activityString withParameters:nil];
	}	
}

@end
