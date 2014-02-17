//
//  CNTextView.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CNSuggestionViewController.h"


@protocol CNTextViewDelegate <NSObject>

-(BOOL)willShowSuggestionBox:(CNSuggestionViewController*)controller;
-(void)willRemoveSuggestionBox:(CNSuggestionViewController*)controller;

@end


@interface CNTextView : UITextView <UITextViewDelegate,NSTextStorageDelegate,CNSuggestionViewControllerDelegate>{
    BOOL showingBox;
    NSInteger firstIndex;
    CGSize kbSize;
}

@property UITapGestureRecognizer * tap;
@property NSMutableArray * checkers;
@property CNSuggestionViewController * suggestionBox;

@property (weak) id<CNTextViewDelegate> parentControl;

@end
