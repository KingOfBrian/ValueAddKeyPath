//
//  SecondViewController.h
//  ValueAddComponentTest
//
//  Created by Brian King on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UITableViewController

@property (nonatomic, retain) IBOutlet UISegmentedControl *control;
@property (nonatomic, retain) IBOutlet UIButton *button;

- (IBAction)textFieldAction:(id)sender;
- (IBAction)switchAction:(id)sender;
- (IBAction)buttonAction:(id)sender;
- (IBAction)segmentAction:(id)sender;
- (IBAction)sliderAction:(id)sender;

@end
