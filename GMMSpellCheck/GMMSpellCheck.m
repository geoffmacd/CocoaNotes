//
//  GMMSpellCheck.m
//
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "GMMSpellCheck.h"

@interface NSString(NSStringGMMAddition)
- (NSComparisonResult)lengthCompare:(NSString *)string;
-(BOOL)isEqualToString:(NSString *)aString insensitive:(BOOL)insensitive;
@end

@implementation NSString(NSStringGMMAddition)
- (NSComparisonResult)lengthCompare:(NSString *)string{
    
    if([self length] < [string length])
        return NSOrderedAscending;
    else if([self length] > [string length])
        return NSOrderedDescending;
    else    //alphabetic if same length
        return [self caseInsensitiveCompare:string];
}

-(BOOL)isEqualToString:(NSString *)aString insensitive:(BOOL)insensitive{
    
    if(insensitive){
        return [[self lowercaseString] isEqualToString:[aString lowercaseString]];
    } else
        return [self isEqualToString:aString];
}

@end


@interface GMMSpellCheck ()

/**
 Range finding options
 */
@property NSStringCompareOptions options;
/**
 Internal dictionary containing graph of keys
 */
@property (nonatomic, strong) NSDictionary * suggestions;

@end

@implementation GMMSpellCheck

-(instancetype)init{
    if(self = [super init]){
        //default setup
        _minLength = 2;
        _orderByShortestPossibility = YES;
        _caseInsensitive = YES;
        _suggestions = [NSDictionary new];
        [self setCaseInsensitive:YES];
        //subclass setup
        [self setup];
    }
    return self;
}

-(void)addToSpellCheck:(NSArray*)addArray{
    
    //short by shortest
    NSArray * words = [addArray sortedArrayUsingSelector:@selector(length)];
    
    __block NSMutableArray * objArray = [NSMutableArray new];
    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //add blank subdictionary to each word
        [objArray addObject:[NSMutableDictionary new]];
    }];
    //create dictionary with blank sub-dictionaries to recursively organize with recursiveDictionarySort
    NSMutableDictionary * wordDict = [NSMutableDictionary dictionaryWithObjects:objArray forKeys:words];
    
    _suggestions = [self recursiveDictionarySort:wordDict];
    NSLog(@"%@", [_suggestions description]);
}

-(NSMutableDictionary*)recursiveDictionarySort:(NSMutableDictionary*)wordDict{
    //for each word, add to top level dictionary if key is substring or create new dictionary
    
    NSArray * wordArray = [[wordDict allKeys] sortedArrayUsingSelector:@selector(lengthCompare:)];
    
    [wordArray enumerateObjectsUsingBlock:^(id topWord, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"%@",topWord);
        __block NSMutableDictionary * topDict = wordDict[topWord];
        
        //find substring match ordered by shortest key
        [wordArray enumerateObjectsUsingBlock:^(id subWord, NSUInteger idx, BOOL *stop) {
            
            if(![subWord isEqualToString:topWord]){

                //find this subword in previous keys
                NSRange range = [subWord rangeOfString:topWord options:_options];
                if(range.location != NSNotFound){
                    //if found then add it to that key's dictionary with blank sub-dictionary attached
                    topDict[subWord] = [NSMutableDictionary new];
                    [wordDict removeObjectForKey:subWord];
                }
            }
        }];
        
        //all words added, recurse
        topDict = [self recursiveDictionarySort:topDict];
    }];
    
    return wordDict;
}

-(void)setup{
    //implemented by subclasses
    NSAssert(NO, @"Setup method must be implemented by SpellCheck Subclasses. Can not use directly");
}

-(void)setCaseInsensitive:(BOOL)caseInsensitive{
    _caseInsensitive = caseInsensitive;
    
    if(caseInsensitive)
        _options = NSCaseInsensitiveSearch|NSAnchoredSearch;
    else //start at beginning
        _options = NSAnchoredSearch;
}

-(BOOL)isPotential:(NSString*)word{
    //does word contain at least minimum length
    return ([word length] >= _minLength);
}

-(NSArray*)listSuggestions:(NSString*)word{
    
    if([self isPotential:word]){
        if(_orderByShortestPossibility)
            return [[self listSuggestions:word withDictionary:_suggestions] sortedArrayUsingSelector:@selector(lengthCompare:)];
        else
            return [[self listSuggestions:word withDictionary:_suggestions] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
    return nil;
}

-(NSArray*)listSuggestions:(NSString*)word withDictionary:(NSDictionary*)wordDict{
    
    __block NSMutableArray * wordArray = [NSMutableArray new];
    [wordDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if([word length] > [key length]){
            //find substring of key in word
            
            NSRange keyRange = [word rangeOfString:key options:_options];
            if(keyRange.location != NSNotFound){
                
                NSDictionary * subDict = obj;
                //recursive with subdirectory
                NSArray * wordsFromDict = [self listSuggestions:word withDictionary:subDict];
                //add words from key
                [wordArray addObjectsFromArray:wordsFromDict];
            }
            
        } else if( [word length] < [key length]){
            //find substring of word in key
            
            NSRange keyRange = [key rangeOfString:word options:_options];
            if(keyRange.location != NSNotFound){
                
                //add key directly
                [wordArray addObject:key];
                
                NSDictionary * subDict = obj;
                //recursive with subdirectory
                NSArray * wordsFromDict = [self listSuggestions:word withDictionary:subDict];
                //add words from key
                [wordArray addObjectsFromArray:wordsFromDict];
            }
            
        } else {
            //equal
            
            //add key directly
            if([key isEqualToString:word insensitive:_caseInsensitive])
                [wordArray addObject:key];
            
            //add recursive words for this key as well
            NSRange keyRange = [word rangeOfString:key options:_options];
            if(keyRange.location != NSNotFound){
                
                NSDictionary * subDict = obj;
                //recursive with subdirectory
                NSArray * wordsFromDict = [self listSuggestions:word withDictionary:subDict];
                //add words from key
                [wordArray addObjectsFromArray:wordsFromDict];
            }
        }
    }];
    return wordArray;
}

-(BOOL)containsExact:(NSString*)word{
    return [self containsExact:word withDict:_suggestions];
}

-(BOOL)containsExact:(NSString*)word withDict:(NSDictionary*)wordDict{
    //determine if graph contains exact word
    
    __block NSString * subKey;
    __block NSDictionary * subDict = nil;
    
    [wordDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString * keyStr = (NSString*)key;
        if([keyStr isEqualToString:word insensitive:_caseInsensitive]){
            subKey = keyStr;
            *stop = YES;
        } else {
            
            NSRange keyRange = [keyStr rangeOfString:word options:_options];
            if(keyRange.location != NSNotFound){
                
                subDict = (NSDictionary *)obj;
                subKey = word;
                //recursive with subdirectory
                *stop = YES;
            }
        }
    }];
    
    if(subKey && subDict == nil)
        return YES;
    else if(subKey && subDict)
        return [self containsExact:subKey withDict:subDict];
    return NO;
}

@end
