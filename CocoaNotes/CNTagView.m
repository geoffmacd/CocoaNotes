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
        
//        [self setBackgroundColor:[UIColor greenColor]];
        
        _field = [[UITextField alloc] initWithFrame:[self bounds]];
        _field.borderStyle = UITextBorderStyleRoundedRect;
        [_field setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_field setPlaceholder:@"Tag"];
        if(tagName)
            [self setName:tagName];
        else
            [self setName:@"Tag"];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self setName:_field.text];
    
    //resize
    CGSize size =  [_field.text sizeWithAttributes:nil];
    NSValue *value = [NSValue valueWithCGSize:size];
    NSDictionary * dict = @{@"rect":value};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagViewTextChange object:self userInfo:dict];
    
    return YES;
}


@end
