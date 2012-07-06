//
//  Group.h
//  VAS002
//
//  Created by Roger Reeder on 11/12/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Result;
@class Scale;
@class Section;
@class GroupResult;

@interface Group :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *section;
@property (nonatomic, retain) NSString *groupDescription;
@property (nonatomic, retain) NSNumber *visible;
@property (nonatomic, retain) NSNumber *rateable;
@property (nonatomic, retain) NSNumber *showGraph;
@property (nonatomic, retain) NSNumber *immutable;
@property (nonatomic, retain) NSNumber *menuIndex;
@property (nonatomic, retain) NSNumber *positiveDescription;
@property (nonatomic, retain) NSSet *result;
@property (nonatomic, retain) NSSet *groupResult;
@property (nonatomic, retain) NSSet *scale;

@end


@interface Group (CoreDataGeneratedAccessors)
- (void)addResultObject:(Result *)value;
- (void)removeResultObject:(Result *)value;
- (void)addResult:(NSSet *)value;
- (void)removeResult:(NSSet *)value;

- (void)addGroupResultObject:(GroupResult *)value;
- (void)removeGroupResultObject:(GroupResult *)value;
- (void)addGroupResult:(NSSet *)value;
- (void)removeGroupResult:(NSSet *)value;

- (void)addScaleObject:(Scale *)value;
- (void)removeScaleObject:(Scale *)value;
- (void)addScale:(NSSet *)value;
- (void)removeScale:(NSSet *)value;
@end

