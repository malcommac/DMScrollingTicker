//
//  RSViewController.m
//  test
//
//  Created by malcom on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSViewController.h"
#import "DMScrollingTicker.h"

@interface RSViewController () {
    DMScrollingTicker *scrollingTicker;
}

- (IBAction)btn_stop:(id)sender;
- (IBAction)btn_resume:(id)sender;
- (IBAction)btn_goSite:(id)sender;

@end

@implementation RSViewController

- (IBAction)btn_stop:(id)sender {
    [scrollingTicker pauseAnimation];
}
- (IBAction)btn_resume:(id)sender {
    [scrollingTicker resumeAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scrollingTicker = [[DMScrollingTicker alloc] initWithFrame:CGRectMake(0, 170, 320, 18)];
    scrollingTicker.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:scrollingTicker];
    NSMutableArray *l = [[NSMutableArray alloc] init];
    NSMutableArray *sizes = [[NSMutableArray alloc] init];
    for (NSUInteger k = 0; k < 5; k++) {
        LPScrollingTickerLabelItem *label = [[LPScrollingTickerLabelItem alloc] initWithTitle:[NSString stringWithFormat:@"› Title %d:",k] 
                                                                                  description:[NSString stringWithFormat:@"Description %d",k]];
        [label layoutSubviews];
        [sizes addObject:[NSValue valueWithCGSize:label.frame.size]];
        [l addObject:label];
    }

    [scrollingTicker beginAnimationWithViews:l
                             direction:LPScrollingDirection_FromRight
                                 speed:0
                                 loops:2
                          completition:^(NSUInteger loopsDone, BOOL isFinished) {
                              NSLog(@"loop %d, finished? %d",loopsDone,isFinished); 
                          }];
    
    /*
    [scrollingTicker beginAnimationWithLazyViews:^UIView *(NSUInteger indexOfViewToShow) {
         return [l objectAtIndex:indexOfViewToShow];
    } itemsSizes:sizes direction:LPScrollingDirection_FromRight speed:0 loops:0 completition:^(BOOL isFinished) {
        
    }];*/
}

- (IBAction)btn_goSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.danielemargutti.com"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
