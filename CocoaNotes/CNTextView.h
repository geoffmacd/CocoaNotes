//
//  CNTextView.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNTextView : UITextView <UITextViewDelegate,NSTextStorageDelegate>

@property UITapGestureRecognizer * tap;

@end
