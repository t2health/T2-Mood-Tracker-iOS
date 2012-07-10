//
//  OptionsTableViewController.m
//  VAS002
//
//  Created by Melvin Manzano on 7/9/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "Error.h"
#import "VAS002AppDelegate.h"
#import "GraphViewController.h"
#import "ChartOptionsViewController.h"


@implementation OptionsTableViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize dataSourceArray, myNavController;
@synthesize legendSwitch, symbolSwitch, gradientSwitch;

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
	VAS002AppDelegate *appDeleate = (VAS002AppDelegate *)[app delegate];
	self.managedObjectContext = appDeleate.managedObjectContext;
    
    self.dataSourceArray = [NSArray arrayWithObjects:@"Legend", @"Symbols", @"Gradient", @"Edit Colors/Symbols", @"Data Range", nil];
    
    
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


#pragma mark Set Options

- (void)legendToggle
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;

    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
    BOOL val = legendSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    NSLog(@"Toggle Legend: %i", val);
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleLegend" object: nil];
    
}

- (void)symbolToggle
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
    
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_SYMBOL"];
    BOOL val = symbolSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    NSLog(@"Toggle Symbol: %i", val);
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleSymbol" object: nil];

}

- (void)gradientToggle
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultsKey;
    
    defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_GRADIENT"];
    BOOL val = gradientSwitch.on;
    [defaults setBool:val forKey:defaultsKey];
    [defaults synchronize];
    NSLog(@"Toggle Gradient: %i", val);
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleGradient" object: nil];

}

#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSourceArray count];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
	// Configure the cell to show the Categories title
    NSInteger row = [indexPath indexAtPosition:1];
    
    // Fetch User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL storedVal;
    NSString *key;
	
    // Create controls
    NSString *cellName = @"";
    
    // Legend
    if (row == 0) 
    {
        cellName = [dataSourceArray objectAtIndex:row];
        
        UISwitch *aSwitch = [[UISwitch alloc] init];
        
        // Fetch User Defaults for Legend
        key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_LEGEND"];
        if (![defaults boolForKey:key]) {
            storedVal = NO;
        }
        else 
        {
            storedVal = [defaults boolForKey:key];	
        }
        aSwitch.on = storedVal;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
        [aSwitch addTarget:self action:@selector(legendToggle) forControlEvents:UIControlEventValueChanged];
        legendSwitch = aSwitch;
        cell.accessoryView = aSwitch;
        [aSwitch release];
    }
    // Symbol
    else if (row == 1) 
    {
        cellName = [dataSourceArray objectAtIndex:row];

        UISwitch *aSwitch = [[UISwitch alloc] init];
        // Fetch User Defaults for Symbol
        key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_SYMBOL"];
        if (![defaults objectForKey:key]) {
            storedVal = NO;
        }
        else {
            storedVal = [defaults boolForKey:key];				
        }
        NSLog(@"config: symbol: %i", storedVal);
        aSwitch.on = NO;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
        [aSwitch addTarget:self action:@selector(symbolToggle) forControlEvents:UIControlEventValueChanged];
        symbolSwitch = aSwitch;

        cell.accessoryView = aSwitch;
        
        [aSwitch release];
    }
    // Gradient
    else if (row == 2) 
    {
        cellName = [dataSourceArray objectAtIndex:row];

        UISwitch *aSwitch = [[UISwitch alloc] init];
        // Fetch User Defaults for Legend
        key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_GRADIENT"];
        if (![defaults objectForKey:key]) {
            storedVal = NO;
        }
        else {
            storedVal = [defaults boolForKey:key];				
        }
        NSLog(@"config: gradient: %i", storedVal);

        aSwitch.on = NO;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
        [aSwitch addTarget:self action:@selector(gradientToggle) forControlEvents:UIControlEventValueChanged];
        gradientSwitch = aSwitch;
        
        cell.accessoryView = aSwitch;
        [aSwitch release];
    }
    // Customize
    else if (row == 3) 
    {
        cellName = [dataSourceArray objectAtIndex:row];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Data Range
    else if (row == 4) 
    {
        cellName = [dataSourceArray objectAtIndex:row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultsKey;
        
        defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_RANGE"];
        cell.detailTextLabel.text = [defaults objectForKey:defaultsKey];
    }

    
    cell.textLabel.text = cellName;
    /*
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = cellName;
    cell.detailTextLabel.text = cellDate;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.textAlignment  = UITextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    //cell.accessoryView.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    [cell setNeedsLayout];
     */
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
    
    NSInteger row = [indexPath indexAtPosition:1];

    // Customize
    if (row == 3) 
    {
        NSLog(@"chartoption clicked");
        
        ChartOptionsViewController *chartOptionsViewController = [[ChartOptionsViewController alloc] initWithNibName:@"ChartOptionsViewController" bundle:nil];

        [self.myNavController pushViewController:chartOptionsViewController animated:YES];
       
        [chartOptionsViewController release];    

    }
    
    // Date Range
    else if (row == 4) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showPicker" object: nil];
    }
     
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // The table view should not be re-orderable.
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


@end
