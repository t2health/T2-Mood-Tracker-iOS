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

@synthesize managedObjectContext, whichGraph;
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
    
    self.dataSourceArray = [NSArray arrayWithObjects: @"Symbols", @"Gradient", @"Edit Colors/Symbols", @"Data Range", nil];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"SWITCH_OPTION_STATE_SYMBOL"];
    [defaults setBool:NO forKey:@"SWITCH_OPTION_STATE_GRADIENT"];

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
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"toggleSymbol_%@", whichGraph] object: nil];
    
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
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"toggleGradient_%@", whichGraph] object: nil];
    
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
    
    // Symbol
    if (row == 0) 
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
        aSwitch.on = storedVal;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
        [aSwitch addTarget:self action:@selector(symbolToggle) forControlEvents:UIControlEventValueChanged];
        symbolSwitch = aSwitch;
        
        cell.accessoryView = aSwitch;
        
        [aSwitch release];
    }
    // Gradient
    else if (row == 1) 
    {
        cellName = [dataSourceArray objectAtIndex:row];
        
        UISwitch *aSwitch = [[UISwitch alloc] init];
        // Fetch User Defaults for Legend
        key = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_GRADIENT"];
        if (![defaults objectForKey:key]) {
            storedVal = NO;
        }
        else 
        {
            storedVal = [defaults boolForKey:key];				
        }
        NSLog(@"config: gradient: %i", storedVal);
        
        aSwitch.on = storedVal;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleBottomMargin; 
        [aSwitch addTarget:self action:@selector(gradientToggle) forControlEvents:UIControlEventValueChanged];
        gradientSwitch = aSwitch;
        
        cell.accessoryView = aSwitch;
        [aSwitch release];
    }
    // Customize
    else if (row == 2) 
    {
        cellName = [dataSourceArray objectAtIndex:row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Data Range
    else if (row == 3) 
    {
        cellName = [dataSourceArray objectAtIndex:row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultsKey;
        
        defaultsKey = [NSString stringWithFormat:@"SWITCH_OPTION_STATE_RANGE"];
        NSString *rangeString = [defaults objectForKey:defaultsKey];
        if (rangeString==nil) 
        {
            cell.detailTextLabel.text = @"30 days";
        }
        else 
        {
            cell.detailTextLabel.text = [defaults objectForKey:defaultsKey];
            
        }
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
    if (row == 2) 
    {
        NSLog(@"chartoption clicked");
        
        ChartOptionsViewController *chartOptionsViewController = [[ChartOptionsViewController alloc] initWithNibName:@"ChartOptionsViewController" bundle:nil];
        
        [self.myNavController pushViewController:chartOptionsViewController animated:YES];
        
        [chartOptionsViewController release];    
        
    }
    
    // Date Range
    else if (row == 3) 
    {
        NSString *notifyName = [NSString stringWithFormat:@"showPicker_%@", whichGraph];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object: nil];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // The table view should not be re-orderable.
    return NO;
}



@end
