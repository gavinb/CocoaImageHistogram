//
//  Document.m
//  CocoaImageHistogram
//
//  Created by Gavin Baker on 14/3/17.
//  Copyright © 2017 Briar Studios. All rights reserved.
//

#import "Document.h"

@interface Document ()

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        for (unsigned i = 0; i <= 255; i++)
            _histogram[i] = 0;
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}


- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    _image = [[NSImage alloc] initWithContentsOfURL:url];
    if (!_image) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
        }
        return NO;
    }

    return YES;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {

    if (!_image)
        return;

    [_imageView setImage:_image];
    [self updateImageData];

    for (unsigned i = 0; i <= 255; i++)
        printf("%u %u\n", i, _histogram[i]);
}

- (void)updateImageData {

    if (!_image)
        return;

    // Dimensions - source image determines context size

    NSSize imageSize = _image.size;
    NSRect imageRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);

    // Create a context to hold the image data

    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             imageSize.width,
                                             imageSize.height,
                                             8,
                                             0,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedLast);

    // Wrap graphics context

    NSGraphicsContext* gctx = [NSGraphicsContext graphicsContextWithCGContext:ctx flipped:NO];

    // Make our bitmap context current and render the NSImage into it

    [NSGraphicsContext setCurrentContext:gctx];
    [_image drawInRect:imageRect];

    // Get a pointer to the raw image data

    // Calculate the histogram

    [self computeHistogramFromBitmap:ctx];
                        
    // Clean up

    [NSGraphicsContext setCurrentContext:nil];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
}

- (void)computeHistogramFromBitmap:(CGContextRef)bitmap {

    size_t width = CGBitmapContextGetWidth(bitmap);
    size_t height = CGBitmapContextGetHeight(bitmap);

    // Assume ARGB 8bpp
    uint32_t* imageBuffer = (uint32_t*)CGBitmapContextGetData(bitmap);

    uint32_t* pixel = imageBuffer;
    for (unsigned y = 0; y < height; y++)
    {
        for (unsigned x = 0; x < width; x++)
        {
            uint32_t abgr = *pixel;
            uint8_t red   = (abgr & 0x000000ff) >> 0;
            uint8_t green = (abgr & 0x0000ff00) >> 8;
            _histogram[red]++;
            pixel++;
        }
    }
}

@end
