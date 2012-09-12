//
//  EditGroupViewController.h
//  VAS002
//
//  Created by Hasan Edain on 1/14/11.
//  Copyright 2011 GDIT. All rights reserved.
//

#import <CoreData/CoreData.h>
@class Group;
@class Scale;

@interface EditGroupViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>{	
	NSManagedObjectContext *managedObjectContext;
	UITextField *groupTextField;
	IBOutlet UIButton *deleteGroup;
	IBOutlet UIButton *manageScalesButton;
	IBOutlet UISwitch *isPositveSwitch;
    IBOutlet UILabel *positiveLabel;
    IBOutlet UITableView *tableView;

    NSMutableArray *filterViewItems;
    NSArray *topFieldArray;
    NSMutableDictionary *scalesDictionary;
    NSArray *scalesArray;
    NSArray *allScalesArray;

    
    
    IBOutlet UIView *manageScaleView;
    IBOutlet UIView *manageScaleView_landscape;
    IBOutlet UIPickerView *scalePicker_landscape;
    IBOutlet UIPickerView *scalePicker;
    IBOutlet UITextField *minTextField;
    IBOutlet UITextField *maxTextField;
    IBOutlet UITextField *minTextField_landscape;
    IBOutlet UITextField *maxTextField_landscape;
    NSArray *pickerArray;
    
    

    
    Scale *scale;
	Group *group;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Scale *scale;

@property (nonatomic, retain) IBOutlet UILabel *positiveLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *filterViewItems;
@property (nonatomic, retain) NSArray *topFieldArray;
@property (nonatomic, retain) NSMutableDictionary *scalesDictionary;
@property (nonatomic, retain) NSArray *scalesArray;
@property (nonatomic, retain) NSArray *allScalesArray;
@property (nonatomic, retain) IBOutlet UIView *manageScaleView_landscape;

@property (nonatomic, retain) IBOutlet UIView *manageScaleView;
@property (nonatomic, retain) IBOutlet UIPickerView *scalePicker;
@property (nonatomic, retain) IBOutlet UIPickerView *scalePicker_landscape;

@property (nonatomic, retain) IBOutlet UITextField *minTextField;
@property (nonatomic, retain) IBOutlet UITextField *maxTextField;
@property (nonatomic, retain) IBOutlet UITextField *minTextField_landscape;
@property (nonatomic, retain) IBOutlet UITextField *maxTextField_landscape;
@property (nonatomic, retain) NSArray *pickerArray;




- (IBAction)deleteGroupPressed:(id)sender;
- (IBAction)manageScalesPressed:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)saveAction:(id)sender;
- (void)addGroup;
- (void)addLegendInfo;

- (void)saveEdit;
- (void)reloadAfterCreate;
- (void)addScale;
- (void)showManager;
- (void)resignManager;
- (void)saveScale;
- (void)slideDownDidStop;

- (NSNumber *)getNextMenuIndex;
- (IBAction)switchFlipped:(id)sender;
- (void) makePositive;
- (void) makeNegative;
- (void)fillScalesArray;

- (void)fillValues;


@end
