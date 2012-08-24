//
//  EditScaleViewController.m
//  VAS002
//
//  Created by Hasan Edain on 2/17/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import "EditScaleViewController.h"
#import "Scale.h"
#import "FlurryUtility.h"
#import "VASAnalytics.h"
#import "VAS002AppDelegate.h"
#import "Error.h"

@implementation EditScaleViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize switchDictionary;
@synthesize groupsDictionary;
@synthesize tableView;

@synthesize leftTextField;
@synthesize rightTextField;
@synthesize scale, groupName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIApplication *app = [UIApplication sharedApplication];
	VAS002AppDelegate *appDelegate = (VAS002AppDelegate*)[app delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;	
	
	self.title = [NSString stringWithFormat:@"Edit Scale"];
	self.leftTextField.text = self.scale.minLabel;
	self.rightTextField.text = self.scale.maxLabel;
	[FlurryUtility report:EVENT_ADD_EDIT_SCALE_ACTIVITY];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];	
    
}

- (void)viewDidUnload
{
	self.fetchedResultsController.delegate = nil;
}

- (void)save:(id)sender {
    [self addLegendInfo];
    
    
	self.scale.minLabel = self.leftTextField.text;
	self.scale.maxLabel = self.rightTextField.text;
    
    
	NSError *error = nil;
	
	if ([self.managedObjectContext hasChanges] ) {
		if(![self.managedObjectContext save:&error]) {
			[Error showErrorByAppendingString:@"Unable to save scale edit." withError:error];
		}
	}
    
    
	
	[self.navigationController popViewControllerAnimated:YES];	
}

-(void) addLegendInfo
{
    // Add Color and Symbol
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *colorSubDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_COLOR_DICTIONARY"]];
    NSMutableDictionary *symbolSubDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"]];
    
    NSLog(@"self.groupName: %@",self.groupName);
    NSMutableDictionary *subColorDict = [NSMutableDictionary dictionaryWithDictionary:[colorSubDict objectForKey:self.groupName]];
    NSMutableDictionary *subSymbolDict = [NSMutableDictionary dictionaryWithDictionary:[symbolSubDict objectForKey:self.groupName]];
    
    
    int randomColor = arc4random_uniform(9);
    int randomSymbol = arc4random_uniform(15);
    UIColor *newGroupColor = [self UIColorForIndex:randomColor];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newGroupColor];
    
    
    [subColorDict setObject:data forKey:self.leftTextField.text];
    [subSymbolDict setObject:[NSString stringWithFormat:@"%i",randomSymbol] forKey:self.leftTextField.text];
    
    
    [colorSubDict setObject:subColorDict forKey:self.groupName];
    [symbolSubDict setObject:subSymbolDict forKey:self.groupName];
    
    [defaults setValue:[NSDictionary dictionaryWithDictionary:colorSubDict] forKey:@"LEGEND_SUB_COLOR_DICTIONARY"];
    [defaults setValue:[NSDictionary dictionaryWithDictionary:symbolSubDict] forKey:@"LEGEND_SUB_SYMBOL_DICTIONARY"];
    
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


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark Text Editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == leftTextField) {
		[leftTextField resignFirstResponder];
		[rightTextField becomeFirstResponder];
		self.scale.minLabel = leftTextField.text;
	}
	
	if (textField == rightTextField) {
		[rightTextField resignFirstResponder];
		self.scale.maxLabel = rightTextField.text;
	}
	
	NSError *error = nil;
    
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		[Error showErrorByAppendingString:@"Unable to save Category edit." withError:error];
	}
	
	return YES;	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	BOOL shouldChangeText = YES;
	
	NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	NSCharacterSet *punctuation = [NSCharacterSet punctuationCharacterSet];
	
	NSString *trimmedReplacement = [string stringByTrimmingCharactersInSet:charactersToRemove ];
	
	trimmedReplacement = [trimmedReplacement stringByTrimmingCharactersInSet:punctuation];
	
	if (![trimmedReplacement isEqual:string]) {
		shouldChangeText = NO;
	}
	
	return shouldChangeText;
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		// Configure the cell...
		[self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    Scale *aScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (![aScale.minLabel isEqual:@""] && ![aScale.maxLabel isEqual:@""]) 
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", aScale.minLabel, aScale.maxLabel];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.alpha = 1.0f;
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
}

#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (SafeFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	
	// Create and configure a fetch request with the Category entity.
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scale" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *indexDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:indexDescriptor, nil] autorelease];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	//Create predicate
	//NSString *showGraphPredicateString = [NSString stringWithFormat:@"group.title like '%@'",self.group.title];
	//NSPredicate *showGraphPredicate = [NSPredicate predicateWithFormat:showGraphPredicateString];
	
    //[NSFetchedResultsController deleteCacheWithName:nil]; 
	//[fetchRequest setPredicate:showGraphPredicate];
	
	// Create and initialize the fetch results controller.
	self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"GetScales"];
	fetchedResultsController.safeDelegate = self;
    
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[Error showErrorByAppendingString:@"Unable to load Category data" withError:error];
	}
	return 
    fetchedResultsController;
}    

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}	
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	if (!self.tableView.editing) {
		[self.tableView reloadData];
	}
	
	[self.tableView endUpdates];
}

#pragma mark Memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)dealloc {
	[self.managedObjectContext release];
	
	[self.leftTextField release];
	[self.rightTextField release];
	[self.scale release], self.scale = nil;
	self.fetchedResultsController.delegate = nil;
	[self.fetchedResultsController release];
    
    [super dealloc];
}


@end
