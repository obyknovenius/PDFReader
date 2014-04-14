//
//  AnnotationStore.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Annotation.h"

@interface AnnotationStore : NSObject

- (id)initWithPageCount:(int)pageCount;

- (void)addAnnotation:(Annotation*)annotation toPage:(int)page;
- (void)addPath:(CGPathRef)path withColor:(CGColorRef)color fill:(BOOL)fill toPage:(int)page;
- (void)addText:(NSString*)text inRect:(CGRect)rect withFont:(UIFont*)font toPage:(int)page;
- (void)addCustomAnnotationWithBlock:(CustomAnnotationDrawingBlock)block toPage:(int)page;

- (void)addAnnotations:(AnnotationStore*)annotations;

- (int)numberOfAnnotations;

- (void)undoAnnotationOnPage:(int)page;

- (NSArray*)annotationsForPage:(int)page;
- (void)drawAnnotationsForPage:(int)page inContext:(CGContextRef) context;

- (void)undo;
- (void)empty;

@end
