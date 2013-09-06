//
//  DAViewController.m
//  DAPagesContainerDemo
//
//  Created by Daria Kopaliani on 5/30/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

@interface DAViewController ()

@property (strong, nonatomic) DAPagesContainer *pagesContainer;

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    
    UIViewController *beaverViewController = [[UIViewController alloc] init];
    UIImageView *beaverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beaver.jpg"]];
    beaverImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [beaverViewController.view addSubview:beaverImageView];
    beaverViewController.title = @"BEAVER";
    
    UIViewController *buckDeerViewController = [[UIViewController alloc] init];
    UIImageView *buckDeerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buckDeer.jpg"]];
    buckDeerImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [buckDeerViewController.view addSubview:buckDeerImageView];
    buckDeerViewController.title = @"BUCK DEER";
    
    UIViewController *catViewController = [[UIViewController alloc] init];
    UIImageView *catImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat.jpg"]];
    catImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [catViewController.view addSubview:catImageView];
    catViewController.title = @"CAT";
    
    UIViewController *lionViewController = [[UIViewController alloc] init];
    UIImageView *lionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lion.jpg"]];
    lionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [lionViewController.view addSubview:lionImageView];
    lionViewController.title = @"REALLY CUTE LION";

    self.pagesContainer.viewControllers = @[beaverViewController, buckDeerViewController, catViewController, lionViewController];
    
    self.pagesContainer.pageIndicatorViewSize = CGSizeMake(100.f, 3.f);
    self.pagesContainer.pageIndicatorColor = [UIColor redColor];
    self.pagesContainer.pageIndicatorShape = PageIndicatorShapeSquare;
    
    self.pagesContainer.delegate = self;
    
}

- (void)viewWillUnload
{
    self.pagesContainer = nil;
    [super viewWillUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pagesContainer updateLayoutForNewOrientation:toInterfaceOrientation];
}

-(void)itemAtIndex:(NSUInteger)index didSelectInPagesContainer:(DAPagesContainer *)container{
    NSLog(@"Selected intex: %d", index);
    
    switch (index) {
        case 0:
            self.pagesContainer.pageIndicatorViewSize = CGSizeMake(80.f, 3.f);
            break;
        case 1:
            self.pagesContainer.pageIndicatorViewSize = CGSizeMake(100.f, 3.f);
            break;
        case 2:
            self.pagesContainer.pageIndicatorViewSize = CGSizeMake(50.f, 3.f);
            break;
        default:
            self.pagesContainer.pageIndicatorViewSize = CGSizeMake(150.f, 3.f);
            break;
    }
    
}


@end