//
//  ReaderScratchPadView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 10.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScratchPadViewModeText,
    ScratchPadViewModeDraw
} ScratchPadViewMode;

@protocol ReaderScratchPadDelegate;

@interface ReaderScratchPadView : UIView

@property (nonatomic, assign) ScratchPadViewMode mode;

@property (nonatomic, weak) id<ReaderScratchPadDelegate> delegate;

@end

@protocol ReaderScratchPadDelegate <NSObject>

@optional

- (CGFloat)lineWidth;
- (UIColor *)lineColor;

- (UIFont *)textFont;
- (UIColor *)textColor;

- (void)readerScratchPad:(ReaderScratchPadView *)scratchPad didDrawPath:(CGPathRef)path;
- (void)readerScratchPad:(ReaderScratchPadView *)scratchPad didDrawText:(NSString *)text inRect:(CGRect)rect;

@end