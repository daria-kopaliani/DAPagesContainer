//
//  DAPagesContainerTopBar.m
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAPagesContainerTopBar.h"


@interface DAPagesContainerTopBar (){
    CGFloat ofx ,ofy ,iw,ih;
    BOOL customItemFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *itemViews;

- (void)layoutItemViews;

@end


@implementation DAPagesContainerTopBar

CGFloat const DAPagesContainerTopBarItemViewWidth = 100.;
CGFloat const DAPagesContainerTopBarItemsOffset = 30.;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.font = [UIFont systemFontOfSize:14];
        self.itemTitleColor = [UIColor whiteColor];
        ofx = DAPagesContainerTopBarItemsOffset;
        ofy = 0;
        iw = DAPagesContainerTopBarItemViewWidth;
        ih = CGRectGetHeight(frame);
        
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    if (![_itemTitleColor isEqual:itemTitleColor]) {
        _itemTitleColor = itemTitleColor;
        for (UIButton *button in self.itemViews) {
            [button setTitleColor:itemTitleColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark * Overwritten setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemView];
            [itemView setTitle:itemTitles[i] forState:UIControlStateNormal];
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UIButton *itemView in self.itemViews) {
            [itemView.titleLabel setFont:font];
        }
    }
}

#pragma mark - Private

- (UIButton *)addItemView
{
    CGRect frame = CGRectMake(0., 0., iw, CGRectGetHeight(self.frame));
    UIButton *itemView = [[UIButton alloc] initWithFrame:frame];
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = self.font;
    [itemView setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
    [self.scrollView addSubview:itemView];
    return itemView;
}

- (void)itemViewTapped:(UIButton *)sender
{
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = ofx;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        CGFloat width = iw;
        if (!customItemFrame) {
             width = [self.itemTitles[i] sizeWithFont:self.font].width;
        }
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake(x, ofy, width, ih);
        x += width + ofx;
    }
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
    if (CGRectGetWidth(self.frame) > x) {
        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
        frame.size.width = x;
    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}
- (void)layoutItemWithSpecifyX:(float)offectX Y:(float)offectY w:(float)width h:(float)height{
    ofx = offectX;
    ofy = offectY;
    iw = width;
    ih = height;
    customItemFrame = YES;
    [self layoutItemViews];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}

#pragma mark * Lazy getters

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundImageView belowSubview:self.scrollView];
    }
    return _backgroundImageView;
}

@end