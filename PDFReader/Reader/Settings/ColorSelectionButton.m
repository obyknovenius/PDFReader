//
//  ColorSelectionButton.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 15.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ColorSelectionButton.h"

@implementation ColorSelectionButton

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = color;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [[UIColor blackColor] CGColor];
    } else {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

@end
