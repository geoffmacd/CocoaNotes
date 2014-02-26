//
//  CNProgrammaticSpellCheck.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNProgrammaticSpellCheck.h"



@implementation CNProgrammaticSpellCheck

-(instancetype)init{
    if(self = [super init]){
        [self config];
    }
    return self;
}

-(void)config{
    //implemented by subclasses
}

-(BOOL)isPotential:(NSString*)word{
    //does first two letters at least match prefix??
    if([word length] > 1){
        //return is at least one
        NSArray * l = [self listClasses:[word lowercaseString]];
        return ([l count] || [self isPotentialMethod:[word lowercaseString]]);
    }
    return NO;
}

-(BOOL)isPotentialMethod:(NSString*)word{
    
    unichar plus = '+';
    unichar minus = '-';
    
    unichar first = [word characterAtIndex:0];
    
    if(first == plus || first == minus){
        NSArray * m = [self listMethods:[word lowercaseString]];
        if([m count])
            return YES;
    }
    return NO;
}

-(NSArray*)listClasses:(NSString*)word{

    NSMutableArray * methods = [NSMutableArray new];
    [_classNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj length] >= [word length]){
            NSString * shortenedClass = [[obj substringToIndex:[word length]] lowercaseString];
            if([shortenedClass isEqualToString:word])
                [methods addObject:obj];
        }
    }];
    
    return methods;
}

-(BOOL)isExactClass:(NSString*)word{

    NSUInteger index = [_classNames indexOfObject:word];
    
    return (index != NSNotFound);
}

-(NSArray*)listMethods:(NSString*)word{
    
    NSMutableArray * methods = [NSMutableArray new];
    [_methodNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj length] >= [word length]){
            NSString * shortenedMethod = [[obj substringToIndex:[word length]] lowercaseString];
            if([shortenedMethod isEqualToString:word])
                [methods addObject:obj];
        }
    }];
    
    return methods;
}

-(BOOL)isExactMethod:(NSString*)word{
    
    NSUInteger index = [_methodNames indexOfObject:word];
    
    return (index != NSNotFound);
}

@end
