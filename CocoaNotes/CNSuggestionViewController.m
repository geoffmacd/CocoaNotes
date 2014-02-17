//
//  CNSuggestionViewViewController.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/16/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNSuggestionViewController.h"

@interface CNSuggestionViewController ()

@end

@implementation CNSuggestionViewController

static NSString *CellIdentifier = @"Cell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //list methods, classes, etc seperately
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:_list[[indexPath row]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * word = _list[[indexPath row]];
    [self.delegate didSelectWord:word];
}

-(void)setList:(NSArray *)list{
    
    _list = list;
    
    [self.tableView reloadData];
}

@end
