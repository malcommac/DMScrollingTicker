//
//  DMScrollingTicker.m
//
//  Created by Daniele Margutti on 5/15/12.
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//      Email:      daniele.margutti@gmail.com
//      Website:    http://www.danielem.org
//      License:    MIT License
//                  Put this line in your about box: 'Portions LPScrollingTicker by Daniele Margutti http://www.danielem.org'


#import "DMScrollingTicker.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - LPScrollingTicker

// Space between each subview item
#define kLPScrollingTickerHSpace                2.0f
// Default animation speed
#define kLPScrollingAnimationPixelsPerSecond    50.0f

@interface DMScrollingTicker() <UIScrollViewDelegate> {
    UIScrollView*                               scrollView;                         // scrolling ticker
    NSMutableArray*                             tickerSubViews;                     // preloaded subviews (if any)
    NSMutableArray*                             tickerSubviewsFrames;               // preloaded subviews frame (valid both for standard/lazy loading)
    BOOL                                        isAnimating;                        // YES if an animation is in progress
    NSUInteger                                  numberOfLoops;                      // number of loops to made
    LPScrollingDirection                        scrollViewDirection;                // scroll direction of the ticker
    CGFloat                                     scrollViewSpeed;                    // speed of the scroll in pixels/second
    NSUInteger                                  loopsDone;                          // number of loops made since the animation was started
    

    CADisplayLink*                              displayLink;                        // used to sync lazy drawing
    
    // Blocks handlers
    LPScrollingTickerLazyLoadingHandler         lazyLoadingHandler;
    LPScrollingTickerAnimationCompletition      animationCompletitionHandler;
}

- (void) layoutTickerSubviewsWithItems:(NSArray *) itemsToLoad;
- (void) layoutTickerSubviewsWithItemSizes:(NSArray *) frameSizes;

- (void) pauseLayer:(CALayer *)layer;
- (void) resumeLayer:(CALayer *)layer;

- (void) beginAnimation;
- (CGPoint) startOffset;

@end

@implementation DMScrollingTicker

@synthesize isAnimating;
@synthesize contentSize,visibleContentRect;
@synthesize loopsDone;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        scrollViewDirection = LPScrollingDirection_FromRight;
        numberOfLoops = 0; // infinite scrolling = 0
        
        isAnimating = NO;
        tickerSubViews = nil;
        tickerSubviewsFrames = nil;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        self.backgroundColor = [UIColor clearColor];
        scrollView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) beginAnimationWithViews:(NSArray *) subviewsItems {
    [self beginAnimationWithViews:subviewsItems
                        direction:LPScrollingDirection_FromRight
                            speed:0
                            loops:0
                     completition:^(NSUInteger loopsDone, BOOL isFinished) {}];
}

- (void) beginAnimationWithViews:(NSArray *) views
                       direction:(LPScrollingDirection) scrollDirection
                           speed:(CGFloat) scrollSpeed
                           loops:(NSUInteger) loops
                    completition:(LPScrollingTickerAnimationCompletition) completition {
    
    if (isAnimating) [self endAnimation:NO];
    
    lazyLoadingHandler = nil;
    animationCompletitionHandler = completition;
    numberOfLoops = loops;
    scrollViewDirection = scrollDirection;
    scrollViewSpeed = (scrollSpeed == 0 ? kLPScrollingAnimationPixelsPerSecond : scrollSpeed);
    
    if (displayLink) {
        // Display link is used to catch the current visible area of the scrolling view during the animation
        [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        displayLink = nil;
    }
    
    [self layoutTickerSubviewsWithItems:views];
    [self beginAnimation];
}

- (void) beginAnimationWithLazyViews:(LPScrollingTickerLazyLoadingHandler) dataSource
                          itemsSizes:(NSArray *) subviewsSizes
                           direction:(LPScrollingDirection) scrollDirection
                               speed:(CGFloat) scrollSpeed
                               loops:(NSUInteger) loops
                        completition:(LPScrollingTickerAnimationCompletition) completition {
    
    if (isAnimating) [self endAnimation:NO];
    
    lazyLoadingHandler = dataSource;
    animationCompletitionHandler = completition;
    numberOfLoops = loops;
    scrollViewDirection = scrollDirection;
    scrollViewSpeed = (scrollSpeed == 0 ? kLPScrollingAnimationPixelsPerSecond : scrollSpeed);

    displayLink = [CADisplayLink displayLinkWithTarget: self 
                                              selector: @selector(tickerDidScroll)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    
    [self layoutTickerSubviewsWithItemSizes:subviewsSizes];
    [self beginAnimation];
}

- (CGPoint) startOffset {
    CGPoint startOffset = CGPointZero;
    if (scrollViewDirection == LPScrollingDirection_FromRight)
        startOffset = CGPointMake(-scrollView.frame.size.width, 0);
    else if (scrollViewDirection == LPScrollingDirection_FromLeft)
        startOffset = CGPointMake(scrollView.contentSize.width, 0);
    return startOffset;
}

- (void) beginAnimation {
    if (isAnimating) return;
    [scrollView setContentOffset:[self startOffset]];
    
    isAnimating = YES;
    
    NSTimeInterval animationDuration = (scrollView.contentSize.width/scrollViewSpeed);
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGPoint finalPoint = CGPointZero;
                         
                         if (scrollViewDirection == LPScrollingDirection_FromRight)
                             finalPoint = CGPointMake(scrollView.contentSize.width, 0);
                         else if (scrollViewDirection == LPScrollingDirection_FromLeft)
                             finalPoint = CGPointMake(-scrollView.contentSize.width+scrollView.frame.size.width, 0);

                         scrollView.contentOffset = finalPoint;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             isAnimating = NO;
                             BOOL restartAnimation = (numberOfLoops == 0 || loopsDone <= numberOfLoops);
                             
                             animationCompletitionHandler((loopsDone+1),!restartAnimation);
                             
                             if (restartAnimation)
                                 [self beginAnimation];
                             else
                                 [self endAnimation:NO];
                            
                             loopsDone++;
                         }
                     }];
}

- (void) endAnimation:(BOOL) animated {
    if (!isAnimating) return;
    isAnimating = NO;
    loopsDone = 0;
    
    [self pauseLayer:scrollView.layer];
    [self scrollToStart:animated];
}

- (void) pauseAnimation {
    if (!isAnimating) return;
    isAnimating = NO;
    [self pauseLayer:scrollView.layer];
}

- (void) resumeAnimation {
    if (isAnimating) return;
    isAnimating = YES;
    [self resumeLayer:scrollView.layer];
}

- (void) scrollToOffset:(CGPoint) offsetPoint animate:(BOOL) animated {
    [self endAnimation:NO];
    [scrollView setContentOffset:offsetPoint animated:animated];
}

- (void) scrollToStart:(BOOL) animated {
    [self endAnimation:NO];
    [scrollView setContentOffset:[self startOffset] animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (CGSize) contentSize {
    return scrollView.contentSize;
}

- (void) layoutTickerSubviewsWithItemSizes:(NSArray *) frameSizes {
    tickerSubViews = [[NSMutableArray alloc] init];
    tickerSubviewsFrames = [[NSMutableArray alloc] init];
    
    CGSize scrollingContentSize = CGSizeZero;
    
    CGFloat offsetX = 0.0f;
    for (NSValue *itemSize in frameSizes) {
        CGRect itemFrame = CGRectMake(offsetX,
                                      0,
                                      [itemSize CGSizeValue].width,
                                      [itemSize CGSizeValue].height);
        [tickerSubviewsFrames addObject:[NSValue valueWithCGRect:itemFrame]];
        [tickerSubViews addObject:[NSNull null]];
        
        CGFloat itemWidth = ([itemSize CGSizeValue].width+kLPScrollingTickerHSpace);
        scrollingContentSize.width +=+itemWidth;
        scrollingContentSize.height = MAX(scrollingContentSize.height,[itemSize CGSizeValue].height);
        
        offsetX += itemWidth;
    }
    [scrollView setContentSize:scrollingContentSize];
}

- (void) layoutTickerSubviewsWithItems:(NSArray *) itemsToLoad {
    tickerSubViews = nil;
    tickerSubviewsFrames = [[NSMutableArray alloc] init];

    CGSize scrollingContentSize = CGSizeZero;    
    CGFloat offsetX = 0.0f;
    for (UIView *itemView in itemsToLoad) {
        [itemView layoutSubviews]; // get the correct bounds for this subview
        CGRect itemFrame = CGRectMake(offsetX,
                                      0,
                                      itemView.frame.size.width,
                                      itemView.frame.size.height);
        [tickerSubviewsFrames addObject:[NSValue valueWithCGRect:itemFrame]];
      //  [tickerSubViews addObject:itemView];
        
        // calculate content size
        CGFloat itemWidth = (itemView.frame.size.width+kLPScrollingTickerHSpace);
        scrollingContentSize.width +=+itemWidth;
        scrollingContentSize.height = MAX(scrollingContentSize.height,itemView.frame.size.height);
        offsetX += itemWidth;
        
        itemView.frame = itemFrame;
        [scrollView addSubview:itemView];
    }
    [scrollView setContentSize:scrollingContentSize];
}

- (CGRect) visibleContentRect {
    CGRect visibleRect;
    // it returns the correct value while the scrollview is animating (simple scrollView.contentOffset will return a wrong value)
    visibleRect.origin = [scrollView.layer.presentationLayer bounds].origin;
    visibleRect.size = scrollView.frame.size;
    return visibleRect;
}

- (void)tickerDidScroll {
    // This method is used by lazy loading in order to check and load visible subviews and
    // remove the unused/not visible subviews.
    // This is not called when data loading mode = LPScrollingTickerDataLoading_PreloadSubviews
    NSUInteger k = 0;
    CGRect visibleRect = self.visibleContentRect;
    for (NSValue* itemFrame in tickerSubviewsFrames) {
        BOOL isVisible = CGRectIntersectsRect(visibleRect, [itemFrame CGRectValue]);

        UIView *targetView = lazyLoadingHandler(k);
        
        // this item will be now visible so we want to allocate it and insert into the subview
        if (isVisible && targetView.superview == nil) {
            targetView.frame = [itemFrame CGRectValue];
            [scrollView addSubview:targetView];
        } else if (isVisible == NO && targetView.superview != nil) {
            // item is not out of the visilble area so we can remove it/dealloc
            [targetView removeFromSuperview];
        }
        ++k;
    }
}

-(void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end


#pragma mark - LPScrollingTickerLabelItem


#define kLPScrollingTickerLabelItem_Title_Font          [UIFont boldSystemFontOfSize:14.0f]
#define kLPScrollingTickerLabelItem_Description_Font    [UIFont systemFontOfSize:14.0f]
#define kLPScrollingTickerLabelItem_Space               5.0f

@interface LPScrollingTickerLabelItem() {
    UILabel*       titleLabel;
    UILabel*       descriptionLabel;
}
@end

@implementation LPScrollingTickerLabelItem

@synthesize titleLabel;
@synthesize descriptionLabel;

- (id) initWithTitle:(NSString *) title description:(NSString *) description {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = kLPScrollingTickerLabelItem_Title_Font;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.numberOfLines = 1;
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.font = kLPScrollingTickerLabelItem_Description_Font;
        descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        descriptionLabel.numberOfLines = 1;
        
        descriptionLabel.backgroundColor = [UIColor clearColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:titleLabel];
        [self addSubview:descriptionLabel];
        
        titleLabel.text = title;
        descriptionLabel.text = description;
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"text='%@,%@' frame=%@",titleLabel.text,descriptionLabel.text,NSStringFromCGRect(self.frame)];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGSize bestSize_title = [titleLabel.text sizeWithFont:titleLabel.font
                                        constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)
                                            lineBreakMode:UILineBreakModeWordWrap];
    CGSize bestSize_subtitle = [descriptionLabel.text sizeWithFont:descriptionLabel.font
                                                 constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)
                                                     lineBreakMode:UILineBreakModeWordWrap];
    
    titleLabel.frame = CGRectMake(5, 0, bestSize_title.width, self.frame.size.height);
    descriptionLabel.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width+kLPScrollingTickerLabelItem_Space, 0, bestSize_subtitle.width, self.frame.size.height);
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              bestSize_title.width+kLPScrollingTickerLabelItem_Space+bestSize_subtitle.width+10, 
                              MAX(bestSize_title.height,bestSize_subtitle.height))];
}

@end