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


@interface UIPagedScrollView : UIScrollView {
    id<UIPagedScrollViewDelegate> m_delegate;
    
    NSMutableArray  *m_pageViews;
    
    NSInteger       m_pageCount;
}

@property (nonatomic, assign) id<UIPagedScrollViewDelegate> delegate;

@property (nonatomic, strong)   NSMutableArray  *pageViews;
@property                       NSInteger       pageCount;

- (NSInteger)currentVisiblePage;
- (void)loadVisiblePages;
- (void)loadPage:(int)page;
- (void)purgePage:(int)page;

@end
