//
//  CNDetailViewController.h
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNTextView.h"
#import <JTSCursorMovement.h>

@interface CNDetailViewController : UIViewController <UISplitViewControllerDelegate,CNTextViewDelegate>{
    CNTextView * _textView;
}

@property (strong, nonatomic) id detailItem;

@property (strong,nonatomic) JTSCursorMovement * cursorMovement;

@property NSManagedObjectContext * context;
@end
