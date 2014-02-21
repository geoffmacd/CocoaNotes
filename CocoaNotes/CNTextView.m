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
    NSTextContainer * container = [self customContainer:frame];
    self = [super initWithFrame:frame textContainer:container];
    if (self) {
        // Initialization code
        [self config]; 
        
    }
    return self;
}

-(NSTextContainer*)customContainer:(CGRect)frame{
    
    NSDictionary* attrs = @{NSFontAttributeName:
                                [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    NSAttributedString* attrString = [[NSAttributedString alloc]
                                      initWithString:@""
                                      attributes:attrs];
    _storage = [CNTextStorage new];
    _storage.delegate = self;
    [_storage appendAttributedString:attrString];
    
    // 2. Create the layout manager
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    // 3. Create a text container
    CGSize containerSize = CGSizeMake(frame.size.width, CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_storage addLayoutManager:layoutManager];
    
    return container;
}

-(void)config{
    
    [self setDelegate:self];
    
    //nav bar
    [self setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    _checkers = [NSMutableArray new];
    
    CocoaCheck * cocoa = [[CocoaCheck alloc] init];
    [_checkers addObject:cocoa];
    
    FoundationCheck * found = [[FoundationCheck alloc] init];
    [_checkers addObject:found];
    
    //keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;


    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)preferredContentSizeChanged{
    
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)showListView:(NSArray*)suggestions withFirstIndex:(NSInteger)first{
    
    CNSuggestionViewController * suggestor = [[CNSuggestionViewController alloc] initWithStyle:UITableViewStylePlain];
    
    CGFloat y = self.bounds.size.height - kbSize.height - SuggestorHeight;
    
    [suggestor.view setFrame:CGRectMake(0, y, self.bounds.size.width, SuggestorHeight)];
    [suggestor setList: suggestions];
    [suggestor setDelegate:self];
    
    
    if([self.parentControl willShowSuggestionBox:suggestor]){
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom += suggestor.view.frame.size.height;
        self.contentInset = insets;
        
        insets = self.scrollIndicatorInsets;
        insets.bottom += suggestor.view.frame.size.height;
        self.scrollIndicatorInsets = insets;
        
        //scroll to text
//        NSRange range;
//        range.location = first;
//        range.length = 0;
//        [self scrollRangeToVisible:range];
        
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
    curLoc = 0;
}

-(BOOL)shouldAutoComplete:(NSString*)word{
    
    //check checkers for any matches without returning them
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
    
//    NSRange rangeCopy = self.selectedRange;
//    NSString *textCopy = self.text.copy;
//    [self resignFirstResponder];
//    [self becomeFirstResponder];
//    [self setText:textCopy];
//    [self setSelectedRange:rangeCopy];
    
}

-(BOOL)continueSuggestions:(NSString*)recentWord{
    
    //determine whether suggestion box should still be displayed
    
    if([recentWord length] >  2){
        
        __block NSMutableArray * list = [NSMutableArray new];
        [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CNProgrammaticSpellCheck * checker = obj;
            NSArray * added =[checker listClasses:recentWord];
            if([added count]){
                NSLog(@"found suggestions");
                [list addObjectsFromArray:added];
            }
        }];
        
        if([list count]){
            //update words
            [self.suggestionBox setList:list];
            return YES;
        } else {
            //remove suggestion box
            [self removeListView];
        }
    } else{
        //before first two letters
        [self removeListView];
    }
    return NO;
}

-(NSString*)replaceUserEnteredWord:(NSString*)userWord{
    
    //use suggestions
    NSArray * suggestions = [self.suggestionBox list];
    
    if([suggestions count] == 0)
        return nil;
    else{
        return suggestions[0];
    }
}

-(void)replaceWordInTextView:(NSString*)replacement{
    
    NSMutableString * allText = [NSMutableString stringWithString:self.text];
    NSRange r;
    r.location = firstIndex;
    r.length = curLoc - firstIndex;
    while(r.location + r.length > [allText length])
        r.length--;
    [allText deleteCharactersInRange:r];
    [allText insertString:replacement atIndex:firstIndex];
    //replace textview text
    self.text = [NSString stringWithString:allText];

}

-(BOOL)shouldHighlight:(NSString*)word{
    
    __block BOOL found = NO;
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CNProgrammaticSpellCheck * checker = obj;
        if([checker isExactClass:word]){
            found = YES;
            *stop = YES;
        }
    }];
    return found;
}

/**
 Finds most recent word behind location from allText
 @param allText text in UITextView
 @param location location of cursor
 @return most recent word or else nil if invalid characters between location and alphanumeric characters
 */
-(NSString*)mostRecentWord:(NSString*)allText atLocation:(NSInteger)location{
    
    if(!invalidCharSet){
        NSMutableCharacterSet * programmaticSet = [NSCharacterSet alphanumericCharacterSet];
        NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        whitespace = [whitespace invertedSet];
        //form set with only alphanumeric without whitespaces
        [programmaticSet formIntersectionWithCharacterSet:whitespace];
        invalidCharSet = [programmaticSet invertedSet];
    }
    
    NSRange s,r;
    s.length = 0;
    s.location = location;
    
    do {
        //move string constructor range back
        s.location--;
        s.length++;
        //get newly constructed string
        NSString * constructed = [allText substringWithRange:s];
        //looking for first range of nonvalid characters
        r = [constructed rangeOfCharacterFromSet:invalidCharSet options:NSBackwardsSearch];
        //while the chracter is valid and string has enough length
    } while (s.location > 0 && r.location == NSNotFound);
    
    
    if(r.location != NSNotFound){
        s.location++;
        s.length--;
    }
    
    //if at least two letters long
    if(s.location <  location - 1){
        //found a programmatic substring
        NSString * recent  = [allText substringWithRange:s];
        //always lowercase
        return [recent lowercaseString];
    }
    
    return nil;
}

#pragma UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    //determine if last two letters denote a possible class
    NSLog(@"replacement text: %@    at location: %d  with length: %d",text, range.location, range.length);
    
    //return immediately if not applicable
    if(range.location == 0)
        return YES;
    
    NSMutableString * replacedText = [NSMutableString stringWithString:[textView text]];
    
    //determine potential for correction
    if([text length] == 1){
        //adding character
        
        //add the next letter
        [replacedText insertString:text atIndex:range.location];
        range.location++;
    } else if ([text length] > 1){
        if(showingBox)
            return NO;
    }
    else {
        //backspaced
        
        //remove last letter
        [replacedText deleteCharactersInRange:range];
    }
    NSString* recentWord = [self mostRecentWord:replacedText atLocation:range.location];
        
    if(showingBox){
        
        curLoc = range.location;
        
        if(recentWord){
        
            //pass changes to suggestion box
            [self continueSuggestions:recentWord];
        } else if([text rangeOfCharacterFromSet:invalidCharSet options:NSAnchoredSearch].location != NSNotFound) {
            //user pressed space or enter after completing word, now replace with caps
            //chop off space
            range.location--;
            recentWord = [self mostRecentWord:replacedText atLocation:range.location];
            NSString * replaceStr = [self replaceUserEnteredWord:recentWord];
            if(replaceStr && [replaceStr length] - [recentWord length] < 5) {
                
                [self replaceWordInTextView:replaceStr];
                
                //remove list
                [self removeListView];
            }
        }
        [self disableAutoComplete];
    } else{
        if([recentWord length] >= 2){
            if([self shouldAutoComplete:recentWord]){
                
                //show suggestion box
                NSLog(@"checking potential: %@",recentWord);
                //disable
                [self disableAutoComplete];
                ///show suggestion box
                curLoc = range.location;
                [self showAutoComplete:recentWord withStartIndex:range.location - [recentWord length]];
            }
        }
    }
    //continue with replacements
    return YES;
}

-(void)textViewDidChangeSelection:(UITextView *)textView{
    //scroll to selected
    NSRange range = textView.selectedRange;
    [textView scrollRangeToVisible:range];
}

#pragma CNSuggestionViewControllerDelegate

-(void)didSelectWord:(NSString *)word{
    
    //repace text
    [self replaceWordInTextView:word];
    
    //remove suggestion box
    [self removeListView];
}

#pragma Keyboard notifications

-(void)didShowKeyboard:(NSNotification*)notify{
    
    kbSize = [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.frame;
    frame.size.height -= [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self setFrame:frame];
    
//    UIEdgeInsets insets = self.contentInset;
//    insets.bottom += [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    self.contentInset = insets;
    
//    insets = self.scrollIndicatorInsets;
//    insets.bottom += [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    self.scrollIndicatorInsets = insets;
}

-(void)willHideKeyboard:(NSNotification*)notify{
    
    kbSize = CGSizeZero;
    
    if(showingBox){
        [self removeListView];
    }
    
    CGRect frame = self.frame;
    frame.size.height += [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self setFrame:frame];
    
//    UIEdgeInsets insets = self.contentInset;
//    insets.bottom -= [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
//    self.contentInset = insets;
    
//    insets = self.scrollIndicatorInsets;
//    insets.bottom -= [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
//    self.scrollIndicatorInsets = insets;
}

#pragma CNTextStorageDelegate

-(void)processEditingForAttributes{
    
    NSString * allText = _storage.string;
    NSRange r = {0, [allText length]};
    
    //enumerate all possible programmatic words and apply highlight where applicable
    [allText enumerateLinguisticTagsInRange:r scheme:NSLinguisticTagSchemeTokenType options:NSLinguisticTaggerOmitWhitespace|NSLinguisticTaggerOmitPunctuation orthography:Nil usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        
        NSString * word = [allText substringWithRange:tokenRange];
        
        if([self shouldHighlight:word])
            [_storage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tokenRange];
        else    //need to remove else text attributes are scrambled
            [_storage removeAttribute:NSForegroundColorAttributeName range:tokenRange];
    }];
    
}



@end
