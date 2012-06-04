//
//  DMScrollingTicker.m
//
//  Created by Daniele Margutti on 5/15/12.
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//      Email:      daniele.margutti@gmail.com
//      Website:    http://www.danielem.org
//      License:    MIT License
//                  Put this line in your about box: 'Portions LPScrollingTicker by Daniele Margutti http://www.danielem.org'

/*
    DMScrollingTicker is an advanced horizontal scroll ticker class made in Objective-C for iOS.
    It doesn't use standard NSTimer to perform animations but instead Quartz Layers.
    It allows to load any set of UIView subclasses and add to the scrolling queue with a simple call.
    You can pick between two modes:
        - standard mode:    you will pass your list of UIViews and begin animation (all views will be adjusted and loaded at startup time)
        - lazy mode:        you will pass only UIView's CGSizes array and a datasource blocks handler and DMScrollingView will load each
                            view only when needed (and remove them when not used). It may be useful when you have lots of ticker elements
                            (here called subviews) and you pay attention to the memory usage
 */

#import <UIKit/UIKit.h>


// This is the scrolling ticker UIView's lazy loading data source handler. You must return the indexOfViewToShow UIView subclass to show
typedef UIView* (^LPScrollingTickerLazyLoadingHandler)(NSUInteger indexOfViewToShow);
// This is the handler called at the end of each loop.
typedef void (^LPScrollingTickerAnimationCompletition)(NSUInteger loopsDone, BOOL isFinished);


enum {
    LPScrollingDirection_FromLeft                   = 0,    // Animation starts from left and continues to the right side
    LPScrollingDirection_FromRight                  = 1     // Animation starts from right and continues back to the left side
}; typedef NSUInteger LPScrollingDirection;

@interface DMScrollingTicker : UIView {
    
}

@property (readonly)            BOOL                    isAnimating;            // YES if an animation is currently in progress
@property (readonly)            NSUInteger              loopsDone;              // Number of loops made since the beginning of the animation

@property (nonatomic,readonly)  CGSize                  contentSize;            // Total size of the scrolling content subviews
@property (readonly)            CGRect                  visibleContentRect;     // Currently visible content rect


// Allocation method
- (id)initWithFrame:(CGRect)frame;

/*
    Begin a new animation by loading subviews only when request and release them when not visible.
        - dataSource        =   You should return the correct indexOfViewToShow UIView subview inside the dataSource block handler.
        - subviewsSizes     =   Return an NSArray of NSValues (CGSize) contains the size of each element to show.
                                This is required to make a correct layout of the scroller before start the animation.
        - scrollDirection   =   Pick between LPScrollingDirection_FromLeft (animation starts from left and continues to the right side)
                                or LPScrollingDirection_FromRight (animation starts from right and continues back to the left side)
        - scrollSpeed       =   scrolling speed in pixels per second (0 = use defaults scrool speed, 50 p/s)
        - loops             =   The number of animations loops to make (0 means infinite)
        - completition      =   Called every when the animation ends a loop animation.
 */
- (void) beginAnimationWithLazyViews:(LPScrollingTickerLazyLoadingHandler) dataSource
                          itemsSizes:(NSArray *) subviewsSizes
                           direction:(LPScrollingDirection) scrollDirection
                               speed:(CGFloat) scrollSpeed
                               loops:(NSUInteger) loops
                        completition:(LPScrollingTickerAnimationCompletition) completition;

/*
    Begin a new animation using passed subviews items
        - subviewsItems     =   UIViews or any subclass you want to load inside the scrolling ticker
        - scrollDirection   =   Pick between LPScrollingDirection_FromLeft (animation starts from left and continues to the right side)
                                or LPScrollingDirection_FromRight (animation starts from right and continues back to the left side)
        - scrollSpeed       =   scrolling speed in pixels per second (0 = use defaults scrool speed, 50 p/s)
        - loops             =   The number of animations loops to make (0 means infinite)
        - completition      =   Called every when the animation ends a loop animation.
 */
- (void) beginAnimationWithViews:(NSArray *) subviewsItems
                       direction:(LPScrollingDirection) scrollDirection
                           speed:(CGFloat) scrollSpeed
                           loops:(NSUInteger) loops
                    completition:(LPScrollingTickerAnimationCompletition) completition;

/*
    Begin a new endless animation with scrollDirection = LPScrollingDirection_FromRight and default scroolSpeed
 */
- (void) beginAnimationWithViews:(NSArray *) subviewsItems;

// End an active animation and set the scroll 
- (void) endAnimation:(BOOL) animated;

// Pause an active animation
- (void) pauseAnimation;

// Resume a paused animation
- (void) resumeAnimation;

// Manual scrolling ticker offset value
- (void) scrollToOffset:(CGPoint) offsetPoint animate:(BOOL) animated;
- (void) scrollToStart:(BOOL) animated;

@end


// This is a an example of scrolling ticker subview. It's useful to show a title label + description label

@interface LPScrollingTickerLabelItem : UIView {
    
}

@property (readonly) UILabel *titleLabel;
@property (readonly) UILabel *descriptionLabel;

- (id) initWithTitle:(NSString *) title description:(NSString *) description;

@end