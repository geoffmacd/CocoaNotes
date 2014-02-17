//
//  CNSuggestionViewViewController.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/16/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CNSuggestionViewControllerDelegate <NSObject>

-(void)didSelectWord:(NSString*)word;

@end

@interface CNSuggestionViewController : UITableViewController

@property (nonatomic) NSArray * list;
@property NSString * started;
@property (weak) id<CNSuggestionViewControllerDelegate> delegate;

@end
