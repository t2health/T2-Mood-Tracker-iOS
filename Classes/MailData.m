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
	[self.mailRecipients release];
	[self.mailSubject release];
	[self.mailBody release];
	
	[super dealloc];
}

@end
