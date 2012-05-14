//
//  SecondViewController.m
//  ValueAddComponentTest
//
//  Created by Brian King on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "DynamicTableViewController.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize control;
@synthesize button;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.button = nil;
    self.control = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DynamicTableViewController"];

    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark UIActions
- (IBAction)textFieldAction:(id)sender
{
}

- (IBAction)switchAction:(id)sender
{
}

- (IBAction)buttonAction:(id)sender
{
    if (self.control.selectedSegmentIndex == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Alert Title" message:@"Testing" 
                                   delegate:nil cancelButtonTitle:@"OK" 
                          otherButtonTitles:@"One", @"Two", nil] show];
    }
    else
    {
        [[[UIActionSheet alloc] initWithTitle:@"Action Sheet" delegate:nil 
                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Destroy" 
                            otherButtonTitles:@"One", @"Two", nil] showInView:self.view];
    }
}

- (IBAction)segmentAction:(id)sender
{
}

- (IBAction)sliderAction:(id)sender
{
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
