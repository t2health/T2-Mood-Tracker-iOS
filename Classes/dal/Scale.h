//
//  Scale.h
//  VAS002
//
//  Created by Roger Reeder on 11/11/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Group;
@class Result;

@interface Scale :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * minLabel;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * maxLabel;
@property (nonatomic, retain) Group * group;
@property (nonatomic, retain) NSSet* result;
@property (nonatomic, retain) NSNumber *index;

@end


@interface Scale (CoreDataGeneratedAccessors)
- (void)addResultObject:(Result *)value;
- (void)removeResultObject:(Result *)value;
- (void)addResult:(NSSet *)value;
- (void)removeResult:(NSSet *)value;

- (void)addGroupObject:(Group *)value;
- (void)removeGroupObject:(Group *)value;
- (void)addGroup:(NSSet *)value;
- (void)removeGroup:(NSSet *)value;

@end

