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

@property (nonatomic, strong) UIButton *changeOrientationButton;
@property (nonatomic) DAPagesScrollDirection scrollDirection;
@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollDirection = DAPagesScrollDirectionVertical;
    [self createPagesContainer];
    [self.pagesContainer didMoveToParentViewController:self];
    self.changeOrientationButton = [[UIButton alloc] initWithFrame:CGRectMake(210, 500, 100, 50)];
    [self.changeOrientationButton setTitle:@"Horizontal" forState:UIControlStateNormal];
    self.changeOrientationButton.backgroundColor = [UIColor blackColor];
    [self.changeOrientationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.changeOrientationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.changeOrientationButton addTarget:self action:@selector(changeOrientation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeOrientationButton];

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
}

- (void)createPagesContainer {
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pagesContainer.scrollDirection = self.scrollDirection;
    [self.view addSubview:self.pagesContainer.view];
}

- (void)changeOrientation {
    NSArray *copy = [self.pagesContainer.viewControllers copy];
    if(self.scrollDirection == DAPagesScrollDirectionHorizontal){
        [self.changeOrientationButton setTitle:@"Horizontal" forState:UIControlStateNormal];
        self.scrollDirection = DAPagesScrollDirectionVertical;
    } else {
        [self.changeOrientationButton setTitle:@"Vertical" forState:UIControlStateNormal];
        self.scrollDirection = DAPagesScrollDirectionHorizontal;
    }
    [self.pagesContainer.view removeFromSuperview];
    self.pagesContainer = nil;
    [self createPagesContainer];
    self.pagesContainer.viewControllers = copy;
    [self.view bringSubviewToFront:self.changeOrientationButton];
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



@end