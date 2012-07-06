//
//  RateMoodViewController.h
//  VAS002
//
//  Created by Hasan Edain on 12/21/10.
//  Copyright 2010 GDIT. All rights reserved.
//

@class Group;

@interface RateMoodViewController : UIViewController <UIActionSheetDelegate>{
	Group *currentGroup;
	NSMutableDictionary *sliders;
	IBOutlet UIScrollView *_scrollView;
	NSNumber *standardDeviation;
	NSNumber *mean;

}

@property (nonatomic, retain) Group *currentGroup;
@property (nonatomic, retain) NSMutableDictionary *sliders;
@property (nonatomic, retain) NSNumber *standardDeviation;
@property (nonatomic, retain) NSNumber *mean;
@property (nonatomic, retain) IBOutlet UIScrollView *_scrollView;


- (IBAction)savePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (void)setupSliders;
- (void)calculateStatistics;
- (void)sendNoteRequest:(double)value;

@end
