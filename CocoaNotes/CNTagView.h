//
//  CNTagView.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/23/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTagViewTextChange  @"TextViewDidChange"

@interface CNTagView : UIView <UITextFieldDelegate>

@property (nonatomic) NSString * name;
@property NSManagedObjectID *tagId;


@property (strong,nonatomic) UITextField * field;

- (id)initWithFrame:(CGRect)frame withName:(NSString*)tagName;

@end
