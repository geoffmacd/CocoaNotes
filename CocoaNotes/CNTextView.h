//
//  CNTextView.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CNSuggestionViewController.h"
#import "CNTextStorage.h"

#define SuggestorHeight     120


@protocol CNTextViewDelegate <NSObject>

-(BOOL)willShowSuggestionBox:(CNSuggestionViewController*)controller;
-(void)willRemoveSuggestionBox:(CNSuggestionViewController*)controller;

@end


@interface CNTextView : UITextView <UITextViewDelegate,NSTextStorageDelegate,CNSuggestionViewControllerDelegate,CNTextStorageDelegate>{
    BOOL showingBox;
    NSInteger firstIndex;
    CGSize kbSize;
    CGRect _oldRect;
    NSTimer * _caretVisibilityTimer;
    NSCharacterSet * invalidCharSet;
    NSUInteger curLoc;
    CNTextStorage * _storage;
}

@property UITapGestureRecognizer * tap;
@property NSMutableArray * checkers;
@property CNSuggestionViewController * suggestionBox;

@property (weak) id<CNTextViewDelegate> parentControl;

@end
