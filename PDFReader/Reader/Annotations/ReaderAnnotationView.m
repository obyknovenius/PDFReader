//
//  ReaderAnnotationView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderAnnotationView.h"

#import "Annotation.h"

@interface ReaderAnnotationView ()

@property (nonatomic) CGPDFPageRef page;

@property (nonatomic, readonly) CGRect pageRect;

@property (nonatomic, readonly) CGFloat contentWidthScale;
@property (nonatomic, readonly) CGFloat contentHeightScale;

@end

@implementation ReaderAnnotationView

- (id)initWithFrame:(CGRect)frame page:(CGPDFPageRef)page
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        
        if (page != NULL) {
            CGPDFPageRetain(page);
            _page = page;
            
            _pageRect = CGPDFPageGetBoxRect(self.page, kCGPDFMediaBox);
        } else {
            NSAssert(NO, @"CGPDFPageRef == NULL");
        }
    }
    return self;
}

- (void)dealloc
{
	CGPDFPageRelease(_page);
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    
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

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
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
