//
//  ReaderRedPenSettingsViewController.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 15.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderRedPenSettingsViewController.h"

#import "ColorSelectionButton.h"

@interface ReaderRedPenSettingsViewController ()

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *colorButtons;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISlider *slider;

@end

@implementation ReaderRedPenSettingsViewController

#pragma mark - Initialization

- (id)initWithLineWidth:(CGFloat)width lineColor:(UIColor *)color
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _lineWidth = width;
        _lineColor = color;
        
        _colors = @[[UIColor blackColor], [UIColor grayColor], [UIColor whiteColor],
                    [UIColor redColor], [UIColor greenColor], [UIColor blueColor],
                    [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor]];
    }
    return self;
}

#pragma mark - View lifecircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect sliderFrame = CGRectMake(10.0f, 10.0f, CGRectGetWidth(self.view.bounds) - 20.0f, 32.0f);
    self.slider = [[UISlider alloc] initWithFrame:sliderFrame];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.slider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    self.slider.minimumValue = 5.0f;
    self.slider.maximumValue = 15.0f;
    self.slider.value = self.lineWidth;
    
    self.slider.minimumValueImage = CircleWithRadius(2.5f, [self.lineColor CGColor]);
    self.slider.maximumValueImage = CircleWithRadius(7.5f, [self.lineColor CGColor]);
    
    [self.view addSubview:self.slider];
    
    NSMutableArray *colorButtons = [NSMutableArray arrayWithCapacity:[self.colors count]];
    for (int i = 0; i < [self.colors count]; i++) {
        UIColor *color = self.colors[i];
        
        CGRect colorButtonFrame = CGRectMake(i * 34.0f + 10.0f, 52.0f, 30.0f, 30.0f);
        ColorSelectionButton *colorButton = [[ColorSelectionButton alloc] initWithFrame:colorButtonFrame color:color];
        
        if ([color isEqual:self.lineColor]) {
            colorButton.selected = YES;
        }
        
        [colorButton addTarget:self action:@selector(colorSelectionButtonToggled:) forControlEvents:UIControlEventTouchUpInside];
        
        [colorButtons addObject:colorButton];
        [self.view addSubview:colorButton];
    }
    self.colorButtons = colorButtons;
}

#pragma mark - Actions

- (void)colorSelectionButtonToggled:(ColorSelectionButton *)sender
{
    if (!sender.selected) {
        NSUInteger prevIndex = [self.colors indexOfObject:self.lineColor];
        ColorSelectionButton *previousSelectedButton = self.colorButtons[prevIndex];
        previousSelectedButton.selected = NO;
        
        sender.selected = YES;
        NSUInteger newIndex = [self.colorButtons indexOfObject:sender];
        self.lineColor = [self.colors objectAtIndex:newIndex];
        
        self.slider.minimumValueImage = CircleWithRadius(2.5f, [self.lineColor CGColor]);
        self.slider.maximumValueImage = CircleWithRadius(7.5f, [self.lineColor CGColor]);
        
        if ([self.delegate respondsToSelector:@selector(readerRedPenSettingViewController:didSelectLineColor:)]) {
            [self.delegate readerRedPenSettingViewController:self didSelectLineColor:self.lineColor];
        }
    }
}

- (void)sliderChangeValue:(UISlider *)sender
{
    self.lineWidth = sender.value;
    
    if ([self.delegate respondsToSelector:@selector(readerRedPenSettingViewController:didSelectLineWidth:)]) {
        [self.delegate readerRedPenSettingViewController:self didSelectLineWidth:self.lineWidth];
    }
}

#pragma mark - Utils

UIImage *CircleWithRadius(CGFloat radius, CGColorRef color)
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2, radius * 2), NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, color);
    
    CGContextAddEllipseInRect(ctx, CGRectMake(0.0f, 0.0f, radius * 2, radius * 2));
    
    CGContextDrawPath(ctx, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end