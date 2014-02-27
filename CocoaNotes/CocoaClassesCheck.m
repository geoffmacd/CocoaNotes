//
//  CocoaCheck.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CocoaClassesCheck.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation CocoaClassesCheck


static NSArray * a;


-(void)setup{
    
    a = @[@"corefoundation",@"coredata",@"coregraphics",@"uikit"];
    
    //generate method names from objc
    unsigned int count1;
    const char** images = objc_copyImageNames(&count1);
    
    NSMutableArray * classArray  = [NSMutableArray new];
    
    for(NSInteger k = 0 ; k < count1; k++){
        
        unsigned int count2;
        const char * name = images[k];
        NSString * libName = [NSString stringWithCString:name encoding:NSStringEncodingConversionAllowLossy];
        libName = [[[libName lastPathComponent] stringByDeletingPathExtension] lowercaseString];
        
        //test if in our library list
        if([a indexOfObject:libName] != NSNotFound){
            
            const char** classes = objc_copyClassNamesForImage(name, &count2);
            
            NSCharacterSet * underscored = [NSCharacterSet characterSetWithCharactersInString:@"_"];
            
            for (NSInteger i = 0 ; i < count2; i++) {
                NSString  * className = [NSString stringWithCString:classes[i] encoding:NSStringEncodingConversionAllowLossy];
                NSRange r = [className rangeOfCharacterFromSet:underscored];
                if(r.location == NSNotFound){
                    [classArray addObject:className];
                }
            }
            free(classes);
            
            
        }
    }
    free(images);
    
    //sort by name
    [self addToSpellCheck:[classArray sortedArrayUsingSelector:@selector(compare:)]];
    
}

@end
