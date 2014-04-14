//
//  ReaderAnnotatedPageView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 11.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderPageView.h"

@interface ReaderAnnotatedPageView : ReaderPageView

@property (nonatomic, strong) NSArray *annotations;

@end
