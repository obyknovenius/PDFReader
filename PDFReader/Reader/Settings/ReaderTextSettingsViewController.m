//
//  ReaderTextSettingsViewController.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 15.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderTextSettingsViewController.h"

#import "ColorSelectionButton.h"

@interface ReaderTextSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *fontName;

@property (nonatomic, strong) NSArray *fontNames;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *colorButtons;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ReaderTextSettingsViewController

#pragma mark - Initialization

- (id)initWithFontName:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor *)color
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _fontName = fontName;
        
        _fontNames = @[@"ArialMT", @"Courier", @"Georgia", @"Helvetica", @"MarkerFelt-Thin"];
        _fontSize = 17.0f;
        
        _fontSize = fontSize;
        _textColor = color;
        
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
    
    CGRect tableViewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 220.0f);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.scrollEnabled = NO;
    
    [self.view addSubview:self.tableView];
    
    CGRect sliderFrame = CGRectMake(10.0f, 230.0f, CGRectGetWidth(self.view.bounds) - 20.0f, 32.0f);
    self.slider = [[UISlider alloc] initWithFrame:sliderFrame];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.slider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    self.slider.minimumValue = 10.0f;
    self.slider.maximumValue = 25.0f;
    self.slider.value = self.fontSize;
    
    self.slider.minimumValueImage = [UIImage imageNamed:@"SmallLetter"];
    self.slider.maximumValueImage = [UIImage imageNamed:@"BigLetter"];
    
    [self.view addSubview:self.slider];
    
    NSMutableArray *colorButtons = [NSMutableArray arrayWithCapacity:[self.colors count]];
    for (int i = 0; i < [self.colors count]; i++) {
        UIColor *color = self.colors[i];
        
        CGRect colorButtonFrame = CGRectMake(i * 34.0f + 10.0f, 272.0f, 30.0f, 30.0f);
        ColorSelectionButton *colorButton = [[ColorSelectionButton alloc] initWithFrame:colorButtonFrame color:color];
        
        if ([color isEqual:self.textColor]) {
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
        NSUInteger prevIndex = [self.colors indexOfObject:self.textColor];
        ColorSelectionButton *previousSelectedButton = self.colorButtons[prevIndex];
        previousSelectedButton.selected = NO;
        
        sender.selected = YES;
        NSUInteger newIndex = [self.colorButtons indexOfObject:sender];
        self.textColor = [self.colors objectAtIndex:newIndex];
        
        if ([self.delegate respondsToSelector:@selector(readerTextSettingViewController:didSelectTextColor:)]) {
            [self.delegate readerTextSettingViewController:self didSelectTextColor:self.textColor];
        }
    }
}

- (void)sliderChangeValue:(UISlider *)sender
{
    self.fontSize = sender.value;
    
    if ([self.delegate respondsToSelector:@selector(readerTextSettingViewController:didSelectFontSize:)]) {
        [self.delegate readerTextSettingViewController:self didSelectFontSize:self.fontSize];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fontNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    
    NSString *fontName = self.fontNames[indexPath.row];
    cell.textLabel.text = fontName;
    cell.textLabel.font = [UIFont fontWithName:fontName size:17.0f];
    
    if ([fontName isEqualToString:self.fontName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *font = self.fontNames[indexPath.row];
    if ([font isEqualToString:self.fontName]) {
        return;
    } else {
        NSUInteger prevIndex = [self.fontNames indexOfObject:self.fontName];
        NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:prevIndex inSection:0];
        UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:prevIndexPath];
        prevCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.fontName = font;
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if ([self.delegate respondsToSelector:@selector(readerTextSettingViewController:didSelectFontName:)]) {
            [self.delegate readerTextSettingViewController:self didSelectFontName:self.fontName];
        }
    }
}

@end