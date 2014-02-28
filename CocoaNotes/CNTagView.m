//
//  CNTagView.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/23/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNTagView.h"

@implementation CNTagView

- (id)initWithFrame:(CGRect)frame withName:(NSString*)tagName
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _field = [[UITextField alloc] initWithFrame:[self bounds]];
        _field.borderStyle = UITextBorderStyleRoundedRect;
        _field.returnKeyType = UIReturnKeyDone;
        _field.enablesReturnKeyAutomatically = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _field.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_field setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        if(tagName)
            [self setName:tagName];
        else
            [self setName:@"tag"];
        [_field setTextColor:[UIColor purpleColor]];
        [_field setDelegate:self];
        [_field setEnabled:YES];
        [self addSubview:_field];
        
    }
    return self;
}

-(void)setName:(NSString *)name{
    _name = name;
    
    [_field setText:name];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_field resignFirstResponder];
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength > 15)
        return NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagViewTextChange object:self userInfo:nil];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagViewTextEditing object:self userInfo:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagViewEndedTextEditing object:self userInfo:nil];
}

@end
