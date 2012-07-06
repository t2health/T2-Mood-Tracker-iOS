//
//  Saved.h
//  VAS002
//
//  Created by Melvin Manzano on 3/27/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Saved : NSManagedObject {
    
}


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *savedDate;
@property (nonatomic, retain) NSString *timestamp;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *sectionIdentifier;
@property (nonatomic, retain) NSString *primitiveSectionIdentifier;
@property (nonatomic, retain) NSDate *primitiveSavedDate;

@end

@interface Saved (CoreDataGeneratedAccessors)

- (void)addSavedObject:(Saved *)value;
- (void)removeNoteObject:(Saved	*)value;
- (void)addSaved:(NSSet *)value;
- (void)removeSaved:(NSSet *)value;

@end