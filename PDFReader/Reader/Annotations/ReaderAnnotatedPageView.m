//
//  ReaderAnnotatedPageView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 11.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderAnnotatedPageView.h"

@interface ReaderAnnotatedPageView ()

@property (nonatomic, assign) CGRect pageRect;

@property (nonatomic, readonly) CGFloat contentWidthScale;
@property (nonatomic, readonly) CGFloat contentHeightScale;

@end

@implementation ReaderAnnotatedPageView

- (id)initWithFrame:(CGRect)frame page:(CGPDFPageRef)page
{
    if (self = [super initWithFrame:frame page:page]) {
        self.contentMode = UIViewContentModeRedraw;
        
        if (page != NULL) {
            _pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        } else {
            NSAssert(NO, @"CGPDFPageRef == NULL");
        }
    }
    return self;
}

#pragma mark - Accessors

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    
    self.layer.contents = nil;
    [self setNeedsDisplay];
}

- (CGFloat)contentWidthScale
{
    return CGRectGetWidth(self.frame)/CGRectGetWidth(_pageRect);
}

- (CGFloat)contentHeightScale
{
    return CGRectGetHeight(self.frame)/CGRectGetHeight(_pageRect);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    
    CGContextSaveGState(ctx);
    
    CGContextScaleCTM(ctx, self.contentWidthScale, self.contentHeightScale);
    
    if (self.annotations) {
        for (Annotation *anno in self.annotations) {
            [anno drawInContext:ctx];
        }
    }
    
    CGContextRestoreGState(ctx);
}

@end
