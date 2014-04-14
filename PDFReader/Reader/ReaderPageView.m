//
//  ReaderPageView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderPageView.h"

#import "ReaderContentTile.h"

@interface ReaderPageView ()

@property (nonatomic) CGPDFPageRef page;

@property (nonatomic, assign) CGRect pageRect;

@property (nonatomic, readonly) CGFloat contentWidthScale;
@property (nonatomic, readonly) CGFloat contentHeightScale;

@end

@implementation ReaderPageView

+ (Class)layerClass
{
	return [ReaderContentTile class];
}

- (id)initWithFrame:(CGRect)frame page:(CGPDFPageRef)page
{
    if (self = [super initWithFrame:frame]) {
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

#pragma mark - Accessors

- (CGFloat)contentWidthScale
{
    return CGRectGetWidth(self.frame)/CGRectGetWidth(_pageRect);
}

- (CGFloat)contentHeightScale
{
    return CGRectGetHeight(self.frame)/CGRectGetHeight(_pageRect);
}

- (void)didMoveToWindow
{
	self.contentScaleFactor = 1.0f;
}

#pragma mark - Tiled layer delegate

- (void)drawRect:(CGRect)rect
{
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    // Fill the background with white
	CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
    
    // Flip the context so that the PDF page is rendered right side up.
	CGContextTranslateCTM(ctx, 0.0f, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    
    CGContextScaleCTM(ctx, self.contentWidthScale, self.contentHeightScale);

	CGContextDrawPDFPage(ctx, self.page); // Render the PDF page into the context
    
    CGContextRestoreGState(ctx);
}

@end
