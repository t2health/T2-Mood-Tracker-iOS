//
//  MailData.h
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

@interface MailData : NSObject {
	NSArray *mailRecipients;
	NSString *mailSubject;
	NSString *mailBody;
}

@property (nonatomic, retain) NSArray *mailRecipients;
@property (nonatomic, retain) NSString *mailSubject;
@property (nonatomic, retain) NSString *mailBody;

@end
