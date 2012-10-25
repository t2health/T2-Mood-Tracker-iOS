/*
 *
 * T2 Mood Tracker
 *
 * Copyright © 2009-2012 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright © 2009-2012 Contributors. All Rights Reserved.
 *
 * THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
 * REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
 * COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
 * AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
 * THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
 * INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
 * REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
 * DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
 * HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
 * RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: T2MoodTracker002
 * Government Agency Original Software Title: T2 Mood Tracker
 * User Registration Requested. Please send email
 * with your contact information to: robert.kayl2@us.army.mil
 * Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
 *
 */

#import "SymbolViewController.h"

@interface SymbolViewController ()

@end

@implementation SymbolViewController

@synthesize groupName, bigSymbol, symbolsDictionary, subName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([subName isEqualToString:@""]) 
    {
        _isSub = NO;
    }
    else {
        _isSub = YES;
    }
    
    NSLog(@"groupName: %@", groupName);
    
    NSString *dictName = @"LEGEND_SYMBOL_DICTIONARY";
    
    if (_isSub) 
    {
        dictName = @"LEGEND_SUB_SYMBOL_DICTIONARY";
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tSymbolDict = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:dictName]];
    UIImage *image;
    
    if (_isSub) 
    {
        NSDictionary *tSubSymbolDict = [NSDictionary dictionaryWithDictionary:[tSymbolDict objectForKey:subName]];
        image = [self UIImageForIndex:[[tSubSymbolDict objectForKey:subName] intValue]];
        
        
    }
    else 
    {
        image = [self UIImageForIndex:[[tSymbolDict objectForKey:groupName] intValue]];
    }
    
    // the image
    bigSymbol.image = image;
    
    // NavBar Button
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done)];
    
    self.navigationItem.rightBarButtonItem = actionButton;
    
    [actionButton release];
}

- (void)done
{
    //int count = [self.navigationController.viewControllers count];
    // [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-2]];
    NSLog(@"gufaw");
    NSArray *buh = self.navigationController.viewControllers;
    NSMutableArray *VCs = [NSMutableArray arrayWithArray:buh];
    [VCs removeObjectAtIndex:[VCs count] - 2];
    self.navigationController.viewControllers = VCs;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    UIDevice *device = [UIDevice currentDevice];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //iPad
        if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight)
        {
            NSLog(@"ipad land");
            
        }
        else 
        {
            NSLog(@"ipad portrait");
            
        }
        
    } 
    else 
    {
        //iPhone
        if (device.orientation == UIDeviceOrientationPortrait || device.orientation == UIDeviceOrientationPortraitUpsideDown) 
        {
            NSLog(@"iphone portrait");
            
        }
        else if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight)
        {
            NSLog(@"iphone land");
            
        }
        
    }    
}

- (IBAction)doneClick:(id)sender
{
    
    int tag = [sender tag];
    
    // Process changes
    // Fetch saved user symbols/colors
    
    NSString *dictName = @"LEGEND_SYMBOL_DICTIONARY";
    
    if (_isSub) 
    {
        dictName = @"LEGEND_SUB_SYMBOL_DICTIONARY";
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *tSymbolDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:dictName]];
    
    
    if (_isSub) 
    {
        NSLog(@"sub");
        NSMutableDictionary *tSubSymbolDict = [NSMutableDictionary dictionaryWithDictionary:[tSymbolDict objectForKey:groupName]];
        
        [tSubSymbolDict setObject:[NSString stringWithFormat:@"%i", tag] forKey:subName];
        [tSymbolDict setObject:tSubSymbolDict forKey:groupName];
    }
    else 
    {
        NSLog(@"nosub");
        
        [tSymbolDict setValue:[NSString stringWithFormat:@"%i", tag] forKey:groupName];
    }
    
    
    [defaults setObject:tSymbolDict forKey:dictName];
    
    UIImage *theImage = [self UIImageForIndex:tag];
    bigSymbol.image = theImage;
    //  NSLog(@"button tag: %i", tag);
    
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
