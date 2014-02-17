 //
//  CNTextView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTextView.h"
#import "CocoaCheck.h"
#import "CNSuggestionViewViewController.h"

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
    
    [self setDelegate:self];
    
    _checkers = [NSMutableArray new];
    
    CocoaCheck * cocoa = [[CocoaCheck alloc] init];
    [_checkers addObject:cocoa];
    
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

-(void)showListView:(NSString*)word{
    
    
    CNSuggestionViewViewController * suggestor = [[CNSuggestionViewViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    
    [self.parentControl willShowSuggestionBox:suggestor];
}

-(BOOL)shouldDisableAutoComplete:(NSString*)word{
    
    __block BOOL should = NO;
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CNProgrammaticSpellCheck * checker = obj;
        if([checker isPotential:word]){
            should = YES;
            NSLog(@"is potential");
            *stop = YES;
        }
        
    }];
    return should;
}

-(void)checkAutoComplete:(NSString*)word{
    
}

-(void)disableAutoComplete{
    
    NSRange rangeCopy = self.selectedRange;
    NSString *textCopy = self.text.copy;
    NSLog(@"disabled autocomplete");
    [self resignFirstResponder];
    [self becomeFirstResponder];
    [self setText:textCopy];
    [self setSelectedRange:rangeCopy];
    
}


#pragma UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSLog(@"replacement: %@",text);
    
    NSString * allText = [textView text];
    
    if(![allText length])
        return YES;
    
    unichar lastLetter;
    unichar thisLetter;
    if([text length]){
        lastLetter = [allText characterAtIndex:[allText length]-1];
        thisLetter = [text characterAtIndex:0];
    } else {
        lastLetter = [allText characterAtIndex:[allText length]-2];
        thisLetter = [allText characterAtIndex:[allText length]-1];
    }
    
    NSString * recentWord = [NSString stringWithFormat:@"%C%C", lastLetter,thisLetter];
    
    NSCharacterSet *s = [NSCharacterSet lowercaseLetterCharacterSet];
    s = [s invertedSet];
    
    NSRange r = [recentWord rangeOfCharacterFromSet:s];
    if (r.location != NSNotFound) {
        NSLog(@"Not an alphanumeric word");
        return YES;
    }else{
        NSLog(@"checking potential: %@",recentWord);
        if([self shouldDisableAutoComplete:recentWord]){
            [self disableAutoComplete];
            [self checkAutoComplete:recentWord];
        }
        return YES;
    }
}

@end
