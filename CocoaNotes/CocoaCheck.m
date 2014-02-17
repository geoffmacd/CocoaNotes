//
//  CocoaCheck.m
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CocoaCheck.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation CocoaCheck

const char * libName = "UIKit";

-(void)config{
    self.prefix = @"ui";
    
    //generate method names from objc
    unsigned int count1;
    const char** images = objc_copyImageNames(&count1);
    
    NSMutableArray * clas  = [NSMutableArray new];
    for(NSInteger k = 0 ; k < count1; k++){
        
        unsigned int count2;
        const char * name = images[k];
        const char** classes = objc_copyClassNamesForImage(name, &count2);
        
        for (NSInteger i = 0 ; i < count2; i++) {
            NSString  * className = [NSString stringWithCString:classes[i] encoding:NSStringEncodingConversionAllowLossy];
            [clas addObject:className];
        }
    }

    
    self.classNames = clas;
}

@end
