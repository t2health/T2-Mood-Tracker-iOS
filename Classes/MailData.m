//
//  MailData.m
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "MailData.h"


@implementation MailData

@synthesize mailRecipients;
@synthesize mailSubject;
@synthesize mailBody;

-(void)dealloc {
	[mailRecipients release];
	[mailSubject release];
	[mailBody release];
	
	[super dealloc];
}

@end
