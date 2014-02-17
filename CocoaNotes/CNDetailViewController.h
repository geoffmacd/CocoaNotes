//
//  CNDetailViewController.h
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNTextView.h"

@interface CNDetailViewController : UIViewController <UISplitViewControllerDelegate,CNTextViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet CNTextView *textView;
@property NSManagedObjectContext * context;
@end
