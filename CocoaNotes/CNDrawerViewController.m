//
//  CNDrawerViewController.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2014-02-28.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNDrawerViewController.h"
#import "Tag.h"

@interface CNDrawerViewController ()

@end

@implementation CNDrawerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setTagArray:(NSArray *)tagArray{
    _tagArray = tagArray;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;//[_tagArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
//    Tag * curTag = _tagArray[[indexPath row]];
    
    [cell.textLabel setText:@"Geoff"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    Tag * curTag = _tagArray[[indexPath row]];
    
    [self.delegate selectedTag:nil];
}


@end
