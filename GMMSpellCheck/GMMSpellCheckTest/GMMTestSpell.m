//
//  GMMTestSpell.m
//  GMMSpellCheckTest
//
//  Created by Xtreme Dev on 2014-02-27.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "GMMTestSpell.h"

@implementation GMMTestSpell

-(void)setup{
    NSArray * array = @[@"tot",@"toe",@"tote",@"total",@"totee",@"toteeeeet",@"totoef",@"totoefa"];
    [self addToSpellCheck:array];
}


@end
