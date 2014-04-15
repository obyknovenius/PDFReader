//
//  ReaderRedPenSettingsViewController.h
//  PDFReader
//
//  Created by Vitaly Dyachkov on 15.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReaderRedPenSettingsDelegate;

@interface ReaderRedPenSettingsViewController : UIViewController

@property (nonatomic, weak) id<ReaderRedPenSettingsDelegate> delegate;

- (id)initWithLineWidth:(CGFloat)width lineColor:(UIColor *)color;

@end

@protocol ReaderRedPenSettingsDelegate <NSObject>

@optional

- (void)readerRedPenSettingViewController:(ReaderRedPenSettingsViewController *)controller didSelectLineWidth:(CGFloat)width;
- (void)readerRedPenSettingViewController:(ReaderRedPenSettingsViewController *)controller didSelectLineColor:(UIColor *)color;

@end