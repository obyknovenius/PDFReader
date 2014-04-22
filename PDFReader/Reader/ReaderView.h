//
//  ReaderView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 01.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ReaderViewEditingModeNone,
    ReaderViewEditingModeText,
    ReaderViewEditingModeRedPen
} ReaderViewEditingMode;

@class AnnotationStore;

@protocol ReaderViewDataSource;

@interface ReaderView : UIScrollView

@property (nonatomic, weak) id <ReaderViewDataSource> dataSource;

@property (nonatomic, readonly) NSMutableArray *visibleViews;
@property (nonatomic, readonly) UIView *containerView;

- (UIView *)viewAtIndex:(NSUInteger)index;
- (NSUInteger)indexForView:(UIView *)view;

@end

@protocol ReaderViewDataSource <NSObject>

- (NSUInteger)numberOfPagesInReaderView:(ReaderView *)readerView;
- (UIView *)readerView:(ReaderView *)readerView viewForPageAtIndex:(NSUInteger)index;
- (CGFloat)readerView:(ReaderView *)readerView heightOfPageAtIndex:(NSUInteger)index forWidth:(CGFloat)width;

@end