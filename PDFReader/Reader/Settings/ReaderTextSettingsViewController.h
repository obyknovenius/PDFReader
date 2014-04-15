//
//  ReaderTextSettingsViewController.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 15.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReaderTextSettingsDelegate;

@interface ReaderTextSettingsViewController : UIViewController

@property (nonatomic, weak) id<ReaderTextSettingsDelegate> delegate;

- (id)initWithFontName:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor *)color;

@end

@protocol ReaderTextSettingsDelegate <NSObject>

@optional

- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectFontName:(NSString *)fontName;
- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectFontSize:(CGFloat)fontSize;
- (void)readerTextSettingViewController:(ReaderTextSettingsViewController *)controller didSelectTextColor:(UIColor *)color;

@end