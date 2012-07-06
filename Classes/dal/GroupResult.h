//
//  GroupResult.h
//  VAS002
//
//  Created by Hasan Edain on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Group;

@interface GroupResult :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) Group * group;

@end



