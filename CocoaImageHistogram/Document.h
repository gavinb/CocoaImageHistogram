//
//  Document.h
//  CocoaImageHistogram
//
//  Created by Gavin Baker on 14/3/17.
//  Copyright © 2017 Briar Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument
{
    NSImage*                _image;
    IBOutlet NSImageView*   _imageView;
    unsigned                _histogram[256];
}

@property (copy) NSImage* image;

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController;

- (void)updateImageData;
- (void)computeHistogramFromBitmap:(CGContextRef)bitmap;

@end
