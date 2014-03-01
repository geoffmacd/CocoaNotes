//
//  CNAppDelegate.h
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNDrawerViewController.h"
#import "CNMasterViewController.h"
#import "JSSlidingViewController.h"

@interface CNAppDelegate : UIResponder <UIApplicationDelegate,DrawerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property CNDrawerViewController * drawerView;
@property CNMasterViewController * masterView;
@property JSSlidingViewController * slidingController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(NSArray*)getTags;
- (void)insertNewTag:(NSString*)tagName withInitialNote:(NSManagedObjectID*)firstNoteId;

@end
