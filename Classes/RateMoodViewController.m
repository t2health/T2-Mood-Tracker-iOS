//
//  RateMoodViewController.m
//  VAS002
//
//  Created by Hasan Edain on 12/21/10.
//  Copyright 2010 GDIT. All rights reserved.
//

#import "RateMoodViewController.h"
#import "Group.h"
#import "Scale.h"
#import "Result.h"
#import "VAS002AppDelegate.h"
#import <CoreData/CoreData.h>
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Error.h"
#import "GroupResult.h"
#import "ManageScalesViewController.h"
#import "VAS002AppDelegate.h"
#import "EditGroupViewController.h"


@implementation RateMoodViewController

@synthesize currentGroup;
@synthesize sliders;
@synthesize standardDeviation;
@synthesize mean, _scrollView;
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Core Data
    UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;

    
	self.title = self.currentGroup.title;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
    [self setupSliders];
    
	[FlurryUtility report:EVENT_FORM_ACTIVITY];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [_scrollView flashScrollIndicators];
}

- (void)sendNoteRequest:(double)value {
	double difference = abs(value - [self.mean doubleValue]);
	if (difference >= [self.standardDeviation doubleValue]) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:self.mean ,@"mean" ,[NSNumber numberWithDouble:value], @"value", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UnusualEntryAdded" object:self userInfo:info];
	}
}

- (void)calculateStatistics {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
	NSSortDescriptor *scaleIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scale.index" ascending:YES];
	NSSortDescriptor *timestampIndex = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:scaleIndexDescriptor,timestampIndex, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];	
	
	NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(group.title like[cd] %@)",self.currentGroup.title];
	[fetchRequest setPredicate:groupPredicate];
    
	[fetchRequest setFetchLimit:31];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (error) {
		[Error showErrorByAppendingString:@"Unable to fetch information" withError:error];
	}
    
	[scaleIndexDescriptor release];
	[timestampIndex release];
	[sortDescriptors release];
	[fetchRequest release];
	
	double total = 0;
	double count = 0;
	
	for (Result *aResult in fetchedObjects) {
		total += [aResult.value doubleValue];
		count++;
	}
	
	if (count > 0) {
		self.mean = [NSNumber numberWithDouble:total/count];
	}
    
	double totalVariance = 0;
	double variance;
	double varianceSquared;
	
	for (Result *aResult in fetchedObjects) {
		variance = [self.mean doubleValue] - [aResult.value doubleValue];
		varianceSquared = variance * variance;
		totalVariance += varianceSquared;
	}
	
	if (count > 2) {
		self.standardDeviation = [NSNumber numberWithDouble:sqrt(totalVariance/count-1)];
	}
}

- (void)setupSliders {
    NSLog(@"Slidersetup");
	self.sliders = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //508 Compliance
	[sliders setIsAccessibilityElement:YES];
    [sliders setAccessibilityLabel:@"This slider controls blah blah etc...." ];
    
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
	NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(group.title like[cd] %@)",self.currentGroup.title];
	[fetchRequest setPredicate:groupPredicate];
	
	NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:indexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to fetch information" withError:error];
	}
    
	[indexDescriptor release];
	[sortDescriptors release];
	[fetchRequest release];
	
	NSInteger startY = 10;
	NSInteger xOffset = 4;
	NSInteger rowHeight = 40;
    NSInteger labelHeight = 20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        rowHeight = 80;
        labelHeight = 40;
    } 
    
	NSInteger rowNumber = 0;
	NSInteger labelWidth = 120;
	
	
	NSInteger addedScaleCount = 0;
	
	for (Scale *scale in fetchedObjects) {
		if (![scale.minLabel isEqual:@""] && ![scale.maxLabel isEqual:@""]) {
			addedScaleCount ++;
			CGRect frameRect = (CGRect )[self.view frame];
			CGRect currentSliderFrame = CGRectMake(frameRect.origin.x, (rowNumber*rowHeight)+startY, frameRect.size.width, rowHeight);
			CGRect currentMinLabelFrame = CGRectMake(frameRect.origin.x + xOffset, (rowNumber*rowHeight)+startY-4, labelWidth, labelHeight);
			CGRect currentMaxLabelFrame = CGRectMake(frameRect.origin.x + frameRect.size.width - labelWidth - xOffset, (rowNumber*rowHeight)+startY-4, labelWidth, labelHeight);
			
			UILabel *minLabel = [[UILabel alloc] init];
			minLabel.text = scale.minLabel;
			minLabel.frame = currentMinLabelFrame;
			minLabel.backgroundColor = [UIColor clearColor];
			minLabel.textColor = [UIColor whiteColor];
			
			UILabel *maxLabel = [[UILabel alloc] init];
			maxLabel.text = scale.maxLabel;
			maxLabel.frame = currentMaxLabelFrame;
			maxLabel.backgroundColor = [UIColor clearColor];
			maxLabel.textColor = [UIColor whiteColor];
			maxLabel.textAlignment = UITextAlignmentRight;
			maxLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			
			UISlider *sliderView = [[UISlider alloc] init];
			sliderView.frame = currentSliderFrame;
			sliderView.minimumValue = 0;
			sliderView.maximumValue = 99;
			[sliderView setValue:50.0f];
			sliderView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleRightMargin;
			
			[_scrollView addSubview:minLabel];
			[_scrollView addSubview:maxLabel];
			[_scrollView addSubview:sliderView];
			[self.sliders setObject:sliderView forKey:scale.minLabel];
			rowNumber++;
			
			[minLabel release];
			[maxLabel release];
			[sliderView release];
		}
	}
	if (addedScaleCount > 0) {
		NSInteger bottomLastSlider =  (rowNumber*rowHeight)+startY;
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, bottomLastSlider);		
	}
	else {
		NSString *messageString = [NSString stringWithFormat:@"There are no scales for the Category named: %@",self.currentGroup.title];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString
																 delegate:self 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:nil 
														otherButtonTitles:@"Add Scales", nil];
		[actionSheet showFromToolbar:self.navigationController.toolbar];
        [actionSheet release];
	}
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        EditGroupViewController *editGroupViewController = [[EditGroupViewController alloc] initWithNibName:@"EditGroupViewController" bundle:nil];
        editGroupViewController.hidesBottomBarWhenPushed = YES;
        
        editGroupViewController.group = self.currentGroup;
        [self.navigationController pushViewController:editGroupViewController animated:YES];
        [editGroupViewController release];
        
        
        /*
        ManageScalesViewController *manageScalesViewController = [[ManageScalesViewController alloc] initWithNibName:@"ManageScalesViewController" bundle:nil];
        manageScalesViewController.group = self.currentGroup;
        [appDelegate.navigationController pushViewController:manageScalesViewController animated:YES];
        [manageScalesViewController release];
         */
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSInteger sWidth = self.view.frame.size.width;
	NSInteger numRows = [self.sliders count];
	NSInteger sHeight = (numRows * 40) + 10;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        sHeight = (numRows * 80) + 10;
        
    } 
    
	
	CGSize size = CGSizeMake(sWidth, sHeight);
	_scrollView.contentSize = size;
	[_scrollView setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) 
    {
        // reached the bottom
        NSLog(@"reached bottom");
        // self._imageView.hidden = YES;
    }
    
    else
    {
        // self._imageView.hidden = NO;
    }
}


- (IBAction)savePressed:(id)sender {
    NSLog(@"debug:1");
	[self calculateStatistics];
	NSLog(@"debug:2");
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	

	
	NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(group.title like[cd] %@)",self.currentGroup.title];
	[fetchRequest setPredicate:groupPredicate];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[Error showErrorByAppendingString:@"Unable to save rating." withError:error];
	}
	
	[fetchRequest release];
	
	NSDate *now = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:[NSTimeZone localTimeZone]];
	NSDateComponents *nowComponents = [gregorian components:(NSDayCalendarUnit + NSMonthCalendarUnit + NSYearCalendarUnit) fromDate:now];
	
	NSNumber *dayOfMonth = [NSNumber numberWithInt:[nowComponents day]];
	NSNumber *monthOfYear = [NSNumber numberWithInt:[nowComponents month]];
	NSNumber *year = [NSNumber numberWithInt:[nowComponents year]];
	
	[gregorian release];
	
	NSInteger count = 0;
	NSInteger total = 0;
	NSInteger movedCount = 0;
    NSLog(@"debug:3");

	for (Scale *scale in fetchedObjects) {
		if (![scale.minLabel isEqual:@""] && ![scale.maxLabel isEqual:@""]) {
			
			UISlider *slider = [self.sliders objectForKey:scale.minLabel];
			if (slider != nil) {
				Result *result = (Result *)[NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:self.managedObjectContext];
				[result setValue:[NSNumber numberWithFloat:slider.value]];
				[result setTimestamp:now];			
				[result setDay:dayOfMonth];
				[result setMonth:monthOfYear];
				[result setYear:year];
				[result setScale:scale];
				[result setGroup:scale.group];
				count++;
				total += slider.value;
				if (slider.value != 50.0f) {
					movedCount++;
				}
			}
		}
	}
    NSLog(@"debug:4");

	if (count > 0) {
		double avg = total / count;
		GroupResult *groupResult = (GroupResult *)[NSEntityDescription insertNewObjectForEntityForName:@"GroupResult" inManagedObjectContext:self.managedObjectContext];
		[groupResult setValue:[NSNumber numberWithDouble:avg]];
		[groupResult setDay:dayOfMonth];
		[groupResult setMonth:monthOfYear];
		[groupResult setYear:year];
		[groupResult setGroup:self.currentGroup];
		[self sendNoteRequest:avg];
        
		double percentMoved = movedCount / count;
		NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:percentMoved], EVENT_FORM_PERCENT, nil];
		[FlurryUtility report:EVENT_FORM_SAVED withData:usrDict];
        NSLog(@"debug:5");

	}
    NSLog(@"debug:6");

	if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save rating" withError:error];
	} 
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(id)sender {
	[FlurryUtility report:EVENT_FORM_CANCELED];
	[self.navigationController popViewControllerAnimated:YES];	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

- (void)dealloc {
	[currentGroup release];
	[sliders release];
	[standardDeviation release];
	[mean release];
	[managedObjectContext release];
	[super dealloc];
}

@end