  //
//  CNTextView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTextView.h"
#import "CocoaClassesCheck.h"
#import "GMMSpellCheck.h"

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
    _storage.textDelegate = self;
    [_storage appendAttributedString:attrString];
    
    // Create the layout manager
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    // Create a text container
    CGSize containerSize = CGSizeMake(frame.size.width, CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    [layoutManager addTextContainer:container];
    [_storage addLayoutManager:layoutManager];
    
    return container;
}

-(void)config{
    
    [self setDelegate:self];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    _checkers = [NSMutableArray new];
    
    //too slow, put on another thread
    dispatch_queue_t queue = dispatch_queue_create("GMM", nil);
    dispatch_async(queue, ^{
    
        CocoaClassesCheck * cocoa = [[CocoaClassesCheck alloc] init];
        [_checkers addObject:cocoa];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //highlight after they are ready on main thread
            [self processHighlighting];
        });
    });

    //keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    //invalid characters
    NSMutableCharacterSet * programmaticSet = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet * methodSet = [NSCharacterSet characterSetWithCharactersInString:@"-+"];
    whitespace = [whitespace invertedSet];
    //form set with only alphanumeric without whitespaces
    [programmaticSet formIntersectionWithCharacterSet:whitespace];
    [programmaticSet formIntersectionWithCharacterSet:methodSet];
    _invalidCharSet = [programmaticSet invertedSet];
    

}

-(void)preferredContentSizeChanged{
    //form notification
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

-(void)setText:(NSString *)text{
    [super setText:text];
    
    [self processHighlighting];
}

#pragma mark
#pragma mark Suggestions

-(void)showListView:(NSDictionary*)suggestions withFirstIndex:(NSInteger)first{
    
    CNSuggestionViewController * suggestor = [[CNSuggestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    CGFloat y = self.bounds.size.height - kbSize.height - kSuggestorHeight;
    
    [suggestor.view setFrame:CGRectMake(0, y, self.bounds.size.width, kSuggestorHeight)];
    [suggestor setDict: suggestions];
    [suggestor setDelegate:self];
    
    
    if([self.parentControl willShowSuggestionBox:suggestor]){
        
        //include suggestion box
        [self setContentInset:UIEdgeInsetsMake(64, 0, kbSize.height + kSuggestorHeight, 0)];
        
        _suggestionBox = suggestor;
        firstIndex = first;
        showingBox = YES;
    }
}

-(void)removeListView{
    
    [self enableAutoComplete];
    
    [self.parentControl willRemoveSuggestionBox:_suggestionBox];
    showingBox = NO;
    firstIndex = -1;
    _suggestionBox = nil;
    curLoc = 0;
    
    //reset
    [UIView animateWithDuration:0.6 animations:^{
        [self setContentInset:UIEdgeInsetsMake(64, 0, kbSize.height, 0)];
    }];
    
    //scroll to text selection
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //adjust position of scrollview
        CGRect line = [self caretRectForPosition: self.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height - ( self.contentOffset.y + self.bounds.size.height - self.contentInset.bottom - self.contentInset.top );
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = self.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
            [self setContentOffset:offset];
        }
    });
}

-(void)showAutoComplete:(NSString*)word withStartIndex:(NSInteger)index{
    
    NSDictionary * suggestionDict = [self listSuggestions:word];
    
    //decide to display suggestion box
    if([suggestionDict count]){
        [self showListView:suggestionDict withFirstIndex:index];
    }
}

-(void)disableAutoComplete{
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
}

-(void)enableAutoComplete{
    [self setAutocorrectionType:UITextAutocorrectionTypeDefault];
}

-(BOOL)continueSuggestions:(NSString*)recentWord{
    
    //determine whether suggestion box should still be displayed
    
    if([self isPotential:recentWord]){
        
        NSDictionary * suggestionDict = [self listSuggestions:recentWord];
        
        if([suggestionDict count]){
            //update words
            [self.suggestionBox setDict:suggestionDict];
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

/**
 Finds most recent word behind location from allText
 @param allText text in UITextView
 @param location location of cursor
 @return most recent word or else nil if invalid characters between location and alphanumeric characters
 */
-(NSString*)mostRecentWord:(NSString*)allText atLocation:(NSInteger)location{
    
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
        r = [constructed rangeOfCharacterFromSet:_invalidCharSet options:NSBackwardsSearch];
        //while the chracter is valid and string has enough length
    } while (s.location > 0 && r.location == NSNotFound);
    
    //increment from failed lookup
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

#pragma mark
#pragma mark UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView{
    
    //adjust position of scrollview
    CGRect line = [textView caretRectForPosition: textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
    
    
}

-(void)textViewDidChangeSelection:(UITextView *)textView{
    
    NSRange range = textView.selectedRange;
    //should not have anything selected
    if(range.length)
        range.location += range.length;
    NSString * upToLocText = [textView.text substringToIndex:range.location];

    NSString* recentWord = [self mostRecentWord:upToLocText atLocation:range.location];
    
    if(showingBox){
        curLoc = range.location;
        
        [self disableAutoComplete];
        
        if(recentWord){
            //pass changes to suggestion box
            [self continueSuggestions:recentWord];
        } else {
            //one back due to space or return
            recentWord = [self mostRecentWord:upToLocText atLocation:range.location-1];
            if(recentWord && [self containsExact:recentWord]){
                //replace with exact match
                curLoc--;
                NSString * replacement = [self exactWord:recentWord];
                [self replaceWordInTextView:replacement];
            }
            
            //remove list
            [self removeListView];
        }
    } else{
        if([self isPotential:recentWord]){
            
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

#pragma mark
#pragma mark CNSuggestionViewControllerDelegate

-(void)didSelectWord:(NSString *)word{
    
    //repace text
    [self replaceWordInTextView:word];
    
    //remove suggestion box
    [self removeListView];
}

#pragma mark
#pragma mark Keyboard notifications

-(void)didShowKeyboard:(NSNotification*)notify{
    
    kbSize = [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //adjust for keyboard
    [self setContentInset:UIEdgeInsetsMake(64, 0, kbSize.height + kTagHeight + 5, 0)];
}

-(void)willShowKeyboard:(NSNotification*)notify{

}

-(void)willHideKeyboard:(NSNotification*)notify{
    
    kbSize = CGSizeZero;
    if(showingBox)
        [self removeListView];
    //reset
    [self setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    //scroll to text selection
    NSRange r =self.selectedRange;
    [self scrollRangeToVisible:r];
}

#pragma mark
#pragma mark CNTextStorageDelegate

-(void)processHighlighting{
    //highlight syntax
    NSString * allText = _storage.string;
    NSRange r = {0, [allText length]};
    
    //enumerate all possible programmatic words and apply highlight where applicable
    [allText enumerateLinguisticTagsInRange:r scheme:NSLinguisticTagSchemeTokenType options:NSLinguisticTaggerOmitWhitespace|NSLinguisticTaggerOmitPunctuation orthography:Nil usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        
        NSString * word = [allText substringWithRange:tokenRange];
//        NSLog(@"%@",word);
        
        if([self containsExact:word])
            [_storage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tokenRange];
        else    //need to remove else text attributes are scrambled
            [_storage removeAttribute:NSForegroundColorAttributeName range:tokenRange];
    }];
}

#pragma mark
#pragma mark GMMSpellChecker combines

-(BOOL)isPotential:(NSString*)word{
    
    __block BOOL should = NO;
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        GMMSpellCheck * checker = obj;
        if([checker isPotential:word]){
            should = YES;
            NSLog(@"is potential for word: %@", word);
            *stop = YES;
        }
    }];
    return should;
}

-(NSDictionary*)listSuggestions:(NSString*)word{
    
    __block NSMutableDictionary * dict = [NSMutableDictionary new];
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        GMMSpellCheck * checker = obj;
        NSArray * suggestions = [checker listSuggestions:word];
        if([suggestions count]){
            NSLog(@"found suggestions for word: %@", word);
            if([suggestions count])
                dict[checker.checkerName] = suggestions;
        }
    }];
    return dict;
}

-(BOOL)containsExact:(NSString*)word{
    
    __block BOOL exact = NO;
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        GMMSpellCheck * checker = obj;
        if([checker containsExact:word]){
            exact = YES;
            NSLog(@"contains exact: %@", word);
            *stop = YES;
        }
    }];
    return exact;

}

-(NSString*)exactWord:(NSString*)word{
    
    __block NSString * exact;;
    [_checkers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        GMMSpellCheck * checker = obj;
        exact = [checker exactWord:word];
        if(exact){
            NSLog(@"exact word: %@", word);
            *stop = YES;
        }
    }];
    return exact;
    
}

@end
