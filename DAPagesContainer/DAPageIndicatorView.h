//
//  DAPageIndicatorView.h
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 Enum for defining the shape for the page indicator. Triangle by default as defined on the original component.
 */
typedef enum {
    PageIndicatorShapeTriangle,
    PageIndicatorShapeSquare
}PageIndicatorShape;

@interface DAPageIndicatorView : UIView

@property (strong, nonatomic) UIColor *color;

@property (nonatomic) PageIndicatorShape pageIndicatorShape;

@end
