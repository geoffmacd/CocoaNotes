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
#import "CNTagView.h"
#import "Note.h"

@interface CNDetailViewController : UIViewController <UISplitViewControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNTextViewDelegate>{
    CNTextView * _textView;
    NSMutableArray * tagViews;
}

@property (strong, nonatomic) Note * note;

@property (strong,nonatomic) JTSCursorMovement * cursorMovement;
@property UICollectionView * tagCollectionView;

@property NSManagedObjectContext * context;
@end
