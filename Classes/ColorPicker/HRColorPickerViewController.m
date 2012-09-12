/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "HRColorPickerViewController.h"
#import "HRColorPickerView.h"

@implementation HRColorPickerViewController

@synthesize delegate, groupName,subName;


+ (HRColorPickerViewController *)colorPickerViewControllerWithColor:(UIColor *)color
{
    return [[[HRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAlways] autorelease];
}

+ (HRColorPickerViewController *)cancelableColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[[HRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAndCancel] autorelease];
}

+ (HRColorPickerViewController *)fullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[[HRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAlways] autorelease];
}

+ (HRColorPickerViewController *)cancelableFullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[[HRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAndCancel] autorelease];
}



- (id)initWithDefaultColor:(UIColor *)defaultColor
{
    return [self initWithColor:defaultColor fullColor:NO saveStyle:HCPCSaveStyleSaveAlways];
}

- (id)initWithColor:(UIColor*)defaultColor fullColor:(BOOL)fullColor saveStyle:(HCPCSaveStyle)saveStyle

{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = [defaultColor retain];
        _fullColor = fullColor;
        _saveStyle = saveStyle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select Color";
    NSLog(@"%@ - %@",groupName, subName);
    if ([subName isEqualToString:@""]) 
    {
        _isSub = NO;
    }
    else {
        _isSub = YES;
    }
    NSLog(@"isSub = %i",_isSub);
    
    HRRGBColor rgbColor;
    RGBColorFromUIColor(_color, &rgbColor);
    
    HRColorPickerStyle style;
    if (_fullColor) {
        style = [HRColorPickerView fullColorStyle];
    }else{
        style = [HRColorPickerView defaultStyle];
    }
    
    colorPickerView = [[HRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];
    
    [self.view addSubview:colorPickerView];
    
    // Orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    if (_saveStyle == HCPCSaveStyleSaveAndCancel) {
        UIBarButtonItem *buttonItem;
        
        buttonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        self.navigationItem.leftBarButtonItem = buttonItem;
        
        buttonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(save:)] autorelease];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)deviceOrientationChanged:(NSNotification *)notification 
{
    /*
     [colorPickerView removeFromSuperview];
     HRRGBColor rgbColor;
     RGBColorFromUIColor(_color, &rgbColor);
     
     HRColorPickerStyle style;
     if (_fullColor) {
     style = [HRColorPickerView fullColorStyle];
     }else{
     style = [HRColorPickerView defaultStyle];
     }
     
     colorPickerView = [[HRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];
     
     [self.view addSubview:colorPickerView];
     */
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_saveStyle == HCPCSaveStyleSaveAlways) {
        [self save:self];
    }
}

- (void)saveColor:(id)sender{
    [self save];
}

- (void)save
{
    if (self.delegate) {
        //    HRRGBColor rgbColor = [colorPickerView RGBColor];
        // [self.delegate refreshTable];
    }
    //[self.navigationController popViewControllerAnimated:YES];
    NSString *dictName = @"LEGEND_COLOR_DICTIONARY";
    
    if (_isSub) 
    {
        dictName = @"LEGEND_SUB_COLOR_DICTIONARY";
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *tColorDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:dictName]];
    
    // the color
    HRRGBColor rgbColor = [colorPickerView RGBColor];
    UIColor *color = [UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:color];
    
    if (_isSub) 
    {
        NSMutableDictionary *tSubColorDict = [NSMutableDictionary dictionaryWithDictionary:[tColorDict objectForKey:groupName]];
        
        [tSubColorDict setObject:data forKey:subName];
        [tColorDict setObject:tSubColorDict forKey:groupName];
    }
    else 
    {
        [tColorDict setObject:data forKey:groupName];
    }
    
    [defaults setObject:tColorDict forKey:dictName]; 
    
    SymbolViewController *symbolViewController = [[SymbolViewController alloc] initWithNibName:@"SymbolViewController" bundle:nil];
    
    symbolViewController.groupName = groupName;
    
    if (_isSub) 
    {
        symbolViewController.subName = subName;
    }
    else    
    {
        symbolViewController.subName = @"";
        
    }
    [self.navigationController pushViewController:symbolViewController animated:YES];
}

- (void)save:(id)sender
{
    [self save];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc{
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // deallocでループを止めることができないので、BeforeDeallocを呼び出して下さい
    //
    /////////////////////////////////////////////////////////////////////////////
    
    [colorPickerView BeforeDealloc];
    [colorPickerView release];
    [_color release];
    [super dealloc];
}

@end
