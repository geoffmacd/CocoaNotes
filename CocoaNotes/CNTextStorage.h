//
//  CNTextStorage.h
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/20/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CNTextStorageDelegate <NSObject>

-(void)processHighlighting;

@end

@interface CNTextStorage : NSTextStorage {
    NSMutableAttributedString * _backingStore;
}

@property (weak,nonatomic) id<CNTextStorageDelegate> textDelegate;

@end
