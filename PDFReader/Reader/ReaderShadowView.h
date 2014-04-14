//
//  ReaderShadowView.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderShadowView : UIView

- (id)initWithFrame:(CGRect)frame containedView:(UIView *)containedView;

@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, readonly) UIView *containedView;

@property (nonatomic, readonly) CGFloat contentInset;

@end
