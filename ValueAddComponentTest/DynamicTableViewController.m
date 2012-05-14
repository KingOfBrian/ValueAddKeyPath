//
//  DynamicTableViewController.m
//  ValueAddKeyPath
//
//  Created by Brian King on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicTableViewController.h"

#import "CustomTestCell.h"

@interface DynamicTableViewController ()
@property (nonatomic, assign) NSUInteger identifierIndex;
@end

@implementation DynamicTableViewController

@synthesize identifierIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (NSString *)nextIdentifier
{
    static NSArray *CellIdentifiers = nil;
    if (CellIdentifiers == nil)
    {
        self.identifierIndex = 0;
        CellIdentifiers = [[NSArray alloc] initWithObjects:@"Cell1", @"Cell2", @"Cell3", @"Cell4", @"Cell5", nil];
    }
    else
        self.identifierIndex = self.identifierIndex + 1 < [CellIdentifiers count] ? self.identifierIndex  + 1 : 0;

    return [CellIdentifiers objectAtIndex:self.identifierIndex];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 500;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self nextIdentifier]];
    
    if ([cell isKindOfClass:[CustomTestCell class]])
    {
        CustomTestCell *ccell = (CustomTestCell *)cell;
        ccell.label1.text = [NSString stringWithFormat:@"1-%d", indexPath.row];
        ccell.label2.text = [NSString stringWithFormat:@"2-%d", indexPath.row];
        ccell.label3.text = [NSString stringWithFormat:@"3-%d", indexPath.row];
        ccell.label4.text = [NSString stringWithFormat:@"4-%d", indexPath.row];
        ccell.label5.text = [NSString stringWithFormat:@"5-%d", indexPath.row];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Text %d", indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Detail %d", indexPath.row];

    }
    
    return cell;
}

@end
