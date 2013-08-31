//
//  DAPageContainerScrollView.m
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAPagesContainer.h"

#import "DAPagesContainerTopBar.h"
#import "DAPageIndicatorView.h"


@interface DAPagesContainer () <DAPagesContainerTopBarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) DAPagesContainerTopBar *topBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak,   nonatomic) UIScrollView *observingScrollView;
@property (strong, nonatomic) DAPageIndicatorView *pageIndicatorView;

@property (          assign, nonatomic) BOOL shouldObserveContentOffset;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;

- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;

@end


@implementation DAPagesContainer
@synthesize pageItemsTitleColor = _pageItemsTitleColor;
@synthesize selectedPageItemTitleColor = _selectedPageItemTitleColor;
@synthesize topBarBackgroundColor = _topBarBackgroundColor;
@synthesize borderGlowColor = _borderGlowColor;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [self stopObservingContentOffset];
}

- (void)setUp
{
    _topBarHeight = 44.;
    _topBarBackgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    _pageIndicatorViewSize = CGSizeMake(17., 7.);
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldObserveContentOffset = YES;
        
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                     self.topBarHeight,
                                                                     CGRectGetWidth(self.view.frame),
                                                                     CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    [self startObservingContentOffsetForScrollView:self.scrollView];    

    self.topBar = [[DAPagesContainerTopBar alloc] initWithFrame:CGRectMake(0.,
                                                                           0.,
                                                                           CGRectGetWidth(self.view.frame),
                                                                           self.topBarHeight)];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.delegate = self;
    [self.view addSubview:self.topBar];

    self.pageIndicatorView = [[DAPageIndicatorView alloc] initWithFrame:CGRectMake(0.,
                                                                                   self.topBarHeight,
                                                                                   self.pageIndicatorViewSize.width,
                                                                                   self.pageIndicatorViewSize.height)];
    [self.view addSubview:self.pageIndicatorView];
    self.topBar.backgroundColor = self.pageIndicatorView.color = self.topBarBackgroundColor;
}

- (void)viewDidUnload
{
    [self stopObservingContentOffset];
    self.scrollView = nil;
    self.topBar = nil;
    self.pageIndicatorView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutSubviews];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    if (abs(self.selectedIndex - selectedIndex) <= 1) {
        [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
        if (selectedIndex == _selectedIndex) {
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        self.pageIndicatorView.center.y);
        }
        [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
             [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
         } completion:nil];
    } else {
        // This means we should "jump" over at least one view controller
        self.shouldObserveContentOffset = NO;
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);
        UIViewController *leftViewController = self.viewControllers[MIN(self.selectedIndex, selectedIndex)];
        UIViewController *rightViewController = self.viewControllers[MAX(self.selectedIndex, selectedIndex)];
        leftViewController.view.frame = CGRectMake(0., 0., self.scrollWidth, self.scrollHeight);
        rightViewController.view.frame = CGRectMake(self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollWidth, self.scrollHeight);
        
        CGPoint targetOffset;
        if (scrollingRight) {
            self.scrollView.contentOffset = CGPointZero;
            targetOffset = CGPointMake(self.scrollWidth, 0.);
        } else {
            self.scrollView.contentOffset = CGPointMake(self.scrollWidth, 0.);
            targetOffset = CGPointZero;
            
        }
        [self.scrollView setContentOffset:targetOffset animated:YES];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        self.pageIndicatorView.center.y);
            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
            [previosSelectdItem setTitleColor:self.pageItemsTitleColor forState:UIControlStateNormal];
            [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
                UIViewController *viewController = self.viewControllers[i];
                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
                [self.scrollView addSubview:viewController.view];
            }
            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
            self.scrollView.userInteractionEnabled = YES;
            self.shouldObserveContentOffset = YES;
        }];
    }
    _selectedIndex = selectedIndex;
}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setPageIndicatorViewSize:(CGSize)size
{
    if (!CGSizeEqualToSize(self.pageIndicatorView.frame.size, size)) {
        _pageIndicatorViewSize = size;
        [self layoutSubviews];
    }
}

- (void)setPageItemsTitleColor:(UIColor *)pageItemsTitleColor
{
    if (![_pageItemsTitleColor isEqual:pageItemsTitleColor]) {
        _pageItemsTitleColor = pageItemsTitleColor;
        self.topBar.itemTitleColor = pageItemsTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedPageItemTitleColor:(UIColor *)selectedPageItemTitleColor
{
    if (![_selectedPageItemTitleColor isEqual:selectedPageItemTitleColor]) {
        _selectedPageItemTitleColor = selectedPageItemTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    _topBarBackgroundColor = topBarBackgroundColor;
    self.topBar.backgroundColor = topBarBackgroundColor;
    self.pageIndicatorView.color = topBarBackgroundColor;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setBorderGlowColor:(UIColor *)borderGlowColor {
  _borderGlowColor = borderGlowColor;
  self.topBar.layer.shadowColor = _borderGlowColor.CGColor;
  self.topBar.layer.shadowOffset = CGSizeZero;
  self.topBar.layer.shadowRadius = 4.0f;
  self.topBar.layer.shadowOpacity = 1.0f;
  
  self.pageIndicatorView.layer.shadowColor = _borderGlowColor.CGColor;
  self.pageIndicatorView.layer.shadowOffset = CGSizeMake(0, 3);
  self.pageIndicatorView.layer.shadowRadius = 4.0f;
  self.pageIndicatorView.layer.shadowOpacity = 1.0f;
}

- (UIFont *)topBarItemLabelsFont {
  return self.topBar.font;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        for (UIViewController *viewController in viewControllers) {
            [viewController willMoveToParentViewController:self];
            viewController.view.frame = CGRectMake(0., 0., CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            [viewController didMoveToParentViewController:self];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    self.pageIndicatorView.center.y);
    }
}

#pragma mark - Private

- (void)layoutSubviews
{
    self.topBar.frame = CGRectMake(0., 0., CGRectGetWidth(self.view.bounds), self.topBarHeight);
    self.pageIndicatorView.frame = CGRectMake(0.,
                                              self.topBarHeight,
                                              self.pageIndicatorViewSize.width,
                                              self.pageIndicatorViewSize.height);
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize = CGSizeMake(x, self.scrollHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0.) animated:YES];
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                self.pageIndicatorView.center.y);
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    self.scrollView.userInteractionEnabled = YES;
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - self.topBarHeight;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

#pragma mark - DAPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DAPagesContainerTopBar *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
                       context:(void *)context
{
 
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            
        
            
            CGFloat red, green, blue, alpha, highlightedRed, highlightedGreen, highlightedBlue, highlightedAlpha;
            [self getRed:&red green:&green blue:&blue alpha:&alpha fromColor:self.pageItemsTitleColor];
            [self getRed:&highlightedRed green:&highlightedGreen blue:&highlightedBlue alpha:&highlightedAlpha fromColor:self.selectedPageItemTitleColor];
            
            CGFloat absRatio = fabsf(ratio);
            UIColor *prev = [UIColor colorWithRed:red * absRatio + highlightedRed * (1 - absRatio)
                                            green:green * absRatio + highlightedGreen * (1 - absRatio)
                                             blue:blue * absRatio + highlightedBlue  * (1 - absRatio)
                                            alpha:alpha * absRatio + highlightedAlpha  * (1 - absRatio)];
            UIColor *next = [UIColor colorWithRed:red * (1 - absRatio) + highlightedRed * absRatio
                                            green:green * (1 - absRatio) + highlightedGreen * absRatio
                                             blue:blue * (1 - absRatio) + highlightedBlue * absRatio
                                            alpha:alpha * (1 - absRatio) + highlightedAlpha * absRatio];
            
            [previosSelectedItem setTitleColor:prev forState:UIControlStateNormal];
            [nextSelectedItem setTitleColor:next forState:UIControlStateNormal];

            
            
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                        (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            self.pageIndicatorView.center.y);
  
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                        (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            self.pageIndicatorView.center.y);
            }
        }
    }
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    if (colorSpaceModel == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    } else if (colorSpaceModel == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *red = *green = *blue = components[0];
        *alpha = components[1];
    } else {
        *red = *green = *blue = *alpha = 0;
    }
}

@end