GMMSpellCheck
=============

Efficient ObjC spell checking engine for iOS/Mac


=============

Add words to spell checker with subclass of GMSpellCheck. Then see suggestions or match for a word. 

```
@interface GMMTestSpell : GMMSpellCheck
@end
  
@implementation GMMTestSpell

-(void)setup{
    NSArray * array = @[@"tot",@"toe",@"tote",@"total",@"tots",@"tuft",@"top",@"tulip"];
     [self addToSpellCheck:array];
}
@end
```

```
GMMTestSpell * test = [[GMMTestSpell alloc] init];
NSArray * suggestions = [test listSuggestions:@"tot"];
  
NSLog(@"%@", [suggestions description]);
//Prints tot,tote,total,tots
```





