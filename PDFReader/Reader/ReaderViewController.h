//
//  ReaderViewController.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 11.03.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderViewController : UIViewController

@property (nonatomic, strong) UIColor *selectedButtonTintColor;

- (id)initWithURL:(NSURL *)fileURL;

@end
