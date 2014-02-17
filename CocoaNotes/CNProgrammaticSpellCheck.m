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
    //implemented by sublcasses
}

-(BOOL)isPotential:(NSString*)word{
    //does first two letters at least match prefix??
    if([word length] > 1)
        return ([[word lowercaseString] isEqualToString:self.prefix]);
    return NO;
}

-(NSSet*)listClasses:(NSString*)word{
    if([word length] == 2)
        return [NSSet setWithArray:self.classNames];
    else{
        NSMutableSet * methods = [NSMutableSet new];
        [_classNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj length] >= [word length]){
                NSString * shortenedClass = [[obj substringToIndex:[word length]] lowercaseString];
                if([shortenedClass isEqualToString:word])
                    [methods addObject:obj];
            }
            
        }];
        return methods;
    }
}

@end
