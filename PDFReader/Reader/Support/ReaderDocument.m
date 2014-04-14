//
//  ReaderDocument.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 01.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderDocument.h"

#import "AnnotationStore.h"

@interface ReaderDocument ()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) AnnotationStore *annotationStore;


@property (nonatomic, assign) CGPDFDocumentRef document;
@property (nonatomic, readwrite) NSInteger pageCount;

@end

@implementation ReaderDocument

- (id)initWithURL:(NSURL *)fileURL
{
    if (self = [super init]) {
        _fileURL = fileURL;
        
        CFURLRef docURLRef = (__bridge CFURLRef)_fileURL; // File URL
        _document = CGPDFDocumentCreateWithURL(docURLRef);
        
        if (self.document != NULL) { // Get the number of pages in the document
            _pageCount = CGPDFDocumentGetNumberOfPages(self.document);
        }
        
        _annotationStore = [[AnnotationStore alloc] initWithPageCount:(int)self.pageCount];
    }
    
    return self;
}

- (void)dealloc
{
    CGPDFDocumentRelease(self.document);
}

- (void)save
{
    CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.fileURL);
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:@"annotated.pdf"];
    //CGRectZero means the default page size is 8.5x11
    //We don't care about the default anyway, because we set each page to be a specific size
    UIGraphicsBeginPDFContextToFile(tempPath, CGRectZero, nil);
    
    //Iterate over each page - 1-based indexing (obnoxious...)
    int pages = (int)self.pageCount;
    for (int i = 0; i < pages; i++) {
        CGPDFPageRef page = CGPDFDocumentGetPage (doc, i + 1); // grab page i of the PDF
        CGRect bounds = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        
        //Create a new page
        UIGraphicsBeginPDFPageWithInfo(bounds, nil);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        // flip context so page is right way up
        CGContextTranslateCTM(context, 0, bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawPDFPage (context, page); // draw the page into graphics context
        
        //Annotations
        NSArray *annotations = [self.annotationStore annotationsForPage:i + 1];
        if (annotations) {
            //Flip back right-side up
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, 0, -bounds.size.height);
            
            for (Annotation *anno in annotations) {
                [anno drawInContext:context];
            }
        }
    }
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease (doc);
    
    [self.annotationStore empty];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if (![fileManager removeItemAtURL:self.fileURL error:&error]) {
        NSLog(@"Error occured while deleting file %@: %@", [self.fileURL lastPathComponent], [error localizedDescription]);
        return;
    }
    
    if (![[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:tempPath] toURL:self.fileURL error:&error]) {
        NSLog(@"Error occured while replacing file %@: %@", [self.fileURL lastPathComponent], [error localizedDescription]);
        return;
    }
    
    CGPDFDocumentRelease(self.document);
    CFURLRef docURLRef = (__bridge CFURLRef)self.fileURL; // File URL
    self.document = CGPDFDocumentCreateWithURL(docURLRef);
}

- (CGPDFPageRef)pageAtNumber:(NSUInteger)number
{
    return CGPDFDocumentGetPage(self.document, number);
}

@end