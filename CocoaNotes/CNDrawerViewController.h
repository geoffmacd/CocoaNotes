//
//  CNDrawerViewController.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2014-02-28.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

@protocol DrawerDelegate <NSObject>

-(void)selectedTag:(NSManagedObjectID*)tagId;

@end

@interface CNDrawerViewController : UITableViewController

@property (nonatomic) NSArray * tagArray;

@property (weak) id<DrawerDelegate> delegate;

@end
