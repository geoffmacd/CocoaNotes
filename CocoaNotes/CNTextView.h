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

#define kSuggestorHeight        120
#define kTagOffset              40
#define kTagHeight              35


@protocol CNTextViewDelegate <NSObject>

-(BOOL)willShowSuggestionBox:(CNSuggestionViewController*)controller;
-(void)willRemoveSuggestionBox:(CNSuggestionViewController*)controller;

@end


@interface CNTextView : UITextView <UITextViewDelegate,NSTextStorageDelegate,CNSuggestionViewControllerDelegate,CNTextStorageDelegate>{
    BOOL showingBox;
    NSUInteger firstIndex;
    NSUInteger curLoc;
    CGSize kbSize;
    NSCharacterSet * _invalidCharSet;
    CNTextStorage * _storage;
    NSMutableArray * _checkers;
}

@property CNSuggestionViewController * suggestionBox;
@property (weak) id<CNTextViewDelegate> parentControl;

-(void)handleSwipeRight;

@end
