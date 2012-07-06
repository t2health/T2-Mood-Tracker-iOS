//
//  SymbolViewController.h
//  VAS002
//
//  Created by Melvin Manzano on 6/12/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface SymbolViewController : UIViewController
{
    NSString *groupName;   
    NSString *subName;
    BOOL _isSub;
    IBOutlet UIImageView *bigSymbol;
    NSMutableDictionary *symbolsDictionary;
    
}

@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) IBOutlet UIImageView *bigSymbol;
@property (nonatomic, retain) NSMutableDictionary *symbolsDictionary;
@property (nonatomic, retain) NSString *subName;



- (void)done;
- (void)deviceOrientationChanged:(NSNotification *)notification; 
- (IBAction)doneClick:(id)sender;

@end
