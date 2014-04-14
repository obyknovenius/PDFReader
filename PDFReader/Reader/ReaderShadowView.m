//
//  ReaderShadowView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderShadowView.h"

#define CONTENT_INSET 8.0f

@interface ReaderShadowView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containedView;

@end

@implementation ReaderShadowView

- (id)initWithFrame:(CGRect)frame containedView:(UIView *)containedView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect containerFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        containerFrame = CGRectInset(containerFrame, CONTENT_INSET, CONTENT_INSET);
        
        _containerView = [[UIView alloc] initWithFrame:containerFrame];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.containerView.layer.shadowRadius = 4.0f;
        self.containerView.layer.shadowOpacity = 1.0f;
        self.containerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.containerView.bounds] CGPath];
        
        _containedView = containedView;
        self.containedView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.containedView];
        
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect containerFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    containerFrame = CGRectInset(containerFrame, CONTENT_INSET, CONTENT_INSET);
    
    self.containerView.frame = containerFrame;
    self.containerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.containerView.bounds] CGPath];
    
    self.containedView.frame = self.containerView.bounds;
}

- (CGFloat)contentInset
{
    return CONTENT_INSET;
}

@end
