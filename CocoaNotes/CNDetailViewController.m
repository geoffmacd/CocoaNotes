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
    [self.view addSubview:_textView];
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        _textView.text = [[self.detailItem valueForKey:@"text"] description];
    }
    
    [_textView setParentControl:self];
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

@end
