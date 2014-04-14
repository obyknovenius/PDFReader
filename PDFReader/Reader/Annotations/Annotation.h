//
//  Annotation.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CustomAnnotationDrawingBlock)(CGContextRef);

@interface Annotation : NSObject

- (void)drawInContext:(CGContextRef) context;

@end

@interface CustomAnnotation : Annotation

@property (readwrite, copy) CustomAnnotationDrawingBlock block;
+ (id)customAnnotationWithBlock:(CustomAnnotationDrawingBlock)block;

@end;

@interface TextAnnotation : Annotation

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) UIFont *font;

+ (id)textAnnotationWithText:(NSString*)text inRect:(CGRect)rect withFont:(UIFont*)font;

@end

@interface PathAnnotation: Annotation

@property (nonatomic, assign) CGPathRef path;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) BOOL fill;
@property (nonatomic, assign) CGFloat lineWidth;

+ (id)pathAnnotationWithPath:(CGPathRef)path color:(CGColorRef)color fill:(BOOL)fill;
+ (id)pathAnnotationWithPath:(CGPathRef)path color:(CGColorRef)color lineWidth:(CGFloat)width fill:(BOOL)fill;

@end

