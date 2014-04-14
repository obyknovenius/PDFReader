//
//  ReaderDocument.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 01.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnnotationStore;

@interface ReaderDocument : NSObject

@property (nonatomic, readonly) NSInteger pageCount;
@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) AnnotationStore *annotationStore;

- (id)initWithURL:(NSURL *)fileURL;

- (void)save;

- (CGPDFPageRef)pageAtNumber:(NSUInteger)number;

@end
