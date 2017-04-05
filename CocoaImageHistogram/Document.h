//
//  Document.h
//  CocoaImageHistogram
//
//  Created by Gavin Baker on 14/3/17.
//  Copyright © 2017, BSD Licensed
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument
{
    NSImage*                _image;
    IBOutlet NSImageView*   _imageView;
    unsigned                _histogram[3][256];
}

@property (copy) NSImage* image;

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController;

- (void)updateImageData;
- (void)clearHistogram;
- (void)computeHistogramFromBitmap:(CGContextRef)bitmap;

@end
