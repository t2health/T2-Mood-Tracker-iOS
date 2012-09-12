//
//  ChartOptionsViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 5/24/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

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


@implementation SChartOptionsViewController

@synthesize managedObjectContext;
@synthesize switchDictionary;
@synthesize _tableView, pickerView, userSettingsDictionary;
@synthesize colorPicker, symbolPicker , editGroupName;
@synthesize scalesDictionary;
@synthesize scalesArray, ledgendColorsDictionary, groupName;

int editWhat;

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.backgroundView = nil;
    
    // Default to color
    editWhat = 0;
	pickerView.hidden = YES;
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
    
	self.title = @"Customize Charting";

   //[self fillScalesDictionary];

	[FlurryUtility report:EVENT_EDIT_GROUP_ACTIVITY];
    
    // NavBar Button
    
    
}

- (void)viewWillAppear:(BOOL)animated {

   // NSLog(@"groupName: %@", self.groupName);
    [self fillScalesDictionary];
	//[_tableView reloadData];
}

- (void)viewDidUnload {
}



// Called from ColorPicker
- (void)refreshTable
{
    [_tableView reloadData];
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
    
    [self.navigationController popViewControllerAnimated:NO];
    
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




- (void)addSwitchForGroup:(Group *)group {
	UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	aSwitch.on = [group.visible boolValue];
	[aSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged]; 
	[self.switchDictionary setObject:aSwitch forKey:group.title];
	[aSwitch release];
}


#pragma mark Picker Actions

- (void)checkButtonTapped:(id)sender event:(id)event
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[self editSymbol];
    UIButton *tButton = sender;
    editGroupName = tButton.titleLabel.text;
    
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_COLOR_DICTIONARY"]];
    
    NSDictionary *colorDictionary = [tColorDict objectForKey:self.groupName];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button = sender;
    
    
    // the color
    NSData *data = [colorDictionary objectForKey:button.titleLabel.text];
    [button release];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    [self openPicker:color];
    
}

- (void)openPicker:(UIColor *)withColor;
{
    
    HRColorPickerViewController* controller;
    controller = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:withColor];
    controller.groupName = groupName;
    controller.subName = editGroupName;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:NO];
    
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

#pragma mark fill scales

- (void)fillScalesDictionary {
	if (self.scalesDictionary == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"group.title like %@",self.groupName];
		NSArray *predicateArray = [NSArray arrayWithObjects:groupPredicate, nil];
		NSPredicate *finalPredicate = [NSCompoundPredicate	andPredicateWithSubpredicates:predicateArray];
		[fetchRequest setPredicate:finalPredicate];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSMutableDictionary *scales = [NSMutableDictionary dictionary];
		NSError *error = nil;
		NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (!error) {
            
            
			for (Scale *aScale in objects) {
				[scales setObject:aScale forKey:aScale.minLabel];
			}
			self.scalesDictionary = [NSDictionary dictionaryWithDictionary:scales];
			
			NSArray *keys = [self.scalesDictionary allKeys];
			NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
			
			NSMutableArray *sclArray = [NSMutableArray array];
			for (NSString *minLabel in sortedKeys) {
                if ([minLabel isEqualToString:@""]) 
                {
                    
                }
                else 
                {
                    [sclArray addObject:[self.scalesDictionary objectForKey:minLabel]];
                    
                }
                
			}
			self.scalesArray = [NSArray arrayWithArray:sclArray];
            NSLog(@"scalesArray: '%@'",scalesArray);
            
		}
		else {
			[Error showErrorByAppendingString:@"Unable to fetch scale data" withError:error];
		}
		
		[fetchRequest release];
	}
    
}


#pragma mark orientation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
	NSInteger numberOfRows = [self.scalesArray count];
    
    
    
	return numberOfRows;
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"indexpath");
    
    //static NSString *CellIdentifier = @"Cell";
    
    // Perm fix for tableview WEIRD Bug from v2.0; 5/15/2012 Mel Manzano
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d, %d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}   

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
    
    
	NSInteger row = [indexPath indexAtPosition:1];
    NSLog(@"row: '%i'",row);
    
    
    
	Scale *scale = [self.scalesArray objectAtIndex:row];
	//NSString *gName = [NSString stringWithFormat:@"%@/%@", scale.minLabel, scale.maxLabel];
    if ([scale.minLabel isEqualToString:@""]) 
    {
        
    }
    else 
    {
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        
        NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"]];
        NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_COLOR_DICTIONARY"]];
        
        NSDictionary *symbolDictionary = [tSymbolDict objectForKey:self.groupName];
        NSDictionary *colorDictionary = [tColorDict objectForKey:self.groupName];
        
        
        
        // the image
        UIImage *image = [self UIImageForIndex:[[symbolDictionary objectForKey:scale.minLabel] intValue]];
        // the color
        NSData *data = [colorDictionary objectForKey:scale.minLabel];
        
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(200, 20, 43, 43);
        [button setBackgroundImage:[self imageNamed:image withColor:color] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.text = scale.minLabel;
        button.titleLabel.hidden = YES;
        cell.accessoryView = button;
        
        
        cell.textLabel.text = scale.minLabel;
        cell.textLabel.textColor = color;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        
        cell.detailTextLabel.text = scale.maxLabel;
        cell.detailTextLabel.textColor = color;
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.textLabel.textAlignment = UITextAlignmentRight;
    }
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



#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //	Group *group = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //	[self editColor];
    //   editGroupName = group.title;
    //	editWhat = 0;
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


#pragma mark Memory management

- (void)dealloc {
	// Not sure why I have to explicitly set the delegate to nil, but if I don'tthe delegate will 
	// persist even after the View Controller has been deallocated.
	//[_tableView release];
	[self.managedObjectContext release];
	[self.switchDictionary release];
	
    [super dealloc];
}

@end