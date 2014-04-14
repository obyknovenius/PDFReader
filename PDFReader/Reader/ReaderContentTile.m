//
//  ReaderContentTile.m
//  PDFReader
//
//  Created by Vitaly Dyachkov on 13.04.14.
//  Copyright (c) 2014 Vitaly Dyachkov. All rights reserved.
//

#import "ReaderContentTile.h"

@implementation ReaderContentTile

#pragma mark Constants

#define LEVELS_OF_DETAIL 4
#define LEVELS_OF_DETAIL_BIAS 3

#pragma mark ReaderContentTile class methods

+ (CFTimeInterval)fadeDuration {
	return 0.001;
}

#pragma mark ReaderContentTile instance methods

- (id)init
{
	if ((self = [super init])) {
		self.levelsOfDetail = LEVELS_OF_DETAIL; // Zoom levels

		UIScreen *mainScreen = [UIScreen mainScreen]; // Main screen
		CGFloat screenScale = [mainScreen scale]; // Main screen scale
		self.levelsOfDetailBias = (screenScale > 1.0f) ? 1 : LEVELS_OF_DETAIL_BIAS;

		CGRect screenBounds = [mainScreen bounds]; // Main screen bounds
		CGFloat w_pixels = (screenBounds.size.width * screenScale);
		CGFloat h_pixels = (screenBounds.size.height * screenScale);
		CGFloat max = ((w_pixels < h_pixels) ? h_pixels : w_pixels);
		CGFloat sizeOfTiles = ((max < 512.0f) ? 512.0f : 1024.0f);
		self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
	}

	return self;
}

@end
