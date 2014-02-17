 //
//  CNTextView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTextView.h"
#import "CocoaCheck.h"

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

-(void)showListView:(NSSet*)suggestions withFirstIndex:(NSInteger)first{
    
    
    CNSuggestionViewController * suggestor = [[CNSuggestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [suggestor.view setFrame:CGRectMake(0, 200, self.bounds.size.width, 100)];
    [suggestor setList: [suggestions allObjects]];
    [suggestor setDelegate:self];
    
    if([self.parentControl willShowSuggestionBox:suggestor]){
        _suggestionBox = suggestor;
        firstIndex = first;
        showingBox = YES;
    }
}

-(void)removeListView{
    
    [self.parentControl willRemoveSuggestionBox:_suggestionBox];
    showingBox = NO;
    firstIndex = -1;
    _suggestionBox = nil;
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

-(void)showAutoComplete:(NSString*)word withStartIndex:(NSInteger)index{
    
    __block NSMutableSet * list = [NSMutableSet new];
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CNProgrammaticSpellCheck * checker = obj;
        NSSet * added =[checker listClasses:word];
        if([added count]){
            NSLog(@"found suggestions");
            [list unionSet:added];
        }
    }];
    
    //decide to display suggestion box
    if([list count]){
        [self showListView:[NSSet setWithSet:list] withFirstIndex:index];
    }
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

-(void)continueSuggestions:(NSString*)allText withReplace:(NSString*)replacement{
    
    //determine whether suggestion box should still be displayed
    
    NSString * constructed = [NSString stringWithFormat:@"%@%@", allText, replacement];
    if([constructed length] > firstIndex + 1){
        constructed = [constructed substringFromIndex:firstIndex];
        __block NSMutableSet * list = [NSMutableSet new];
        [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CNProgrammaticSpellCheck * checker = obj;
            NSSet * added =[checker listClasses:constructed];
            if([added count]){
                NSLog(@"found suggestions");
                [list unionSet:added];
            }
        }];
        
        if([list count]){
            //update words
            [self.suggestionBox setList:[list allObjects]];
        } else {
            //remove suggestion box
            [self removeListView];
        }
    } else{
        //before first two letters
        [self removeListView];
    }
}

#pragma UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    
    //determine if last two letters denote a possible class
    NSLog(@"replacement text: %@",text);
    
    NSString * allText = [textView text];
    if(![allText length])
        return YES;
    
    //pass to box or evaluate for suggestion potential
    if(showingBox){
        [self continueSuggestions:allText withReplace:text];
    } else{
        
        unichar lastLetter;
        unichar thisLetter;
        NSInteger firstIndex;
        if([text length]){
            firstIndex = [allText length]-1;
            lastLetter = [allText characterAtIndex:firstIndex];
            thisLetter = [text characterAtIndex:0];
        } else {
            firstIndex = [allText length]-2;
            lastLetter = [allText characterAtIndex:firstIndex];
            thisLetter = [allText characterAtIndex:[allText length]-1];
        }
        
        NSString * recentWord = [NSString stringWithFormat:@"%C%C", lastLetter,thisLetter];
        
        NSCharacterSet *s = [NSCharacterSet lowercaseLetterCharacterSet];
        s = [s invertedSet];
        
        NSRange r = [recentWord rangeOfCharacterFromSet:s];
        if (r.location != NSNotFound) {
            NSLog(@"Not an alphanumeric word");
        }else{
            //prevent autocompletion and show suggestion box instead
            NSLog(@"checking potential: %@",recentWord);
            if([self shouldDisableAutoComplete:recentWord]){
                //disable
                [self disableAutoComplete];
                ///show suggestion box
                [self showAutoComplete:recentWord withStartIndex:firstIndex];
            }
        }
    }
    return YES;
}

#pragma CNSuggestionViewControllerDelegate

-(void)didSelectWord:(NSString *)word{
    
    //replace word with correction
    NSString * allText = [self text];
    //delete from firstIndex
    allText = [allText substringToIndex:firstIndex];
    allText = [allText stringByAppendingString:word];
    
    //replace
    self.text = allText;
    
    //remove suggestion box
    [self removeListView];
}

@end
