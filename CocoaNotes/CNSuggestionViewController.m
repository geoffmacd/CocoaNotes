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
        _order = [NSMutableArray new];
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
    return [_dict count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * key = _order[section];
    
    return [_dict[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString * key = _order[[indexPath section]];
    NSArray * array = _dict[key];
    NSString * word = array[[indexPath row]];
    [cell.textLabel setText:word];
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * key = _order[[indexPath section]];
    NSArray * array = _dict[key];
    NSString * word = array[[indexPath row]];
    [self.delegate didSelectWord:word];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString * key = _order[section];
    return key;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}


-(void)setDict:(NSDictionary *)dict{
    
    _dict = dict;
    
    [_order removeAllObjects];
    
    if(_dict[kClasses])
        [_order addObject:kClasses];
    if(_dict[kMethods])
        [_order addObject:kMethods];
    
    
    [self.tableView reloadData];
}

@end
