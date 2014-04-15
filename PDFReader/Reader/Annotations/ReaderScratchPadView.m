//
//  ReaderScratchPadView.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 10.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderScratchPadView.h"

#define TEXTFIELD_WIDTH 300
#define TEXTFILED_HEIGHT 32

#define TEXTFIELD_PADDING 20

@interface ReaderScratchPadView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, assign) BOOL didMove;

@property (nonatomic, assign) CGFloat defaultLineWidth;
@property (nonatomic, strong) UIColor *defaultLineColor;

@property (nonatomic, strong) UIFont *defaultTextFont;
@property (nonatomic, strong) UIColor *defaultTextColor;

@end

@implementation ReaderScratchPadView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    _defaultLineWidth = 5.0f;
    _defaultLineColor = [UIColor redColor];
    
    _defaultTextFont = [UIFont systemFontOfSize:17.0f];
    _defaultTextColor = [UIColor blackColor];
    
    _mode = ScratchPadViewModeDraw;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, TEXTFIELD_WIDTH, TEXTFILED_HEIGHT)];
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.borderStyle = UITextBorderStyleLine;
    self.textField.hidden = YES;
    self.textField.delegate = self;
    [self addSubview:self.textField];
}

#pragma mark - Accessors

- (void)setMode:(ScratchPadViewMode)mode
{
    if (_mode == ScratchPadViewModeText) {
        self.textField.hidden = YES;
        self.textField.text = @"";
        [self.textField resignFirstResponder];
    }
    
    _mode = mode;
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    if (self.mode == ScratchPadViewModeText) {
        UIFont *font = self.defaultTextFont;
        UIColor *color = self.defaultTextColor;
        
        if ([self.delegate respondsToSelector:@selector(readerScratchPadTextFont:)]) {
            font = [self.delegate readerScratchPadTextFont:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(readerScratchPadTextColor:)]) {
            color = [self.delegate readerScratchPadTextColor:self];
        }
        
        self.textField.font = font;
        self.textField.textColor = color;
        
        if (self.textField.hidden) {
            [self.textField becomeFirstResponder];
        }
        
        if ([self.textField pointInside:[touch locationInView:self.textField] withEvent:event]) {
            [self.textField becomeFirstResponder];
        } else {
            self.textField.frame = CGRectMake(currentPoint.x + TEXTFIELD_PADDING, currentPoint.y, TEXTFIELD_WIDTH, TEXTFILED_HEIGHT);
        }
        
        self.textField.hidden = NO;
    } else if (self.mode == ScratchPadViewModeDraw) {
        self.path = CGPathCreateMutable();
        
        CGPathMoveToPoint(self.path, NULL, currentPoint.x, currentPoint.y);
        
        self.didMove = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.didMove = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    if (self.mode == ScratchPadViewModeText) {
        self.textField.frame = CGRectMake(currentPoint.x + TEXTFIELD_PADDING, currentPoint.y, TEXTFIELD_WIDTH, TEXTFILED_HEIGHT);
    } else if (self.mode == ScratchPadViewModeDraw) {
        CGPathAddLineToPoint(self.path, NULL, currentPoint.x, currentPoint.y);
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mode == ScratchPadViewModeText) {
        return;
    }
    
    if (!self.didMove) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        
        CGFloat lineWidth = self.defaultLineWidth;
        if ([self.delegate respondsToSelector:@selector(readerScratchPadLineWidth:)]) {
            lineWidth = [self.delegate readerScratchPadLineWidth:self];
        }
        
        CGPathAddEllipseInRect(self.path, NULL, CGRectMake(currentPoint.x - lineWidth / 2,
                                                           currentPoint.y - lineWidth / 2,
                                                           lineWidth,
                                                           lineWidth));
    }
    
    if ([self.delegate respondsToSelector:@selector(readerScratchPad:didDrawPath:fill:)]) {
        [self.delegate readerScratchPad:self didDrawPath:self.path fill:!self.didMove];
    }
    
    CGPathRelease(self.path);
    self.path = NULL;
    
    [self setNeedsDisplay];
}

#pragma mark -

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGFloat lineWidth = self.defaultLineWidth;
    if ([self.delegate respondsToSelector:@selector(readerScratchPadLineWidth:)]) {
        lineWidth = [self.delegate readerScratchPadLineWidth:self];
    }
        
    UIColor *lineColor = self.defaultLineColor;
    if ([self.delegate respondsToSelector:@selector(readerScratchPadLineColor:)]) {
        lineColor = [self.delegate readerScratchPadLineColor:self];
    }
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    
    CGContextAddPath(context, self.path);
    CGContextStrokePath(context);
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGRect textRect = CGRectInset(self.textField.frame, 2.0f, 4.0f);
    
    if ([self.delegate respondsToSelector:@selector(readerScratchPad:didDrawText:inRect:)]) {
        [self.delegate readerScratchPad:self didDrawText:self.textField.text inRect:textRect];
    }
    
    self.textField.hidden = YES;
    self.textField.text = @"";
    [self.textField resignFirstResponder];
    
    return YES;
}

@end
