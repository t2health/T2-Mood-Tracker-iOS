//
//  Note.h
//  VAS002
//
//  Created by Hasan Edain on 12/27/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Note : NSManagedObject {

}

@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSDate *noteDate;
@property (nonatomic, retain) NSDate *primitiveNoteDate;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSNumber *noteYear;
@property (nonatomic, retain) NSNumber *noteMonth;
@property (nonatomic, retain) NSNumber *noteDay;
@property (nonatomic, retain) NSString *sectionIdentifier;
@property (nonatomic, retain) NSString *primitiveSectionIdentifier;

@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addNoteObject:(Note *)value;
- (void)removeNoteObject:(Note	*)value;
- (void)addNote:(NSSet *)value;
- (void)removeNote:(NSSet *)value;

@end