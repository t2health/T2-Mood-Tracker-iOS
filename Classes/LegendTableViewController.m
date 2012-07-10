//
//  LegendTableViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 6/8/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "LegendTableViewController.h"
#import "Group.h"
#import "Error.h"
#import "VAS002AppDelegate.h"
#import "GraphViewController.h"

@implementation LegendTableViewController

@synthesize groupsArray, groupsDictionary;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
    [self fillGroupsDictionary];
    
    NSLog(@"groupsDictionary: %@", groupsDictionary);
}


- (void)refresh
{
    [self fillGroupsDictionary];
    [self.tableView reloadData];
    
    // Resize Legend Window

}


#pragma mark groups

- (void)fillGroupsDictionary {
    
	NSArray *groupArray = [[self fetchedResultsController] fetchedObjects];
	
	self.groupsDictionary = nil;
	self.groupsDictionary = [NSMutableDictionary dictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsKey = @"";
    BOOL val;
	for (Group *aGroup in groupArray) 
    {
        defaultsKey = [NSString stringWithFormat:@"SWITCH_STATE_%@",aGroup.title];
        
        if (![defaults objectForKey:defaultsKey]) 
        {
            val = YES;
        }
        else 
        {
            val = [defaults boolForKey:defaultsKey];				
        }
        
        //  NSLog(@"group: %@ - %i", aGroup.title, val);
        if (val) 
        {
            [self.groupsDictionary setObject:aGroup forKey:aGroup.title];
        }
	}
    
    NSArray *keys = [self.groupsDictionary allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *grpArray = [NSMutableArray array];
    for (NSString *groupName in sortedKeys) {
        [grpArray addObject:groupName];
    }
    self.groupsArray = [NSArray arrayWithArray:grpArray];
    // NSLog(@"groupsArray: %@", groupsArray);
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
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:
									 self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Groups"];
	self.fetchedResultsController.safeDelegate = self;
	
	[sectionTitleDescriptor autorelease];
	[menuIndexDescriptor autorelease];
	[sortDescriptors  autorelease];
	[fetchRequest autorelease];
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to fetch data for groups." withError:error];
	}
    
	return self.fetchedResultsController;
}    


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	//id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRows = [self.groupsDictionary count];
    
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath indexAtPosition:1];
    
    NSString *grpName = [groupsArray objectAtIndex:row];
    Group *group = [self.groupsDictionary objectForKey:grpName];
    
    // Fetch saved user symbols/colors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SYMBOL_DICTIONARY"]];
    NSDictionary *tColorDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_COLOR_DICTIONARY"]];
    
    
    // the image
    UIImage *image = [self UIImageForIndex:[[tSymbolDict objectForKey:group.title] intValue]];
    // the color
    NSData *data = [tColorDict objectForKey:group.title];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // Configure the cell...
	cell.textLabel.text = group.title;
    
    // cell.textLabel.text = groupName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.textLabel.textAlignment = UITextAlignmentRight;
    
    cell.imageView.image = [self imageNamed:image withColor:color];
    
    
    CGFloat widthScale = 32 / image.size.width;
    CGFloat heightScale = 32 / image.size.height;
    //this line will do it!
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);
    return cell;
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
