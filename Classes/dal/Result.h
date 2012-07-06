//
//  Result.h
//  VAS002
//
//  Created by Roger Reeder on 11/11/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Group;
@class Scale;

@interface Result :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber *day;
@property (nonatomic, retain) NSNumber *month;
@property (nonatomic, retain) NSNumber *year;
@property (nonatomic, retain) Group * group;
@property (nonatomic, retain) Scale * scale;

@end



