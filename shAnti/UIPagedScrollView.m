//
//  UIPagedScrollView.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "UIPagedScrollView.h"

@implementation UIPagedScrollView

@synthesize pageViews   = m_pageViews;
@synthesize pageCount   = m_pageCount;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<UIPagedScrollViewDelegate>)del
{
    m_delegate = del;
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pageCount = [self.delegate numberOfPagesInScrollView];
        
        self.pageViews = [[NSMutableArray alloc] init];                
        for (int i = 0; i < self.pageCount; ++i) {
            [self.pageViews addObject:[NSNull null]];
        }
        
        // First, set up the scroll view frame
        CGSize pagesScrollViewSize = self.frame.size;
        self.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageCount, pagesScrollViewSize.height);
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (NSInteger)currentVisiblePage {
    // Determine which page is currently visible
    CGFloat pageWidth = self.frame.size.width;
    NSInteger page = (NSInteger)floor((self.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    return page;
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageCount) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        
        CGRect frame = self.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        pageView = [self.delegate viewForPage:page];
        pageView.frame = frame;
        
        [self.pageViews replaceObjectAtIndex:page withObject:pageView];
    }
    
    [self addSubview:pageView];
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageCount) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages {
    // Determine which page is currently visible
    NSInteger page = [self currentVisiblePage];
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
	// Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
	// Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.pageCount; i++) {
        [self purgePage:i];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    [self loadVisiblePages];
}

@end
