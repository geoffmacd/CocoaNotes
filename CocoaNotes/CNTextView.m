//
//  CNTextView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTextView.h"


@implementation CNTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self config];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self)
        [self config];
    return self;
}

-(void)config{
    
//    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//    [self addGestureRecognizer:_tap];
    
    for(UIGestureRecognizer  *recog  in [self gestureRecognizers]){
        NSLog(@"%@", [recog description]);
    }
    
    
    [self setDelegate:self];
    
    NSTextStorage * storage = self.textStorage;
    [storage setDelegate:self];
    
}

-(void)tapped:(NSNotification*)notification{
    
    NSLog(@"%@", [notification description]);
    [self setEditable:!self.editable];
}

- (void)drawRect:(CGRect)rect {
    //draw original textview
    [super drawRect:rect];
    
    //draw notepad
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:0.5].CGColor);
    
    // Draw them with a 0.5 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat lineHeight = self.font.lineHeight;
    CGFloat y = lineHeight / 2;
    
    for(NSInteger i = 0; i < 600.0 /lineHeight; i ++){
        
        CGContextMoveToPoint(context, 0,y); //start at this point
        
        CGContextAddLineToPoint(context, 320, y); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
        
        y += lineHeight;
    }
    
    
}


#pragma UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSLog(@"%@",text);
    return YES;
}

#pragma NSTextStorageDelegate

-(void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta{

}

-(void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta{
    
}

@end
