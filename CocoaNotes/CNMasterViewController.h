//
//  CNMasterViewController.h
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNDetailViewController.h"
#import <CoreData/CoreData.h>

@class CNDetailViewController;


@interface CNMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CNDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSManagedObjectID * tagSort;

@end
