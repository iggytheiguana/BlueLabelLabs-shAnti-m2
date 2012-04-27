//
//  UIPagedScrollView.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIPagedScrollViewDelegate <UIScrollViewDelegate>
@required

- (NSInteger)numberOfPagesInScrollView;
- (UIView*)viewForPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end


@interface UIPagedScrollView : UIScrollView <UIScrollViewDelegate> {
    id<UIPagedScrollViewDelegate> m_delegate;
    
    NSMutableArray  *m_pageViews;
    
    NSInteger       m_pageCount;
    
    float           m_padding;
}

@property (nonatomic, assign)   id<UIPagedScrollViewDelegate> delegate;

@property (nonatomic, strong)   NSMutableArray  *pageViews;
@property                       NSInteger       pageCount;
@property                       float           padding;


- (UIView*)currentVisiblePageView;
- (NSInteger)currentVisiblePageIndex;
- (void)goToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)goToPageAtIndexWithObjects:(NSArray*)objects;
- (void)loadView;
- (void)loadVisiblePages;
- (void)loadPage:(int)page;
- (void)purgePage:(int)page;

@end
