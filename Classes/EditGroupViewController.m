//
//  EditGroupViewController.m
//  VAS002
//
//  Created by Hasan Edain on 1/14/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "EditGroupViewController.h"
#import "ManageScalesViewController.h"
#import "Group.h"
#import "Scale.h"
#import "Error.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "EditScaleViewController.h"
#import "UICustomSwitch.h"

BOOL isPortrait;

@implementation EditGroupViewController

@synthesize group, tableView, scalesArray, scale, allScalesArray;
@synthesize managedObjectContext;
@synthesize positiveLabel, scalePicker_landscape;
@synthesize filterViewItems, topFieldArray, scalesDictionary;
@synthesize manageScaleView, scalePicker, minTextField, maxTextField, pickerArray, manageScaleView_landscape, minTextField_landscape, maxTextField_landscape;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.backgroundView = nil;

	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
	
    filterViewItems = [[NSMutableArray alloc] init];
    UIDeviceOrientation interfaceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) 
    {
        isPortrait = YES;
        
    }
    else if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight))  
    {
        isPortrait = NO;
    }
    
	if (self.group != nil) 
    {
        
        [self fillScalesArray];
        
        self.topFieldArray = [NSArray arrayWithObjects:@"Category", @"Positive", @"Scale", nil];
        
        NSDictionary *scaleDict = [NSDictionary dictionaryWithObject:scalesArray forKey:@"Groups"];
        
        NSDictionary *fieldDict = [NSDictionary dictionaryWithObject:topFieldArray forKey:@"Groups"];
        
        
        [filterViewItems addObject:fieldDict];
        [filterViewItems addObject:scaleDict];
        
        
        NSLog(@"filterViewItems: %@", filterViewItems);

        
		self.title = group.title;
		groupTextField.text = self.group.title;
        NSLog(@"group: %@  switch: %i", group.title, [group.positiveDescription intValue]);
        if ([group.positiveDescription intValue] == 0) 
        {
            isPositveSwitch.on = NO;
        }
        else 
        {
            isPositveSwitch.on = YES;
        }
        
        // Delete Button
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteGroupPressed:)];
        self.navigationItem.rightBarButtonItem = deleteButton;
        [deleteButton release];
        
        
        
        
	}
	else {
        
		self.title = @"New Category";
        
        self.topFieldArray = [NSArray arrayWithObjects:@"Category", nil];
        
        
        NSDictionary *fieldDict = [NSDictionary dictionaryWithObject:topFieldArray forKey:@"Groups"];
        
        
        [filterViewItems addObject:fieldDict];
        
	}
	

    
    // NOTIFICATIONS----------------------------------------------//
    // Listen for Actions from Option UITableViewController
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(makePositive) name:@"toggleSwitch_makePositive" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(makeNegative) name:@"toggleSwitch_makeNegative" object: nil];
    // Orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    // NOTIFICATIONS----------------------------------------------//
    
    
    // Fill Picker Array
    [self fillValues];
    NSLog(@"pickerArray: %@", pickerArray);
   // self.pickerArray = [[[NSArray alloc] initWithObjects:
                   //      @"30 days", @"90 days", @"180 days", @"1 year", nil] autorelease];

    
    
	[FlurryUtility report:EVENT_GROUP_ACTIVITY];
}

- (void)viewDidUnload
{
    filterViewItems = nil;
}

- (void)saveEdit {
	self.group.title = groupTextField.text;
	
	NSError *error = nil;
	
	if ([self.managedObjectContext hasChanges] ) {
		if(![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save group edit." withError:error];
		}
	}
	
	//[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Fill Data

- (void)fillScalesArray {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(group.title= %@)", self.group.title];
    
    NSArray *finalPredicateArray = [NSArray arrayWithObjects:groupPredicate, nil];
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:finalPredicateArray];
    [fetchRequest setPredicate:finalPredicate];
    
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [Error showErrorByAppendingString:@"Unable to get data" withError:error];
    }
    
    NSMutableArray *scaleArray = [[[NSMutableArray alloc] init] retain];
    NSMutableArray *allScaleArray = [[[NSMutableArray alloc] init] retain];

    for (Scale *aScales in objects) 
    {
        [allScaleArray addObject:aScales];
    }
    
    for (Scale *aScale in objects) 
    {
        if (![aScale.minLabel isEqualToString:@""]) 
        {
            [scaleArray addObject:aScale];
        }
    }
    scalesArray = [NSArray arrayWithArray:scaleArray];
    allScalesArray = [[NSArray arrayWithArray:allScaleArray] retain];

    [scaleArray release];
    [allScaleArray release];
    [fetchRequest release];
}

- (void)fillValues
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSMutableDictionary *allValueDict = [[NSMutableDictionary alloc] init];
	// Create the sort descriptors array.
	NSSortDescriptor *indexDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"minLabel" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:indexDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [Error showErrorByAppendingString:@"Unable to get data" withError:error];
    }
    
    
    for (Scale *aScale in objects) 
    {
        if (![aScale.minLabel isEqualToString:@""]) 
        {
            NSString *tempValueStr = [NSString stringWithFormat:@"%@-%@", aScale.minLabel, aScale.maxLabel];
            [allValueDict setValue:tempValueStr forKey:tempValueStr];
        }
    }
    NSArray *valueArray = [allValueDict allKeys];
     self.pickerArray = [[[NSArray alloc] initWithArray:valueArray] autorelease];

}


#pragma mark Buttons
- (IBAction)deleteGroupPressed:(id)sender {
	NSString *titleString = [NSString stringWithFormat:@"Delete Category? %@",self.group.title];
	
	UIAlertView *immutableAlert = [[[UIAlertView alloc]initWithTitle:titleString message:@"You are about to delete this Category, and all data associated with it." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil] autorelease];
	[immutableAlert show];
}

- (IBAction)manageScalesPressed:(id)sender {

    
	ManageScalesViewController *manageScalesViewController = [[ManageScalesViewController alloc] initWithNibName:@"ManageScalesViewController" bundle:nil];
	manageScalesViewController.group = self.group;
	[self.navigationController pushViewController:manageScalesViewController animated:YES];
	[manageScalesViewController release];
    
}

#pragma mark Alert 
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1)
	{
		NSManagedObject *local = [self.managedObjectContext objectWithID:[self.group objectID]];
		if ([local isDeleted]) {
			return;
		}
		if (![local isInserted]) {
			[self saveAction:self];
		}
		
		[self.managedObjectContext deleteObject:local];
		
		NSError *error = nil;
		if ([self.managedObjectContext hasChanges]){
			if (![self.managedObjectContext save:&error]) {
				[Error showErrorByAppendingString:@"Unable to save edits made to Category." withError:error];
			}	
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		[FlurryUtility report:EVENT_DELETE_GROUP_ACTIVITY];
	}
}

#pragma mark actionSheet


- (IBAction)saveAction:(id)sender {
	NSError *error = nil;
	
	if (![self.managedObjectContext hasChanges])return;
	if (![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save Category edit." withError:error];
	}
}

#pragma mark Rotation
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)reloadAfterCreate
{
    [self fillScalesArray];
    
    self.topFieldArray = [NSArray arrayWithObjects:@"Category", @"Positive", @"Scale", nil];
    
    NSDictionary *scaleDict = [NSDictionary dictionaryWithObject:scalesArray forKey:@"Groups"];
    
    NSDictionary *fieldDict = [NSDictionary dictionaryWithObject:topFieldArray forKey:@"Groups"];
    
    
    filterViewItems = nil;
    [filterViewItems release];
    
    filterViewItems = [[NSMutableArray alloc] init];

    
    [filterViewItems addObject:fieldDict];
    [filterViewItems addObject:scaleDict];
    
    
    self.title = group.title;
    groupTextField.text = self.group.title;
    NSLog(@"filterViewItems: %@ ", filterViewItems);
    if ([group.positiveDescription intValue] == 0) 
    {
        isPositveSwitch.on = NO;
    }
    else 
    {
        isPositveSwitch.on = YES;
    }
    
    // Delete Button
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteGroupPressed:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    [deleteButton release];
    
    [tableView reloadData];

    
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text field return: %i", textField.tag);
	if (textField == groupTextField) {
		[groupTextField resignFirstResponder];
		self.title = groupTextField.text;
		
		//manageScalesButton.enabled = YES;
		deleteGroup.enabled = YES;
		if (self.group == nil) {
			[self addGroup];
            [self reloadAfterCreate];

		}
		else {
			[self saveEdit];
		}
	}
	
	return YES;	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	BOOL shouldChangeText = YES;
	
    NSMutableCharacterSet *charactersToKeep = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToKeep addCharactersInString:@" "];
    
    NSCharacterSet *charactersToRemove = [charactersToKeep invertedSet];
    
    NSString *trimmedReplacement = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@"" ];
    
	
	if (![trimmedReplacement isEqual:string]) {
		shouldChangeText = NO;
	}
	
	return shouldChangeText;
}

-(BOOL) doesGroupnameExist:(NSString *)groupName {
	BOOL doesExist = NO;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, titleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
	[fetchRequest setPredicate:showGraphPredicate];
	
	
	NSError *error = nil;
	NSArray *groupArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Group * aGroup in groupArray) {
		if ([aGroup.title isEqual:groupName]) {
			doesExist = YES;
			break;
		}
	}
	
	[sectionTitleDescriptor autorelease];
	[titleDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
	
	return doesExist;
}

- (NSNumber *)getNextMenuIndex {
	NSNumber *menuIdx = [NSNumber numberWithInt:0];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *menuIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuIndex" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, menuIndexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
	[fetchRequest setPredicate:showGraphPredicate];
	
	
	NSError *error = nil;
	NSArray *groupArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Group * aGroup in groupArray) {
		if ([aGroup.menuIndex compare:menuIdx] == NSOrderedDescending) { //Groups menu index is larger than the current value
			menuIdx = aGroup.menuIndex;
		}
	}
	
	[sectionTitleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
	
	return [[menuIdx retain] autorelease];
}

#pragma mark Add Group
- (void)addGroup {	
	NSString *groupName = groupTextField.text;
	
	if ([self doesGroupnameExist:groupName] == YES) {
		NSString *messageString = [NSString stringWithFormat:@"You already have a group titled: %@",groupName];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString
                                                                 delegate:self 
                                                        cancelButtonTitle:@"Ok" 
                                                   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
		[groupTextField becomeFirstResponder];
	}
	else if([groupName isEqual:@""]) {
		NSString *messageString = [NSString stringWithFormat:@"A Category must contain at least one character: %@",groupName];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageString
																 delegate:self 
														cancelButtonTitle:@"Ok" 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
		[groupTextField becomeFirstResponder];
	}
	else {
		Group *newGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		newGroup.section = @"Rate";
		newGroup.title = groupTextField.text;
		newGroup.groupDescription = @"Lorem ipsum dolor sit amet";
		newGroup.visible = [NSNumber numberWithBool:YES];
		newGroup.rateable = [NSNumber numberWithBool:YES];
		newGroup.immutable = [NSNumber numberWithBool:NO];
		newGroup.showGraph = [NSNumber numberWithBool:YES];
		newGroup.menuIndex = [self getNextMenuIndex];
		newGroup.positiveDescription = [NSNumber numberWithBool:isPositveSwitch.on];
		
		NSError *error = nil;
        

		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving new Category" withError:error];
		}
        
		Scale *newScale;
		for (NSInteger i = 0; i<10; i++) {
			newScale = [NSEntityDescription insertNewObjectForEntityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
			
			newScale.maxLabel = @"";
			newScale.minLabel = @"";			
			
			newScale.weight = [NSNumber numberWithInt:50];
			newScale.group = newGroup;
			newScale.index = [NSNumber numberWithInt:i];
			
			error = nil;
			if (![self.managedObjectContext save:&error]) {
				[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
			}


            
		}
		
		self.group = newGroup;
        [self addLegendInfo];
	}
}

#pragma mark Manager Helper Methods

- (void)addScale
{
    
    NSLog(@"**************allScalesArray: %@", allScalesArray);
    self.scale = nil;
    [self showManager];

    
}

- (void)slideDownDidStop
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
	// the date picker has finished sliding downwards, so remove it
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        [self.manageScaleView removeFromSuperview];

    }
    else 
    {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            [self.manageScaleView removeFromSuperview];
        }
        else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
        {
            [self.manageScaleView_landscape removeFromSuperview];

        }
        
    }
}


- (void)saveScale
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);

    // Check Scale Count
    int curScale;

    if (self.scale == nil) 
    {        
        NSLog(@"Scale is nil");
        if (scalesArray.count == 0) 
        {
            curScale = 0;
            NSLog(@"allScalesArray.count == 0");

        }
        else 
        {
            NSLog(@"allScalesArray.count != 0");
            NSMutableDictionary *scalesUsedDict = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < scalesArray.count; i++) 
            {
                Scale *tempScale = [scalesArray objectAtIndex:i];
                [scalesUsedDict setValue:@"Used" forKey:[NSString stringWithFormat:@"%@", tempScale.index]];
            }
            NSArray *whichUsed = [scalesUsedDict allKeys];
            NSMutableArray *notUsed = [[NSMutableArray alloc] init];
            
            int cnt = whichUsed.count;
            
            for (int c = 0; c < 10; c++) 
            {
                for (int i = 0; i < cnt; i++) 
                {
                    
                    BOOL isStringThere = [whichUsed containsObject:[NSString stringWithFormat:@"%i", c]];
                    
                    if (!isStringThere) 
                    {
                        [notUsed addObject:[NSString stringWithFormat:@"%i", c]];
                    }

                }
            }
            NSLog(@"whichUsed: %@", whichUsed);

            NSLog(@"notUsed: %@", notUsed);
            curScale = [[notUsed objectAtIndex:0] intValue];
        }
    }
    else 
    {
       // scale
        NSLog(@"Scale is NOT nil");

        curScale = [self.scale.index intValue];
    }

    
    
    self.scale = [allScalesArray objectAtIndex:curScale];
    NSLog(@"*****curScale: %@", scale);

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        self.scale.minLabel = minTextField.text;
        self.scale.maxLabel = maxTextField.text;
        
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
        self.scale.minLabel = minTextField_landscape.text;
        self.scale.maxLabel = maxTextField_landscape.text;
        
    }
    
    
    NSError *error = nil;
    
    if ([self.managedObjectContext hasChanges] ) {
        if(![self.managedObjectContext save:&error]) {
            [Error showErrorByAppendingString:@"Unable to save scale edit." withError:error];
        }
    }    
     
    // Add Color and Symbol
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *colorSubDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_COLOR_DICTIONARY"]];
    NSMutableDictionary *symbolSubDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"]];
    
    NSMutableDictionary *subColorDict = [NSMutableDictionary dictionaryWithDictionary:[colorSubDict objectForKey:group.title]];
    NSMutableDictionary *subSymbolDict = [NSMutableDictionary dictionaryWithDictionary:[symbolSubDict objectForKey:group.title]];
    
    
    int randomColor = arc4random_uniform(9);
    int randomSymbol = arc4random_uniform(15);
    UIColor *newGroupColor = [self UIColorForIndex:randomColor];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newGroupColor];
    
    
    [subColorDict setObject:data forKey:scale.minLabel];
    [subSymbolDict setObject:[NSString stringWithFormat:@"%i",randomSymbol] forKey:scale.minLabel];
    
    
    [colorSubDict setObject:subColorDict forKey:group.title];
    [symbolSubDict setObject:subSymbolDict forKey:group.title];
    
    [defaults setValue:[NSDictionary dictionaryWithDictionary:colorSubDict] forKey:@"LEGEND_SUB_COLOR_DICTIONARY"];
    [defaults setValue:[NSDictionary dictionaryWithDictionary:symbolSubDict] forKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"];
    
    
    
    [self reloadAfterCreate];    
    
    [self resignManager];

}

- (void)addLegendInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *colorDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    NSMutableDictionary *symbolDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    
    int randomColor = arc4random_uniform(9);
    int randomSymbol = arc4random_uniform(15);
    UIColor *newGroupColor = [self UIColorForIndex:randomColor];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newGroupColor];
    
    [colorDict setObject:data forKey:groupTextField.text];
    [symbolDict setObject:[NSString stringWithFormat:@"%i",randomSymbol] forKey:groupTextField.text];
    
    
    [defaults setValue:[NSDictionary dictionaryWithDictionary:colorDict] forKey:@"LEGEND_COLOR_DICTIONARY"];
    [defaults setValue:[NSDictionary dictionaryWithDictionary:symbolDict] forKey:@"LEGEND_SYMBOL_DICTIONARY"];
    
}

#pragma mark symbols

-(UIImage *)UIImageForIndex:(NSInteger)index {
	NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Symbol_Circle.png"], [UIImage imageNamed:@"Symbol_Cross.png"], [UIImage imageNamed:@"Symbol_Diamondring.png"], [UIImage imageNamed:@"Symbol_Hourglass.png"], [UIImage imageNamed:@"Symbol_Pentagon.png"], [UIImage imageNamed:@"Symbol_Square.png"], [UIImage imageNamed:@"Symbol_Fivestar.png"], [UIImage imageNamed:@"Symbol_Triangle.png"], [UIImage imageNamed:@"Symbol_Spade.png"], [UIImage imageNamed:@"Symbol_Club.png"], [UIImage imageNamed:@"Symbol_Moon.png"], [UIImage imageNamed:@"Symbol_Diamondclassic.png"], [UIImage imageNamed:@"Symbol_Clover.png"], [UIImage imageNamed:@"Symbol_Skew.png"], [UIImage imageNamed:@"Symbol_Quadstar.png"], [UIImage imageNamed:@"Symbol_Octogon.png"], nil];
	
	UIImage *image = nil;
	//NSLog(@"imageArray: %@", imageArray);
    // Perm fix for color bug from v2.0; 5/17/2012 Mel Manzano
	if (index >=0 && index < [imageArray count]) {
		image = [imageArray objectAtIndex:index];
		[[image retain] autorelease];
	}
    else // If index is > color array count, then start over.
    {
        // Split index into digits via array
        NSString *stringNumber = [NSString stringWithFormat:@"%i", index];
        NSMutableArray *digits = [NSMutableArray arrayWithCapacity:[stringNumber length]];
        const char *cstring = [stringNumber cStringUsingEncoding:NSASCIIStringEncoding];
        while (*cstring) {
            if (isdigit(*cstring)) {
                [digits addObject:[NSString stringWithFormat:@"%c", *cstring]];
            }
            cstring++;
        }
        
        // Take last digit in array and use for color selection
        int lastDigit = [digits count] - 1;
        int overCount = [[digits objectAtIndex:lastDigit] intValue];
        image = [imageArray objectAtIndex:overCount];
    }
    
	return image;
}


#pragma mark colors

-(UIColor *)UIColorForIndex:(NSInteger)index {
	NSArray *colorsArray = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor redColor], [UIColor purpleColor], [UIColor grayColor], [UIColor brownColor], [UIColor cyanColor], [UIColor magentaColor], [UIColor lightGrayColor], nil];
	
	UIColor *color = nil;
	
    // Perm fix for color bug from v2.0; 5/17/2012 Mel Manzano
	if (index >=0 && index < [colorsArray count]) {
		color = [colorsArray objectAtIndex:index];
		[[color retain] autorelease];
	}
    else // If index is > color array count, then start over.
    {
        // Split index into digits via array
        NSString *stringNumber = [NSString stringWithFormat:@"%i", index];
        NSMutableArray *digits = [NSMutableArray arrayWithCapacity:[stringNumber length]];
        const char *cstring = [stringNumber cStringUsingEncoding:NSASCIIStringEncoding];
        while (*cstring) {
            if (isdigit(*cstring)) {
                [digits addObject:[NSString stringWithFormat:@"%c", *cstring]];
            }
            cstring++;
        }
        
        // Take Last digit in array and use for color selection
        int lastDigit = [digits count] - 1;
        int overCount = [[digits objectAtIndex:lastDigit] intValue];
        color = [colorsArray objectAtIndex:overCount];
    }
    
	return color;
}

- (void) makePositive
{
    if (self.group != nil) {

		self.group.positiveDescription = [NSNumber numberWithInt:1];
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
		}
	}
}

- (void) makeNegative
{
    if (self.group != nil) {
        
		self.group.positiveDescription = [NSNumber numberWithInt:0];
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
		}
	}

}

- (IBAction)switchFlipped:(id)sender {
    NSLog(@"switched to: %i", isPositveSwitch.on);

	if (self.group != nil) {
        if (isPositveSwitch.on) 
        {
            isPositveSwitch.on = NO;
        }
        else 
        {
            isPositveSwitch.on = YES;
        }
		self.group.positiveDescription = [NSNumber numberWithBool:isPositveSwitch.on];
        
		NSLog(@"switched to: %i", isPositveSwitch.on);
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Error saving Scale in Category" withError:error];
		}
	}
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    NSString *pickedRange = [pickerArray objectAtIndex:row];
    NSArray *splitValue = [pickedRange componentsSeparatedByString:@"-"];
    NSString *theMinLabel = [splitValue objectAtIndex:0];
    NSString *theMaxLabel = [splitValue objectAtIndex:1];
    
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        self.minTextField.text = theMinLabel;
        self.maxTextField.text = theMaxLabel;

    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
    {
     //   self.minTextField.text = theMinLabel;
      //  self.maxTextField.text = theMaxLabel;

        self.minTextField_landscape.text = theMinLabel;
        self.maxTextField_landscape.text = theMaxLabel;

    }
    

}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [pickerArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [pickerArray objectAtIndex:row];
} 

#pragma mark Manager

- (void) showManager
{
        
    // Change Buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(resignManager)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveScale)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    // Change Nav Title
    self.title = @"Manage Scale";

    NSLog(@"scale: %@", scale);

    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);    
    
    int startHeight = 0;
    int startWeight = 0;
    int headerSpace = 44;
        
    // check if our rangePicker is already on screen
    if (self.manageScaleView.superview == nil)
    {
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {

            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            
            if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
            {
                startHeight = 1024;
                startWeight = 780;
                headerSpace = 24;
            }
            else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
            {
                startHeight = 780;
                startWeight = 1024;
                headerSpace = 24;
            }
            
            
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGSize pickerSize = [self.manageScaleView sizeThatFits:CGSizeZero];
            [self.view addSubview: self.manageScaleView];
            
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          startWeight, pickerSize.height);
            self.manageScaleView.frame = startRect;
            // compute the end frame
            CGRect pickerRect = CGRectMake(0.0,
                                           0.0,
                                           startWeight,
                                           startHeight);
            // start the slide up animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            
            self.manageScaleView.frame = pickerRect;
            [UIView commitAnimations];
            
            [self.scalePicker selectRow:0 inComponent:0 animated:YES];
            
            
            
            if (self.scale != nil) 
            {
                minTextField.text = scale.minLabel;
                maxTextField.text = scale.maxLabel;
            }
            else 
            {
                minTextField.text = @"";
                maxTextField.text = @"";
                
            }
            
        }
        else 
        {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            
            if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
            {
                
                CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
                CGSize pickerSize = [self.manageScaleView sizeThatFits:CGSizeZero];
                [self.view addSubview: self.manageScaleView];

                //iPhone
                startHeight = 480;
                startWeight = 320;
                
                CGRect startRect = CGRectMake(0.0,
                                              screenRect.origin.y + screenRect.size.height,
                                              startWeight, pickerSize.height);
                self.manageScaleView.frame = startRect;
                // compute the end frame
                CGRect pickerRect = CGRectMake(0.0,
                                               0.0,
                                               startWeight,
                                               startHeight);
                // start the slide up animation
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                
                self.manageScaleView.frame = pickerRect;
                [UIView commitAnimations];
                
                
                [self.scalePicker selectRow:0 inComponent:0 animated:YES];
                
                
                
                if (self.scale != nil) 
                {
                    minTextField.text = scale.minLabel;
                    maxTextField.text = scale.maxLabel;
                }
                else 
                {
                    minTextField.text = @"";
                    maxTextField.text = @"";
                    
                }
                
            }
            else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
            {
                CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
                CGSize pickerSize = [self.manageScaleView_landscape sizeThatFits:CGSizeZero];
                [self.view addSubview: self.manageScaleView_landscape];

                
                //iPhone
                startHeight = 320;
                startWeight = 480;
                
                CGRect startRect = CGRectMake(0.0,
                                              screenRect.origin.y + screenRect.size.height,
                                              startWeight, pickerSize.height);
                self.manageScaleView_landscape.frame = startRect;
                // compute the end frame
                CGRect pickerRect = CGRectMake(0.0,
                                               0.0,
                                               startWeight,
                                               startHeight);
                // start the slide up animation
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                
                self.manageScaleView_landscape.frame = pickerRect;
                [UIView commitAnimations];
                
                
                [self.scalePicker selectRow:0 inComponent:0 animated:YES];
                
                
                
                if (self.scale != nil) 
                {
                    minTextField_landscape.text = scale.minLabel;
                    maxTextField_landscape.text = scale.maxLabel;
                }
                else 
                {
                    minTextField_landscape.text = @"";
                    maxTextField_landscape.text = @"";
                    
                }
            }

        }

    }
    
}

- (void)resignManager
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.manageScaleView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.manageScaleView.frame = endFrame;
        [UIView commitAnimations];
    }
    else 
    {
        
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGRect endFrame = self.manageScaleView.frame;
            endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
            
            // start the slide down animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
            
            self.manageScaleView.frame = endFrame;
            [UIView commitAnimations];
        }
        else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight)  
        {
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGRect endFrame = self.manageScaleView_landscape.frame;
            endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
            
            // start the slide down animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            // we need to perform some post operations after the animation is complete
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
            
            self.manageScaleView_landscape.frame = endFrame;
            [UIView commitAnimations];
        }
        
    }
    
    // Delete Button
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteGroupPressed:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    [deleteButton release];	
    
    self.navigationItem.leftBarButtonItem = nil;
    
    // Change Title
    self.title = group.title;
    self.scale = nil;
    
    NSLog(@"scale: %@", scale);
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    UIDeviceOrientation interfaceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) 
    {
        NSLog(@"***** Orientation: Portrait");
        if (!isPortrait) {
            [manageScaleView removeFromSuperview];
        }
        isPortrait = YES;
        
    }
    else if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && (interfaceOrientation == UIDeviceOrientationLandscapeLeft ||interfaceOrientation == UIDeviceOrientationLandscapeRight))  
    {
        NSLog(@"***** Orientation: Landscape");
        
        if (isPortrait) {
            [manageScaleView_landscape removeFromSuperview];
        }
        isPortrait = NO;
        
    }
    else if (interfaceOrientation == UIDeviceOrientationFaceUp || interfaceOrientation == UIDeviceOrientationFaceDown)
    {
        NSLog(@"***** Orientation: Other");
        
    }
    else {
        NSLog(@"***** Orientation: Unknown");
        
    }
}



#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
	return [filterViewItems count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    
    NSDictionary *dictionary = [filterViewItems objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"Groups"];
    NSLog(@"arraycount: %i", [array count]);
    
    return [array count];
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
    // create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)] autorelease];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
    NSString *sectionName = @"";
    if (section == 1) 
    {
        sectionName = @"Scales";
    }
    else
    {
        sectionName = @"Category";
    }
    
    headerLabel.text = sectionName;
    
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    
	//static NSString *cellIdentifier = @"Cell";
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell %d, %d", indexPath.row, indexPath.section];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:cellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
	// Configure the cell to show the Categories title
    NSInteger row = [indexPath indexAtPosition:1];
	
    // Fetch scales
    NSString *cellName = @"";
   
    
    if (indexPath.section == 0) 
    {
        
        cellName = [self.topFieldArray objectAtIndex:indexPath.row];
        
        if ([cellName isEqualToString:@"Positive"]) 
        {
            
            UICustomSwitch *switchView = [[UICustomSwitch alloc] initWithFrame:CGRectZero];
            switchView = [UICustomSwitch switchWithLeftText:@"YES" andRight:@"NO"];

            NSLog(@"Creating Cell Positive: %i", isPositveSwitch.on);
            
            if (isPositveSwitch.on) 
            {
                NSLog(@"IS ON");
                switchView.on = YES;
                switchView.value = 1.0;
            }
            else 
            {
                NSLog(@"IS OFF");
                switchView.on = NO;
                switchView.value = 0.0;

            }
                        
            cell.accessoryView =  switchView;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:10];

            cell.textLabel.text = @"Is this category a positive in nature?";
            
            
                         
        }
        else if ([cellName isEqualToString:@"Scale"]) 
        {
        
            float startX = 0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
            {
                // iPad
                UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
                {
                    startX = 300;
                }
                else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
                {
                    startX = 300;                    
                }
            }
            else 
            {
                // iPhone
                UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
                {
                    startX = 120;                    
                }
                else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
                {
                    startX = 180;
                    
                }
                
            }
            
            
            UIButton *myButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
            [myButton setTitle:@"+ Add Scale" forState:UIControlStateNormal];
            myButton.frame = CGRectMake(startX, 5.0, 150, 30);
            [myButton addTarget:self action:@selector(addScale) forControlEvents:(UIControlEventTouchUpInside)];
            
            if (scalesArray.count == 10) 
            {
                myButton.enabled = NO;
            }
            
            cell.accessoryView = myButton;
            [myButton release];
        }
        else if ([cellName isEqualToString:@"Category"]) 
        {
            
            float startX = 25;
            float widthX = 280;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
            {
                // iPad
                UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
                {
                    startX = 60;
                    widthX = 650;
                }
                else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
                {
                    startX = 60;
                    widthX = 650;

                }
            }
            else 
            {
                // iPhone
                UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
                {
                    startX = 25;
                    widthX = 280;

                }
                else if(interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight)
                {
                    startX = 25;
                    widthX = 280;

                }
                
            }
            UITextField *cField = [[UITextField alloc] initWithFrame:CGRectMake(startX, 10, widthX, 30)];

            
            cField.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            if (group.title) 
            {
                cField.text = group.title;
            }
            cField.placeholder = @"Enter a Category Name (No Punctuation)";
            
            cField.keyboardType = UIKeyboardTypeDefault;
            cField.returnKeyType = UIReturnKeyDone;
            cField.tag = 0;
            [cField setEnabled:YES];
            groupTextField = cField;
            groupTextField.delegate = self;
            [cell addSubview:groupTextField];
            [cField release];


        }
    }
    else
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
        
        // scales
        Scale *curScale = [scalesArray objectAtIndex:row];
		cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = curScale.minLabel;
        cell.detailTextLabel.text = curScale.maxLabel;


    }

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    return UITableViewCellEditingStyleNone;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    if (indexPath.section == 0) 
    {
        
    }
    else 
    {
        

        self.scale = [scalesArray objectAtIndex:[indexPath row]];
            
        
        
        NSLog(@"scale: %@", scale);
        NSLog(@"scalesArray: %@", scalesArray);

        [self showManager];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSLog(@"***** FUNCTION %s *****", __FUNCTION__);
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark Memory management

- (void)dealloc {
	if (self.group != nil) {
		[self.group release];		
	}
	[self.managedObjectContext release];
    [super dealloc];
}

@end