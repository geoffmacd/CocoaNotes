//
//  CNDetailViewController.m
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNDetailViewController.h"
#import "CNSuggestionViewController.h"
#import "CNAppDelegate.h"
#import "Tag.h"

@interface CNDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CNDetailViewController

#pragma mark - Managing the detail item

-(void)setNote:(Note *)note
{
    if (_note != note) {
        _note = note;
    }
}

- (void)configureView
{
    //create the text view
    _textView = [[CNTextView alloc] initWithFrame:self.view.frame];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_textView];
    
    // Update the user interface for the detail item.
    tagViews = [NSMutableArray new];
    if (_note) {
        _textView.text = _note.text;
        
        [_note.tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //add tag view
            Tag * tag = obj;
            CNTagView * tagView = [[CNTagView alloc] initWithFrame:CGRectMake(0, 0, 45, kTagHeight) withName:tag.name];
            [tagViews addObject:tagView];
        }];
    }
    
    [_textView setParentControl:self];
    
    
    UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = 25.0f;
    _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(2, 500, self.view.bounds.size.width-4, 40) collectionViewLayout:flow];
    [_tagCollectionView setDelegate:self];
    [_tagCollectionView setDataSource:self];
    [_tagCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_tagCollectionView setBackgroundColor:[UIColor clearColor]];
    
    
    //keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagViewDidChange:) name:kTagViewTextChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagViewEditing:) name:kTagViewTextEditing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagViewEndEditing:) name:kTagViewEndedTextEditing object:nil];

    if(![tagViews count]){
        CNTagView * blankTag = [[CNTagView alloc] initWithFrame:CGRectMake(0, 0, 45, kTagHeight) withName:nil];
        [tagViews addObject:blankTag];
    }
    
    [self.view addSubview:_tagCollectionView];
    
    //add cursor movement gestures
    self.cursorMovement = [[JTSCursorMovement alloc] initWithTextView:_textView];
    
    UIBarButtonItem * del = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteNote)];
    [self.navigationItem setRightBarButtonItem:del];
}

-(void)deleteNote{
    
    [_context deleteObject:_note];
    NSError * err;
    [self.context save:&err];
    
    _note = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

-(void)viewWillDisappear:(BOOL)animated{
    if(_note){
        _note.text = _textView.text;
        //save tags
        CNAppDelegate * appDel = (CNAppDelegate * )[[UIApplication sharedApplication] delegate];
        NSArray * tags = [appDel getTags];
        [tagViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
            CNTagView * tagView = obj;
            
            __block BOOL found = NO;
            [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                Tag * dbTag = obj;
                if([dbTag.name isEqualToString:tagView.name]){
                    
                    //ensure the tag has a note attached
                    
                    found = YES;
                    *stop = YES;
                }
            }];
            
            if(!found && tagView.name){
                //add new tag
                [appDel insertNewTag:tagView.name withInitialNote:_note.objectID];
            }
        }];
        
        NSError * err;
        [self.context save:&err];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTagViewTextChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTagViewTextEditing object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTagViewEndedTextEditing object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CNTextViewDelegate

-(BOOL)willShowSuggestionBox:(CNSuggestionViewController *)controller{
    
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];
    
    return YES;
}

-(void)willRemoveSuggestionBox:(CNSuggestionViewController *)controller{
    
    [controller removeFromParentViewController];
    [controller.view removeFromSuperview];
}


#pragma mark
#pragma mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(![tagViews count])
        return 1;
    return [tagViews count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CNTagView * tag = tagViews[[indexPath row]];
    
    CGFloat width = [tag.field.text sizeWithAttributes:@{}].width + 10;
    return CGSizeMake(width, kTagHeight);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    CNTagView * tagView = [tagViews objectAtIndex:[indexPath row]];
    //add subview
    [cell addSubview:tagView];
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.autoresizesSubviews = YES;
    
    return cell;
}

#pragma mark
#pragma mark Keyboard notifications

-(void)didShowKeyboard:(NSNotification*)notify{
    
}

-(void)willShowKeyboard:(NSNotification*)notify{
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        //adjust tagviews
        CGRect rect = _tagCollectionView.frame;
        rect.origin.y = 320;
        [_tagCollectionView setFrame:rect];
    } completion:nil];
}

-(void)willHideKeyboard:(NSNotification*)notify{

    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        //adjust tagviews
        CGRect rect = _tagCollectionView.frame;
        rect.origin.y = 500;
        [_tagCollectionView setFrame:rect];
    } completion:nil];
}

-(void)tagViewDidChange:(NSNotification*)notification{
    
    //dictionary contains new tag size
    CNTagView * changing = notification.object;
    UICollectionViewCell * cell = ( UICollectionViewCell *)[changing superview];
    
    
    CGFloat width = [changing.field.text sizeWithAttributes:@{}].width + 30;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
}

-(void)tagViewEditing:(NSNotification*)notification{
    CNTagView * changing = notification.object;
    UICollectionViewCell * cell = ( UICollectionViewCell *)[changing superview];
    
    
    CGFloat width = [changing.field.text sizeWithAttributes:@{}].width + 30;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
}

-(void)tagViewEndEditing:(NSNotification*)notification{
    CNTagView * changing = notification.object;
    UICollectionViewCell * cell = ( UICollectionViewCell *)[changing superview];
    
    CGFloat width = [changing.field.text sizeWithAttributes:@{}].width + 5;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
    
    changing.name = changing.field.text;
    if([changing.name length]){
        //it is real, add another tag view
        if([tagViews count] <= 5){
            CNTagView * blankTag = [[CNTagView alloc] initWithFrame:CGRectMake(0, 0, 45, kTagHeight) withName:nil];
            [tagViews addObject:blankTag];
        }
        
        [_tagCollectionView reloadData];
    }
}


@end
