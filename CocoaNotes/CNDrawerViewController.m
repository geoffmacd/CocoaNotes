//
//  CNDrawerViewController.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2014-02-28.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNDrawerViewController.h"
#import "Tag.h"

@implementation CNDrawerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tagArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSInteger index = [indexPath row];
    if(index > 0){
        index--;
        Tag * curTag = [_tagArray objectAtIndex:index];
        [cell.textLabel setText:curTag.name];
    } else {
        NSAttributedString * attr  = [[NSAttributedString alloc] initWithString:@"All" attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}];
        [cell.textLabel setAttributedText:attr];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Tags";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath row];
    if(index > 0){
        index--;
        Tag * curTag = _tagArray[index];
        
        NSManagedObjectID * objId = [curTag objectID];
        
        
        [self.delegate selectedTag:objId];
    } else {
        [self.delegate selectedTag:nil];
    }
}


@end
