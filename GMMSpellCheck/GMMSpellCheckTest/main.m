//
//  main.m
//  GMMSpellCheckTest
//
//  Created by Xtreme Dev on 2014-02-27.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMMTestSpell.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        //init test spell check with random words
        GMMTestSpell * test = [[GMMTestSpell alloc] init];
    
        NSLog(@"Custom Spellcheck test...");
    
        while(YES){
            
            char str[50] = {0};                  // init all to 0
            
            printf("Enter word to spell check: ");
            scanf("%s", str);                    // read and format into the str buffer
            
            NSString * word = [NSString stringWithCString:str encoding:NSStringEncodingConversionAllowLossy];
            NSArray * suggestions = [test listSuggestions:word];
            if([suggestions count]){
                if([test containsExact:word])
                    NSLog(@"Contains Exact Match!");
                NSLog(@"Suggestions....");
                [suggestions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSLog(@"    %@",obj);
                }];
            } else {
                
                NSLog(@"No Suggestions");
            }
        }
    }
    return 0;
}

