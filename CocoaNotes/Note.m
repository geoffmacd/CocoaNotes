//
//  Note.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "Note.h"


@implementation Note

@dynamic timeStamp;
@dynamic text;
@dynamic tags;

- (void)addTagsObject:(Note *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.tags];
    [tempSet addObject:value];
    self.tags = tempSet;
}

@end
