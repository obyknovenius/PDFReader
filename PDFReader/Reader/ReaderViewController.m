//
//  ReaderViewController.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 11.03.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderViewController.h"
#import "ReaderRedPenSettingsViewController.h"
#import "ReaderTextSettingsViewController.h"

#import "ReaderView.h"
#import "ReaderAnnotatedPageView.h"
#import "ReaderShadowView.h"
#import "ReaderScratchPadView.h"
#import "ReaderAnnotationView.h"

#import "ReaderDocument.h"
#import "AnnotationStore.h"

typedef enum : NSUInteger {
    AnnotationModeNone,
    AnnotationModeText,
    AnnotationModeRedPen,
} AnnotationMode;

@interface ReaderViewController () <UIScrollViewDelegate, UIPopoverControllerDelegate, ReaderViewDataSource, ReaderScratchPadDelegate, ReaderRedPenSettingsDelegate, ReaderTextSettingsDelegate>

@property (nonatomic, strong) ReaderDocument *document;

@property (nonatomic, strong) AnnotationStore *tempAnnotationStore;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, strong) ReaderView *contentView;
@property (nonatomic, strong) NSArray *scratchPadViews;
@property (nonatomic, strong) NSArray *annotationViews;

@property (nonatomic, assign) AnnotationMode annotationMode;

@property (nonatomic, strong) UIBarButtonItem *redPenButton;
@property (nonatomic, strong) UIBarButtonItem *textButton;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;

@property (nonatomic, strong) UIBarButtonItem *undoButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIBarButtonItem *saveButton;

@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ReaderViewController

#pragma mark - Initialization

- (id)initWithURL:(NSURL *)fileURL
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        _document = [[ReaderDocument alloc] initWithURL:fileURL];
        self.title = [fileURL lastPathComponent];
        
        _lineColor = [UIColor redColor];
        _lineWidth = 5.0f;
        
        _fontName = @"Helvetica";
        _fontSize = 17.0f;
        _textColor = [UIColor blackColor];
        
        _selectedButtonTintColor = [UIColor blackColor];
    }
    
    return self;
}

#pragma mark - View lifecircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    self.contentView = [[ReaderView alloc] initWithFrame:self.view.bounds];
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];
    
    self.redPenButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RedPen"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(redPenButtonTapped:)];
    
    self.textButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Text"]
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(textButtonTapped:)];
    
    self.settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"]
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(settingsButtonTapped:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(doneButtonTapped:)];
    
    self.undoButton = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(undoButtonTapped:)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(saveButtonTapped:)];
    
    self.navigationItem.rightBarButtonItems = @[self.redPenButton, self.textButton];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(keyboardFrame), 0.0f);
    self.contentView.contentInset = contentInsets;
    self.contentView.scrollIndicatorInsets = contentInsets;
    
    if (self.editingTextField) {
        CGRect textFieldFrame = [self.contentView convertRect:self.editingTextField.frame fromView:self.editingTextField.superview];
        textFieldFrame = CGRectInset(textFieldFrame, 0.0f, -8.0f);
        [self.contentView scrollRectToVisible:textFieldFrame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentView.contentInset = contentInsets;
    self.contentView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self finishEditing];
    
    UIColor *globalTint = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.redPenButton.tintColor = globalTint;
    self.textButton.tintColor = globalTint;
}

- (void)undoButtonTapped:(UIBarButtonItem *)sender
{
    [self.tempAnnotationStore undo];
    
    for (int i = 0; i < [self.contentView.visibleViews count]; i++) {
        ReaderShadowView *shadowView = [self.contentView.visibleViews objectAtIndex:i];
        NSUInteger pageNumber = [self.contentView indexForView:shadowView] + 1;
        
        ReaderAnnotationView *annotationView = [self.annotationViews objectAtIndex:i];
        annotationView.annotations = [self.tempAnnotationStore annotationsForPage:(int)pageNumber];
    }
}

- (void)redPenButtonTapped:(UIBarButtonItem *)sender
{
    if (self.annotationMode == AnnotationModeNone) {
        [self beginEditing];
        
        self.navigationItem.leftBarButtonItems = @[self.doneButton, self.undoButton];
        self.navigationItem.rightBarButtonItems = @[self.redPenButton, self.textButton, self.settingsButton];

    }
    
    self.redPenButton.tintColor = self.selectedButtonTintColor;
    
    UIColor *globalTint = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.textButton.tintColor = globalTint;
    
    for (ReaderScratchPadView *scratchPadView in self.scratchPadViews) {
        scratchPadView.mode = ScratchPadViewModeDraw;
    }
    
    self.annotationMode = AnnotationModeRedPen;
}

- (void)textButtonTapped:(UIBarButtonItem *)sender
{
    if (self.annotationMode == AnnotationModeNone) {
        [self beginEditing];
        
        self.navigationItem.leftBarButtonItems = @[self.doneButton, self.undoButton];
        self.navigationItem.rightBarButtonItems = @[self.redPenButton, self.textButton, self.settingsButton];

    }
    
    self.textButton.tintColor = self.selectedButtonTintColor;
    
    UIColor *globalTint = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.redPenButton.tintColor = globalTint;
    
    for (ReaderScratchPadView *scratchPadView in self.scratchPadViews) {
        scratchPadView.mode = ScratchPadViewModeText;
    }
    
    self.annotationMode = AnnotationModeText;
}

- (void)settingsButtonTapped:(UIBarButtonItem *)sender
{
    if (self.annotationMode == AnnotationModeRedPen) {
        ReaderRedPenSettingsViewController *redPenSettings = [[ReaderRedPenSettingsViewController alloc] initWithLineWidth:self.lineWidth lineColor:self.lineColor];
        redPenSettings.delegate = self;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:redPenSettings];
        self.popover.popoverContentSize = CGSizeMake(320.0f, 92.0f);
    } else if (self.annotationMode == AnnotationModeText) {
        ReaderTextSettingsViewController *textSettings = [[ReaderTextSettingsViewController alloc] initWithFontName:self.fontName fontSize:self.fontSize fontColor:self.textColor];
        textSettings.delegate = self;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:textSettings];
        self.popover.popoverContentSize = CGSizeMake(320.0f, 312.0f);
    }
    
    self.popover.delegate = self;
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover.passthroughViews = nil;
}

- (void)saveButtonTapped:(UIBarButtonItem *)sender
{
    [self.document save];
    
    self.contentView.dataSource = self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    BOOL hidden = self.navigationController.navigationBarHidden;
    
    [self.navigationController setNavigationBarHidden:!hidden animated:YES];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark -

- (void)beginEditing
{
    self.tapGestureRecognizer.enabled = NO;
    
    self.contentView.pinchGestureRecognizer.enabled = NO;
    self.contentView.panGestureRecognizer.enabled = NO;
    self.contentView.delaysContentTouches = NO;
    
    NSMutableArray *scratchPadViews = [NSMutableArray arrayWithCapacity:[self.contentView.visibleViews count]];
    NSMutableArray *annotationViews = [NSMutableArray arrayWithCapacity:[self.contentView.visibleViews count]];
    
    for (ReaderShadowView *shadowView in self.contentView.visibleViews) {
        NSUInteger pageNumber = [self.contentView indexForView:shadowView] + 1;
        CGPDFPageRef page = [self.document pageAtNumber:pageNumber];
        
        ReaderAnnotationView *annotationView = [[ReaderAnnotationView alloc] initWithFrame:shadowView.containedView.frame page:page];
        annotationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [annotationViews addObject:annotationView];
        [shadowView.containerView addSubview:annotationView];
        
        ReaderScratchPadView *scratchPadView = [[ReaderScratchPadView alloc] initWithFrame:shadowView.containedView.frame];
        scratchPadView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        scratchPadView.delegate = self;
        
        [scratchPadViews addObject:scratchPadView];
        [shadowView.containerView addSubview:scratchPadView];
    }
    
    self.annotationViews = [annotationViews copy];
    self.scratchPadViews = [scratchPadViews copy];
    
    self.tempAnnotationStore = [[AnnotationStore alloc] initWithPageCount:(int)self.document.pageCount];
}

- (void)finishEditing
{
    self.tapGestureRecognizer.enabled = YES;
    
    self.contentView.pinchGestureRecognizer.enabled = YES;
    self.contentView.panGestureRecognizer.enabled = YES;
    self.contentView.delaysContentTouches = YES;
    
    for (UIView *annotationView in self.annotationViews) {
        [annotationView removeFromSuperview];
    }
    self.annotationViews = nil;
    
    for (UIView *scratchPadView in self.scratchPadViews) {
        [scratchPadView removeFromSuperview];
    }
    self.scratchPadViews = nil;
    
    if ([self.tempAnnotationStore numberOfAnnotations] > 0) {
        [self.document.annotationStore addAnnotations:self.tempAnnotationStore];
        
        for (ReaderShadowView *shadowView in self.contentView.visibleViews) {
            NSUInteger pageNumber = [self.contentView indexForView:shadowView] + 1;
            
            ReaderAnnotatedPageView *pageView = (ReaderAnnotatedPageView *)shadowView.containedView;
            pageView.annotations = [self.document.annotationStore annotationsForPage:(int)pageNumber];
        }
        
        self.navigationItem.leftBarButtonItems = @[self.saveButton];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
    }
    self.tempAnnotationStore = nil;
    
    self.annotationMode = AnnotationModeNone;
}

#pragma mark - Reader view data source

- (NSUInteger)numberOfPagesInReaderView:(ReaderView *)readerView
{
    return self.document.pageCount;
}

- (UIView *)readerView:(ReaderView *)readerView viewForPageAtIndex:(NSUInteger)index
{
    NSUInteger pageNumber = index + 1;
    CGPDFPageRef page = [self.document pageAtNumber:pageNumber];
    ReaderPageView *pageView = [[ReaderAnnotatedPageView alloc] initWithFrame:CGRectZero page:page];
    ReaderShadowView *shadowView = [[ReaderShadowView alloc] initWithFrame:self.view.bounds containedView:pageView];

    return shadowView;
}

- (CGFloat)readerView:(ReaderView *)readerView heightOfPageAtIndex:(NSUInteger)index forWidth:(CGFloat)width
{
    ReaderShadowView *shadowView = (ReaderShadowView *)[readerView viewAtIndex:index];
    CGFloat contentInset = shadowView.contentInset;
    
    width -= contentInset * 2;
    CGPDFPageRef page = [self.document pageAtNumber:index + 1];
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGFloat height = width / CGRectGetWidth(pageRect) * CGRectGetHeight(pageRect);
    height += contentInset * 2;
    
    return height;
}

#pragma mark - Reader scratch pad delegate

- (CGFloat)readerScratchPadLineWidth:(ReaderScratchPadView *)scratchPad
{
    return self.lineWidth;
}

- (UIColor *)readerScratchPadLineColor:(ReaderScratchPadView *)scratchPad
{
    return self.lineColor;
}

- (UIFont *)readerScratchPadTextFont:(ReaderScratchPadView *)scratchPad
{
    return [UIFont fontWithName:self.fontName size:self.fontSize];
}

- (UIColor *)readerScratchPadTextColor:(ReaderScratchPadView *)scratchPad
{
    return self.textColor;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField inReaderScratchPad:(ReaderScratchPadView *)scratchPad
{
    self.editingTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField inReaderScratchPad:(ReaderScratchPadView *)scratchPad
{
    self.editingTextField = nil;
}

- (void)readerScratchPad:(ReaderScratchPadView *)scratchPad didDrawPath:(CGPathRef)path fill:(BOOL)fill
{
    NSUInteger index = [self.scratchPadViews indexOfObject:scratchPad];
    
    ReaderShadowView *shadowView = [self.contentView.visibleViews objectAtIndex:index];
    
    NSUInteger pageNumber = [self.contentView indexForView:shadowView] + 1;
    CGPDFPageRef page = [self.document pageAtNumber:pageNumber];
    
    PathAnnotation *anno = [self pathAnnotationByTranslatingPath:path fromView:scratchPad toPDFPage:page fill:fill];
    [self.tempAnnotationStore addAnnotation:anno toPage:(int)pageNumber];
    
    ReaderAnnotationView *annotationView = [self.annotationViews objectAtIndex:index];
    annotationView.annotations = [self.tempAnnotationStore annotationsForPage:(int)pageNumber];
}

- (PathAnnotation *)pathAnnotationByTranslatingPath:(CGPathRef)path fromView:(UIView *)view toPDFPage:(CGPDFPageRef)page fill:(BOOL)fill
{
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGFloat widthScale = CGRectGetWidth(pageRect) / CGRectGetWidth(view.bounds);
    CGFloat heightScale = CGRectGetHeight(pageRect) / CGRectGetHeight(view.bounds);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(widthScale, heightScale);
    CGPathRef transformPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform);
    
    PathAnnotation *pathAnnotation = [PathAnnotation pathAnnotationWithPath:transformPath
                                                                      color:[self.lineColor CGColor]
                                                                  lineWidth:self.lineWidth * widthScale
                                                                       fill:fill];
    CGPathRelease(transformPath);
    
    return pathAnnotation;
}

- (void)readerScratchPad:(ReaderScratchPadView *)scratchPad didDrawText:(NSString *)text inRect:(CGRect)rect
{
    NSUInteger index = [self.scratchPadViews indexOfObject:scratchPad];
    
    ReaderShadowView *shadowView = [self.contentView.visibleViews objectAtIndex:index];
    
    NSUInteger pageNumber = [self.contentView indexForView:shadowView] + 1;
    CGPDFPageRef page = [self.document pageAtNumber:pageNumber];
    
    TextAnnotation *anno = [self textAnnotationByTranslatingText:text inRect:rect fromView:scratchPad toPDFPage:page];
    [self.tempAnnotationStore addAnnotation:anno toPage:(int)pageNumber];
    
    ReaderAnnotationView *annotationView = [self.annotationViews objectAtIndex:index];
    annotationView.annotations = [self.tempAnnotationStore annotationsForPage:(int)pageNumber];
}

- (TextAnnotation *)textAnnotationByTranslatingText:(NSString *)text inRect:(CGRect)rect fromView:(UIView *)view toPDFPage:(CGPDFPageRef)page
{
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGFloat widthScale = CGRectGetWidth(pageRect) / CGRectGetWidth(view.bounds);
    CGFloat heightScale = CGRectGetHeight(pageRect) / CGRectGetHeight(view.bounds);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(widthScale, heightScale);
    rect = CGRectApplyAffineTransform(rect, scaleTransform);
    
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
    font = [UIFont fontWithName:font.fontName size:font.pointSize * widthScale];
    
    TextAnnotation *textAnnotation = [TextAnnotation textAnnotationWithText:text inRect:rect withFont:font color:self.textColor];
    
    return textAnnotation;
}

#pragma mark - Reader red pen settings delegate

- (void)readerRedPenSettingViewController:(ReaderRedPenSettingsViewController *)controller didSelectLineWidth:(CGFloat)width
{
    self.lineWidth = width;
}

- (void)readerRedPenSettingViewController:(ReaderRedPenSettingsViewController *)controller didSelectLineColor:(UIColor *)color
{
    self.lineColor = color;
}

#pragma mark - Reader text settings delegate

- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectFontName:(NSString *)fontName
{
    self.fontName = fontName;
}

- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectFontSize:(CGFloat)fontSize
{
    self.fontSize = fontSize;
}

- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectTextColor:(UIColor *)color
{
    self.textColor = color;
}

#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView.containerView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    CGFloat contentScale = scale * [UIScreen mainScreen].scale; // Handle retina
    
    for (ReaderShadowView *shadowView in self.contentView.visibleViews) {
        ReaderAnnotatedPageView *pageView = (ReaderAnnotatedPageView *)shadowView.containedView;
        pageView.contentScaleFactor = contentScale;
    }
}

#pragma mark - Popover controller delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

@end