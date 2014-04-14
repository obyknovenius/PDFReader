//
//  AnnotationStore.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "AnnotationStore.h"
#import "Annotation.h"

@interface AnnotationStore ()

//Array (by page number) of arrays (annotations for that page - each page is a queue (most recent at end)
@property (nonatomic, strong) NSArray *annotations;

@property (nonatomic, strong) NSMutableArray *pageNumbers;

@end

@implementation AnnotationStore

- (id)initWithPageCount:(int)pageCount
{
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:pageCount];
    for (int i = 0; i < pageCount; i++) {
        [tmp addObject:[NSMutableArray array]];
    }
    _annotations = [NSArray arrayWithArray:tmp];
    
    _pageNumbers = [NSMutableArray arrayWithCapacity:pageCount];
    
    return self;
}

- (void)addAnnotation:(Annotation*)annotation toPage:(int)page
{
    NSMutableArray *pageAnnotations = [self.annotations objectAtIndex:(page - 1)];
    //Each page is a queue, first annotation at 0
    [pageAnnotations addObject:annotation];
    
    [self.pageNumbers addObject:@(page)];
}

- (void)addPath:(CGPathRef)path withColor:(CGColorRef)color lineWidth:(CGFloat)width fill:(BOOL)fill toPage:(int)page
{
    [self addAnnotation:[PathAnnotation pathAnnotationWithPath:path color:color lineWidth:width fill:fill] toPage:page];
}

- (void)addPath:(CGPathRef)path withColor:(CGColorRef)color fill:(BOOL)fill toPage:(int)page
{
    [self addAnnotation:[PathAnnotation pathAnnotationWithPath:path color:color fill:fill] toPage:page];
}

- (void)addText:(NSString*)text inRect:(CGRect)rect withFont:(UIFont*)font toPage:(int)page {
    [self addAnnotation:[TextAnnotation textAnnotationWithText:text inRect:rect withFont:font] toPage:page];
}

- (void) addCustomAnnotationWithBlock:(CustomAnnotationDrawingBlock)block toPage:(int)page
{
    [self addAnnotation:[CustomAnnotation customAnnotationWithBlock:block] toPage:page];
}

- (void) addAnnotations:(AnnotationStore *)newAnnotations
{
    int count = (int)[self.annotations count];
    for (int page = 1; page <= count; page++) {
        NSMutableArray *pageAnnotations = [self.annotations objectAtIndex:(page - 1)];
        NSArray *otherAnnotations = [newAnnotations annotationsForPage:page];
        [pageAnnotations addObjectsFromArray:otherAnnotations];
        
        [self.pageNumbers addObject:@(page)];
    }
}

- (int)numberOfAnnotations
{
    return [self.pageNumbers count];
}

- (void)undoAnnotationOnPage:(int)page
{
    if (page - 1 >= [self.annotations count]) {
        return;
    }
    
    NSMutableArray* pageAnnotations = [self.annotations objectAtIndex:(page-1)];
    if ([pageAnnotations count] > 0) {
        [pageAnnotations removeLastObject];
    }
}

- (void)undo
{
    int lastPageNumber = [[self.pageNumbers lastObject] intValue];
    [self undoAnnotationOnPage:lastPageNumber];
    [self.pageNumbers removeLastObject];
}

- (void)empty
{
    int count = (int)[self.annotations count];
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [tmp addObject:[NSMutableArray array]];
    }
    self.annotations = [NSArray arrayWithArray:tmp];
}

- (NSArray*)annotationsForPage:(int)page
{
    if (page - 1 >= [self.annotations count]) {
        NSLog(@"We wanted index %d but only have %d items", page - 1 , (int)[self.annotations count]);
        return [NSArray array];
    }
    return [self.annotations objectAtIndex:(page-1)];
}

- (void)drawAnnotationsForPage:(int)page inContext:(CGContextRef)context
{
    NSArray *pageAnnotations = [self annotationsForPage:page];
    if (!pageAnnotations) {
        return;
    }
    for (Annotation *anno in pageAnnotations) {
        [anno drawInContext:context];
    }
}

@end
