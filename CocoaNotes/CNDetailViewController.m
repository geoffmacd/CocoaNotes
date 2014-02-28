//
//  CNDetailViewController.m
//  CocoaNotes
//
//  Created by Xtreme Dev on 2/13/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "CNDetailViewController.h"
#import "CNSuggestionViewController.h"

@interface CNDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CNDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    } 

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

-(void)detailViewComponents:(UIView*)view{
    
    NSLog(@"%@", [view description]);
    
    for(UIView * subView in [view subviews]){
        
        [self detailViewComponents:subView];
    }
}

- (void)configureView
{
    //create the text view
    _textView = [[CNTextView alloc] initWithFrame:self.view.frame];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_textView];
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        _textView.text = [[self.detailItem valueForKey:@"text"] description];
    }
    
    [_textView setParentControl:self];
    
    tagViews = [NSMutableArray new];
    
    UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 500, self.view.bounds.size.width, 40) collectionViewLayout:flow];
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.detailItem setValue:[_textView text] forKey:@"text"];
    [self.context save:nil];
    
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


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
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
    
    CGFloat width = [tag.field.text sizeWithFont:tag.field.font].width + 5;
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
    
    
    CGFloat width = [changing.field.text sizeWithFont:changing.field.font].width + 35;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
}

-(void)tagViewEditing:(NSNotification*)notification{
    CNTagView * changing = notification.object;
    UICollectionViewCell * cell = ( UICollectionViewCell *)[changing superview];
    
    
    CGFloat width = [changing.field.text sizeWithFont:changing.field.font].width + 35;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
}

-(void)tagViewEndEditing:(NSNotification*)notification{
    CNTagView * changing = notification.object;
    UICollectionViewCell * cell = ( UICollectionViewCell *)[changing superview];
    
    CGFloat width = [changing.field.text sizeWithFont:changing.field.font].width + 5;
    CGRect rect = cell.frame;
    rect.size.width = width;
    [cell setFrame:rect];
    
    if([changing.name length]){
        //it is real, add another tag view
        
        CNTagView * blankTag = [[CNTagView alloc] initWithFrame:CGRectMake(0, 0, 45, kTagHeight) withName:nil];
        [tagViews addObject:blankTag];
        
        [_tagCollectionView reloadData];
    }
}


@end
