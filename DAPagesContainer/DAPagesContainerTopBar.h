//
//  DAPagesContainerTopBar.h
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DAPagesContainerTopBar;

@protocol DAPagesContainerTopBarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DAPagesContainerTopBar *)bar;

@end


@interface DAPagesContainerTopBar : UIView

@property (strong, nonatomic) NSArray *itemTitles;
@property (strong, nonatomic) UIFont *font;
@property (readonly, strong, nonatomic) NSArray *itemViews;
@property (readonly, strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<DAPagesContainerTopBarDelegate> delegate;

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;

@end