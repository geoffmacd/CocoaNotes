 //
//  CNTextView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTextView.h"
#import "CocoaCheck.h"
#import "FoundationCheck.h"

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
    
    FoundationCheck * found = [[FoundationCheck alloc] init];
    [_checkers addObject:found];
    
    //keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

}

- (void)drawRect:(CGRect)rect {
    //draw original textview
    [super drawRect:rect];
    
//    //draw notepad
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:0.5].CGColor);
//    
//    // Draw them with a 0.5 stroke width so they are a bit more visible.
//    CGContextSetLineWidth(context, 0.5);
//    
//    CGFloat lineHeight = self.font.lineHeight;
//    CGFloat y = lineHeight / 2;
//    
//    for(NSInteger i = 0; i < 600.0 /lineHeight; i ++){
//        
//        CGContextMoveToPoint(context, 0,y); //start at this point
//        
//        CGContextAddLineToPoint(context, 320, y); //draw to this point
//        
//        // and now draw the Path!
//        CGContextStrokePath(context);
//        
//        y += lineHeight;
//    }
}

-(void)showListView:(NSArray*)suggestions withFirstIndex:(NSInteger)first{
    
    CNSuggestionViewController * suggestor = [[CNSuggestionViewController alloc] initWithStyle:UITableViewStylePlain];
    
    CGFloat y = self.bounds.size.height - kbSize.height - 200;
    
    [suggestor.view setFrame:CGRectMake(0, y, self.bounds.size.width, 200)];
    [suggestor setList: suggestions];
    [suggestor setDelegate:self];
    
    
    if([self.parentControl willShowSuggestionBox:suggestor]){
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom += _suggestionBox.view.frame.size.height;
        self.contentInset = insets;
        
        insets = self.scrollIndicatorInsets;
        insets.bottom += _suggestionBox.view.frame.size.height;
        self.scrollIndicatorInsets = insets;
        
        _suggestionBox = suggestor;
        firstIndex = first;
        showingBox = YES;
    }
}

-(void)removeListView{
    
    UIEdgeInsets insets = self.contentInset;
    insets.bottom -= _suggestionBox.view.frame.size.height;
    self.contentInset = insets;
    
    insets = self.scrollIndicatorInsets;
    insets.bottom -= _suggestionBox.view.frame.size.height;
    self.scrollIndicatorInsets = insets;
    
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
        
        NSArray * added =[checker listClasses:word];
        if([added count]){
            should = YES;
            NSLog(@"is potential from class list");
            *stop = YES;
        }
        
    }];
    return should;
}

-(void)showAutoComplete:(NSString*)word withStartIndex:(NSInteger)index{
    
    __block NSMutableArray * list = [NSMutableArray new];
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CNProgrammaticSpellCheck * checker = obj;
        NSArray * added =[checker listClasses:word];
        if([added count]){
            NSLog(@"found suggestions");
            [list addObjectsFromArray:added];
        }
    }];
    
    //decide to display suggestion box
    if([list count]){
        [self showListView:list withFirstIndex:index];
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
    if([constructed length] > firstIndex + 2){
        constructed = [constructed substringFromIndex:firstIndex];
        if(![replacement length]){
            constructed = [constructed substringToIndex:[constructed length]-1];
        }
        
        __block NSMutableArray * list = [NSMutableArray new];
        [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CNProgrammaticSpellCheck * checker = obj;
            NSArray * added =[checker listClasses:constructed];
            if([added count]){
                NSLog(@"found suggestions");
                [list addObjectsFromArray:added];
            }
        }];
        
        if([list count]){
            //update words
            [self.suggestionBox setList:list];
        } else {
            //remove suggestion box
            [self removeListView];
        }
    } else{
        //before first two letters
        [self removeListView];
    }
}

-(NSString*)mostRecentWord:(NSString*)allText{
    
    //find most recent word
    
    if([allText length] < 2)
        return nil;
    
    NSInteger index = [allText length]-2;
    
    NSMutableCharacterSet * programmaticSet = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    whitespace = [whitespace invertedSet];
    //form set with only alphanumeric without whitespaces
    [programmaticSet formIntersectionWithCharacterSet:whitespace];
    NSCharacterSet * test = [programmaticSet invertedSet];
    NSRange r;
    
    do {
        NSString * constructed = [allText substringFromIndex:index];
        //looking for nonvalid characters
        r = [constructed rangeOfCharacterFromSet:test options:NSBackwardsSearch];
        index--;
        //while the chracter is valid and string has enough length
    } while (index > 1 && r.location == NSNotFound);
    
    if(index < [allText length]-2){
        //found a programmatic substring
        NSString * recent  = [allText substringFromIndex:index+2];
        return [recent lowercaseString];
    }
    
    return nil;
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
        NSInteger index;
        NSString * recentWord;
        
        if([text length]){
            //adding character
            index = [allText length]-1;
            lastLetter = [allText characterAtIndex:index];
            thisLetter = [text characterAtIndex:0];
            NSString * recentWord = [[NSString stringWithFormat:@"%C%C", lastLetter,thisLetter] lowercaseString];
            
            NSCharacterSet *s = [NSCharacterSet lowercaseLetterCharacterSet];
            s = [s invertedSet];
            
            //is it letterset
            NSRange r = [recentWord rangeOfCharacterFromSet:s];
            if (r.location != NSNotFound) {
                NSLog(@"Not an alphanumeric word");
            }else{
                //check previous letter as well
                if(index - 1 >= 0){
                    unichar oldLetter = [allText characterAtIndex:index-1];
                    NSString * testOldLetter = [NSString stringWithFormat:@"%C",oldLetter];
                    
                    NSRange r = [testOldLetter rangeOfCharacterFromSet:s];
                    if (r.location == NSNotFound)
                        return YES;
                }
                
                //prevent autocompletion and show suggestion box instead
                NSLog(@"checking potential: %@",recentWord);
                if([self shouldDisableAutoComplete:recentWord]){
                    //disable
                    [self disableAutoComplete];
                    ///show suggestion box
                    [self showAutoComplete:recentWord withStartIndex:index];
                }
            }
        } else {
            //backspacing
            NSString * removed = [allText substringToIndex:range.location];
            recentWord = [self mostRecentWord:removed];
            if(recentWord){
                //show suggestion box
                NSLog(@"checking potential: %@",recentWord);
                if([self shouldDisableAutoComplete:recentWord]){
                    //disable
                    [self disableAutoComplete];
                    ///show suggestion box
                    [self showAutoComplete:recentWord withStartIndex:range.location - [recentWord length]];
                }
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
    NSRange r;
    r.length = [word length];
    r.location = firstIndex;
    
    //replace
    self.text = allText;
    
    //remove suggestion box
    [self removeListView];
    
    //highlight
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
//    [attributedString addAttribute:NSForegroundColorAttributeName  value:[UIColor redColor] range:r];
//    self.attributedText = attributedString;
}

#pragma Keyboard notifications

-(void)didShowKeyboard:(NSNotification*)notify{
    
    kbSize = [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets insets = self.contentInset;
    insets.bottom += [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.contentInset = insets;
    
    insets = self.scrollIndicatorInsets;
    insets.bottom += [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.scrollIndicatorInsets = insets;
}

-(void)willHideKeyboard:(NSNotification*)notify{
    
    kbSize = CGSizeZero;
    
    UIEdgeInsets insets = self.contentInset;
    insets.bottom -= [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.contentInset = insets;
    
    insets = self.scrollIndicatorInsets;
    insets.bottom -= [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.scrollIndicatorInsets = insets;
}

- (void)_scrollCaretToVisible
{
    //This is where the cursor is at.
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    
    if(CGRectEqualToRect(caretRect, _oldRect))
        return;
    
    _oldRect = caretRect;
    
    //This is the visible rect of the textview.
    CGRect visibleRect = self.bounds;
    visibleRect.size.height -= (self.contentInset.top + self.contentInset.bottom);
    visibleRect.origin.y = self.contentOffset.y;
    
    //We will scroll only if the caret falls outside of the visible rect.
    if(!CGRectContainsRect(visibleRect, caretRect))
    {
        CGPoint newOffset = self.contentOffset;
        
        newOffset.y = MAX((caretRect.origin.y + caretRect.size.height) - visibleRect.size.height + 5, 0);
        
        [self setContentOffset:newOffset animated:YES];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _oldRect = [self caretRectForPosition:self.selectedTextRange.end];
    
    _caretVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(_scrollCaretToVisible) userInfo:nil repeats:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_caretVisibilityTimer invalidate];
    _caretVisibilityTimer = nil;
}


@end
