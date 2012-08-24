//
//  ChartOptionsViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 5/24/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "ChartOptionsViewController.h"
#import "SChartOptionsViewController.h"
#import "GroupsViewController.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "Group.h"
#import "Scale.h"
#import "VAS002AppDelegate.h"
#import "EditGroupViewController.h"
#import "Error.h"
#import "HRColorUtil.h"
#import "HRColorPickerViewController.h"

@implementation ChartOptionsViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize switchDictionary;
@synthesize groupsDictionary;
@synthesize _tableView, pickerView, userSettingsDictionary;
@synthesize colorPicker, symbolPicker, colorsDictionary, symbolsDictionary, editGroupName;

int editWhat;

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.backgroundView = nil;
    NSLog(@"CHART OPTION VIEW LOADED");
    // Default to color
    editWhat = 0;
	pickerView.hidden = YES;
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
    
	self.title = @"Customize Charting";
    // [_tableView setBackgroundView:nil];
    //  [_tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    // [_tableView setBackgroundColor:UIColor.clearColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popToGroups)];
    backButton.title = @"Back";
	self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
	[FlurryUtility report:EVENT_EDIT_GROUP_ACTIVITY];
}

- (void)viewWillAppear:(BOOL)animated {
    
	[self fillGroupsDictionary];
    [self fillColors];
    [self fillSymbols];
    
	[_tableView reloadData];
}

- (void)viewDidUnload {
	self.fetchedResultsController = nil;
}
- (void)popNav
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Create dictionaries

- (void)fillGroupsDictionary {
	NSArray *groupsArray = [[self fetchedResultsController] fetchedObjects];
	
	self.groupsDictionary = nil;
	self.groupsDictionary = [NSMutableDictionary dictionary];
	
	for (Group *aGroup in groupsArray) {
		[self.groupsDictionary setObject:aGroup forKey:aGroup.title];
	}
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
        
        // Take last digit in array and use for color selection
        int lastDigit = [digits count] - 1;
        int overCount = [[digits objectAtIndex:lastDigit] intValue];
        color = [colorsArray objectAtIndex:overCount];
    }
    
	return color;
}

- (void)fillColors {
	if (self.colorsDictionary == nil) {
		self.colorsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.groupsDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
			UIColor *color = [self UIColorForIndex:index];
			[self.colorsDictionary setObject:color forKey:groupTitle];
			index++;
		}
	}
    
    // NSLog(@"colorDict: %@", ledgendColorsDictionary);
}

-(UIImage *)UIImageForIndex:(NSInteger)index {
	NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Symbol_Clover.png"], [UIImage imageNamed:@"Symbol_Club.png"], [UIImage imageNamed:@"Symbol_Cross.png"], [UIImage imageNamed:@"Symbol_Davidstar.png"], [UIImage imageNamed:@"Symbol_Diamondclassic.png"], [UIImage imageNamed:@"Symbol_Diamondring.png"], [UIImage imageNamed:@"Symbol_Doublehook.png"], [UIImage imageNamed:@"Symbol_Fivestar.png"], [UIImage imageNamed:@"Symbol_Heart.png"], [UIImage imageNamed:@"Symbol_Triangle.png"], [UIImage imageNamed:@"Symbol_Circle.png"], [UIImage imageNamed:@"Symbol_Hourglass.png"], [UIImage imageNamed:@"Symbol_Moon.png"], [UIImage imageNamed:@"Symbol_Skew.png"], [UIImage imageNamed:@"Symbol_Pentagon.png"], [UIImage imageNamed:@"Symbol_Spade.png"], nil];
	
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

- (void)fillSymbols
{
	if (self.symbolsDictionary == nil) {
		self.symbolsDictionary = [NSMutableDictionary dictionary];
		
		NSArray *objects = [self.groupsDictionary allKeys];
		NSInteger index = 0;
		
		for (NSString *groupTitle in objects) {
            
			UIImage *image = [self UIImageForIndex:index];
            
			[self.symbolsDictionary setObject:image forKey:groupTitle];
			index++;
		}
	}    
    // NSLog(@"symbolsDictionary: %@", symbolsDictionary);
}



- (void)addSwitchForGroup:(Group *)group {
	UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	aSwitch.on = [group.visible boolValue];
	[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged]; 
	[self.switchDictionary setObject:aSwitch forKey:group.title];
	[aSwitch release];
}


#pragma mark Picker Actions

// Called from ColorPicker
- (void)refreshTable
{
    [_tableView reloadData];
}

- (void)openPicker:(UIColor *)withColor;
{
    //UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    //  NSLog(@"Tag = %d", gesture.view.tag);
    
    
    HRColorPickerViewController* controller;
    controller = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:withColor];
    controller.groupName = editGroupName;
    controller.subName = @"";
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[self editSymbol];
    UIButton *tButton = sender;
    editGroupName = tButton.titleLabel.text;
    
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    NSData *data = [tColorDict objectForKey:editGroupName];
    // the color
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self openPicker:color];
    
}

- (void)editColor
{
    pickerView.hidden = NO;
    colorPicker.hidden = NO;
    symbolPicker.hidden = YES;  
    editWhat = 0;
    
    // NavBar Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
}

- (void)cancelEdit
{
    pickerView.hidden = YES;
    colorPicker.hidden = YES;
    symbolPicker.hidden = YES;  
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)editSymbol
{
    pickerView.hidden = NO;
    colorPicker.hidden = YES;
    symbolPicker.hidden = NO;    
    editWhat = 1;
    
    // NavBar Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
}

- (IBAction)doneClick:(id)sender
{
    pickerView.hidden = YES;
    
    int tag = [sender tag];
    
    
    
    
    // Process changes
    // Fetch saved user symbols/colors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *tSymbolDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSMutableDictionary *tColorDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    if (editWhat == 1) 
    {
        // the image
        [tSymbolDict setValue:[NSString stringWithFormat:@"%i", tag] forKey:editGroupName];
        [defaults setObject:tSymbolDict forKey:@"LEGEND_SYMBOL_DICTIONARY"];
    }
    else 
    {
        // the color
        [tColorDict setValue:[NSString stringWithFormat:@"%i", tag] forKey:editGroupName];
        [defaults setObject:tColorDict forKey:@"LEGEND_COLOR_DICTIONARY"]; 
    }
    
    // Refresh tableview
    
    [self._tableView reloadData];
    self.navigationItem.rightBarButtonItem = nil;
    //  NSLog(@"button tag: %i", tag);
    
}

#pragma mark orientation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
    // NSLog(@"sections: %i", numberOfSections);
    
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRows = [sectionInfo numberOfObjects];
    
	return numberOfRows;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	NSArray *sections = [[self fetchedResultsController] sections];
	NSString *sectionName = [[sections objectAtIndex:section] name];
	return sectionName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"indexpath");
    
    //static NSString *CellIdentifier = @"Cell";
    
    // Perm fix for tableview WEIRD Bug from v2.0; 5/15/2012 Mel Manzano
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d, %d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}   

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
	Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	cell.textLabel.text = group.title;
	if (group.visible == NO) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
	}
    
    
    // Fetch saved user symbols/colors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    // the image
    UIImage *image = [self UIImageForIndex:[[tSymbolDict objectForKey:group.title] intValue]];
    // the color
    NSData *data = [tColorDict objectForKey:group.title];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (data != nil) 
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(200, 20, 43, 43);
        [button setBackgroundImage:[self imageNamed:image withColor:color] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.text = group.title;
        button.titleLabel.hidden = YES;
        cell.accessoryView = button;
    }

    
    //cell.textLabel.textColor = color;
    
    
    cell.backgroundColor = [UIColor whiteColor];
	cell.accessoryView.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.backgroundView.backgroundColor = [UIColor clearColor];
    //cell.imageView.image = [UIImage imageNamed:@"check.png"];
    //NSLog(@"cells made");
}

- (void)popToGroups
{
    NSLog(@"pop");
    NSArray *buh = self.navigationController.viewControllers;
    NSMutableArray *VCs = [NSMutableArray arrayWithArray:buh];
    
    NSLog(@"buh:%@", buh);
    for (int i = buh.count-1; i > 1; i--) 
    {
        [VCs removeObjectAtIndex:i];
    }
    self.navigationController.viewControllers = VCs;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (UIImage *)imageNamed:(UIImage *)name withColor:(UIColor *)color
{
    // Load the image
    // NSString *name = @"Symbol_Clover.png";
    UIImage *img = name;
    
    // Begin new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // Get reference to context created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the fill color
    [color setFill];
    
    // Translate/flip graphics context
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set the blend mode to colorburn, and the original image
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    // Generate a new UIImage from the graphics context we draw onto
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return coloredImage;
}


#pragma mark group methods


-(void)switchFlipped:(id)sender {
	NSEnumerator *enumerator = [self.switchDictionary keyEnumerator];
	id key;
	
	UISwitch *currentValue;
	NSString *switchTitle = @"";
	while ((key = [enumerator nextObject])) {
		currentValue = [self.switchDictionary objectForKey:key];
		if (currentValue == sender) {
			switchTitle = key;
			Group *aGroup = [self.groupsDictionary objectForKey:switchTitle];
            
			UISwitch *theSwitch = (UISwitch *)currentValue;
			BOOL isOn = theSwitch.on;
            
			if ([self numberSwitchesOn] > 0) {
				NSNumber *isOnNumber = [NSNumber numberWithBool:isOn];
				aGroup.visible = isOnNumber;
				NSString *flurryKey = EVENT_GROUP_ACTIVATED;
				if (aGroup.visible ==  NO) {
					flurryKey = EVENT_GROUP_DEACTIVATED;
				}
				NSDictionary *usrDict = [NSDictionary dictionaryWithObjectsAndKeys:aGroup.title,flurryKey, nil];
				[FlurryUtility report:flurryKey withData:usrDict];
				
				NSError *error = nil;
				if (![self.managedObjectContext save:&error]) {
					[Error showErrorByAppendingString:@"Unable to save Category edits." withError:error];
				}
				break;
			}
			else {
				theSwitch.on = YES;
				NSString *titleString = [NSString stringWithFormat:@"Minimum Categories"];
				UIAlertView *immutableAlert = [[UIAlertView alloc]initWithTitle:titleString message:@"You must have at least one Category on." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[immutableAlert show];
				[immutableAlert release];
			}			
		}
	}	
}

- (NSInteger) numberSwitchesOn {
	NSInteger numberOn = 0;
	
	for (NSString *switchTitle in self.switchDictionary) {
		UISwitch *currentSwitch = [self.switchDictionary objectForKey:switchTitle];
		if (currentSwitch.on == YES) {
			numberOn++;
		}
	}
	
	return numberOn;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
	Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	//[self editColor];
    editGroupName = group.title;
	editWhat = 0;
    
    // Slide into Sliders
    SChartOptionsViewController *sChartOptionsViewController = [[SChartOptionsViewController alloc] initWithNibName:@"SChartOptionsViewController" bundle:nil];
    sChartOptionsViewController.groupName = editGroupName;
    [self.navigationController pushViewController:sChartOptionsViewController animated:YES];
    
    [sChartOptionsViewController release];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	
	// Create and configure a fetch request with the Group entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sectionTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    //	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSSortDescriptor *menuIndexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuIndex" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionTitleDescriptor, menuIndexDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	NSString *showGraphPredicateString = [NSString stringWithFormat:@"rateable = YES"];
	NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
    [NSFetchedResultsController deleteCacheWithName:nil]; 
	[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:
									 managedObjectContext sectionNameKeyPath:nil cacheName:@"Groups"];
	fetchedResultsController.safeDelegate = self;
	
	[sectionTitleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch data for groups." withError:error];
	}
    
	return fetchedResultsController;
}    

#pragma mark Memory management

- (void)dealloc {
	// Not sure why I have to explicitly set the delegate to nil, but if I don'tthe delegate will 
	// persist even after the View Controller has been deallocated.
	//[_tableView release];
	self.fetchedResultsController.delegate = nil;
	//[fetchedResultsController release];
	[managedObjectContext release];
	[switchDictionary release];
	[groupsDictionary release];
	
    [super dealloc];
}

@end