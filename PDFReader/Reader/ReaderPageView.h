//
//  ReaderPageView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationStore.h"

@interface ReaderPageView : UIView

- (id)initWithFrame:(CGRect)frame page:(CGPDFPageRef)page;

@end
