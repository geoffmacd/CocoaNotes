//
//  Tag.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "Tag.h"
#import "Note.h"


@implementation Tag

@dynamic name;
@dynamic notes;

- (void)addNotesObject:(Note *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.notes];
    [tempSet addObject:value];
    self.notes = tempSet;
}

@end
