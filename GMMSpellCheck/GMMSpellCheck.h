//
//  GMMSpellCheck.h
//
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMMSpellCheck : NSObject


/**
 Minimum length before triggering auto-complete. 2 letters by default
 */
@property NSInteger minLength;
/**
 Order by the shortest replacement words vs ordering by closest spelling. Yes by default
 */
@property BOOL orderByShortestPossibility;
/**
 Case sensitivity. Insensitive by default.
 */
@property (nonatomic) BOOL caseInsensitive;
/**
 User facing spell checker name. IE. English dictionary
 */
@property NSString * checkerName;


/**
 Add words to check for in spellcheck
 @param addArray array of nsstring to add to spellcheck
 */
-(void)addToSpellCheck:(NSArray*)addArray;
/**
 @param word word to check if spellcheck should run
 @return YES if spell check should run
 */
-(BOOL)isPotential:(NSString*)word;
/**
 @param word word to list suggestions for
 @return Array of potential replacements
 */
-(NSArray*)listSuggestions:(NSString*)word;
/**
 Check is word has exact match in spellcheck dictionary
 @param word word to check for exact match
 @return Yes if dictionary contains exact match
 */
-(BOOL)containsExact:(NSString*)word;


-(void)setup;

@end
