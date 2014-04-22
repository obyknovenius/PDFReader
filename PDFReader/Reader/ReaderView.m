//
//  ReaderView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 01.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderView.h"

#import "AnnotationStore.h"

#define VISIBLE_PAGES_COUNT 3

@interface ReaderView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger firstVisiblePageIndex;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger numberOfVisisblePages;

@property (nonatomic, strong) NSMutableArray *visibleViews;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) BOOL needUpdateLayout;

@property (nonatomic, assign) CGFloat contentOffsetYPercentage;

@end

@implementation ReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.scrollsToTop = NO;
        self.maximumZoomScale = 10.0f;
        self.bouncesZoom = NO;
    }
    return self;
}

- (void)setDataSource:(id<ReaderViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self createVisibleViews];
}

- (void)createVisibleViews
{
    self.firstVisiblePageIndex = 0;
    self.numberOfPages = [self.dataSource numberOfPagesInReaderView:self];
    self.numberOfVisisblePages = MIN(self.numberOfPages, VISIBLE_PAGES_COUNT);
    
    if ([self.visibleViews count] > 0) {
        for (UIView *view in self.visibleViews) {
            [view removeFromSuperview];
        }
    }
    [self.containerView removeFromSuperview];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.containerView];
    
    self.visibleViews = [[NSMutableArray alloc] initWithCapacity:self.numberOfVisisblePages];
    for (NSInteger i = self.firstVisiblePageIndex; i < self.numberOfVisisblePages; i++) {
        UIView *pageView = [self.dataSource readerView:self viewForPageAtIndex:i];
        [self.containerView addSubview:pageView];
        [self.visibleViews addObject:pageView];
    }
    
    [self layoutVisibleViews];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGSizeEqualToSize(self.frame.size, frame.size)) {
        [self saveContentOffsetPercentage];
        self.needUpdateLayout = YES;
    }
    
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.needUpdateLayout) {
        [self restoreContentOffsetPercentage];
        [self layoutVisibleViews];
        
        self.needUpdateLayout = NO;
    }
    
    if (self.contentOffset.y >= self.contentSize.height - CGRectGetHeight(self.frame)) {
        if (self.firstVisiblePageIndex + self.numberOfVisisblePages == self.numberOfPages) {
            return;
        }
        
        self.firstVisiblePageIndex++;
        
        [self appendVisisbleView];
        [self layoutVisibleViews];
        
        UIView *lastView = [self.visibleViews lastObject];
        CGRect lastViewFrame = lastView.frame;
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentSize.height - CGRectGetHeight(self.frame) - CGRectGetHeight(lastViewFrame));
    }
    
    if (self.contentOffset.y <= 0) {
        if (self.firstVisiblePageIndex == 0) {
            return;
        }
        
        self.firstVisiblePageIndex--;
        
        [self prependVisibleView];
        [self layoutVisibleViews];
        
        UIView *firstView = [self.visibleViews firstObject];
        CGRect firstViewFrame = firstView.frame;
        self.contentOffset = CGPointMake(self.contentOffset.x, CGRectGetHeight(firstViewFrame));
    }
}

- (void)saveContentOffsetPercentage
{
    CGFloat contentOffsetRange = self.contentSize.height  - CGRectGetHeight(self.bounds);
    if (contentOffsetRange != 0) {
        self.contentOffsetYPercentage = self.contentOffset.y / contentOffsetRange;
    }
}

- (void)restoreContentOffsetPercentage
{
    CGPoint offset = CGPointMake(self.contentOffset.x,
                                 self.contentOffsetYPercentage * (self.contentSize.height - CGRectGetHeight(self.bounds)));
    self.contentOffset = offset;
}

- (void)appendVisisbleView
{
    // remove first view
    UIView *firstView = [self.visibleViews objectAtIndex:0];
    [firstView removeFromSuperview];
    [self.visibleViews removeObject:firstView];
    
    // add new view to the end
    NSInteger nextPage = self.firstVisiblePageIndex + self.numberOfVisisblePages - 1;
    UIView *view = [self.dataSource readerView:self viewForPageAtIndex:nextPage];
    
    [self.visibleViews addObject:view];
    [self.containerView addSubview:view];
}

- (void)prependVisibleView
{
    // remove last view
    UIView *lastView = [self.visibleViews lastObject];
    [lastView removeFromSuperview];
    [self.visibleViews removeObject:lastView];
    
    // add new view to the begin
    NSInteger previousPage = self.firstVisiblePageIndex;
    UIView *view = [self.dataSource readerView:self viewForPageAtIndex:previousPage];
    
    [self.visibleViews insertObject:view atIndex:0];
    [self.containerView addSubview:view];
}

- (void)layoutVisibleViews
{
    CGFloat totalHeight = 0;
    for (NSInteger i = 0; i < self.numberOfVisisblePages; i++) {
        UIView *pageView = [self.visibleViews objectAtIndex:i];
        
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = [self.dataSource readerView:self heightOfPageAtIndex:self.firstVisiblePageIndex + i forWidth:width];
        
        CGRect viewFrame = CGRectMake(0, totalHeight, width, height);
        
        pageView.frame = viewFrame;
        totalHeight += height;
    }
    
    self.containerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), totalHeight);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), totalHeight);
}

- (UIView *)viewAtIndex:(NSUInteger)index
{
    if (index < self.firstVisiblePageIndex || index > self.firstVisiblePageIndex + self.numberOfVisisblePages) {
        return nil;
    }
    
    return [self.visibleViews objectAtIndex:index - self.firstVisiblePageIndex];
}

- (NSUInteger)indexForView:(UIView *)view
{
    NSUInteger index = [self.visibleViews indexOfObject:view];
    if (index == NSNotFound) {
        return NSNotFound;
    }
    
    index += self.firstVisiblePageIndex;
    return index;
}

@end
