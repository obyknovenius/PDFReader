//
//  ReaderAnnotationView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderAnnotationView : UIView

- (id)initWithFrame:(CGRect)frame page:(CGPDFPageRef)page;

@property (nonatomic, strong) NSArray *annotations;

@end
