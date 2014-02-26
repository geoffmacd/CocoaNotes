//
//  CNProgrammaticSpellCheck.h
//  CocoaNotes
//
//  Created by Geoff MacDonald on 2/15/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMethods    @"methods"
#define kClasses    @"classes"

@interface CNProgrammaticSpellCheck : NSObject


@property (nonatomic, retain) NSArray *classNames;
@property (nonatomic, retain) NSArray *propertyNames;
@property (nonatomic, retain) NSArray *methodNames;
@property (nonatomic, retain) NSArray *protocolNames;

@property NSString * prefix;

-(instancetype)init;
-(BOOL)isPotential:(NSString*)word;
-(NSArray*)listClasses:(NSString*)word;
-(BOOL)isExactClass:(NSString*)word;
-(NSArray*)listMethods:(NSString*)word;
-(BOOL)isExactMethod:(NSString*)word;

@end
