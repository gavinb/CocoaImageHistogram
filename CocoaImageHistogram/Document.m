//
//  Document.m
//  CocoaImageHistogram
//
//  Created by Gavin Baker on 14/3/17.
//  Copyright © 2017, BSD Licensed
//

#import "Document.h"

@interface Document ()

@end

#define kRedChannel     0
#define kGreenChannel   1
#define kBlueChannel    2

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        [self clearHistogram];
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}


- (NSString *)windowNibName {
    // Override returning the nib file name of the document If you
    // need to use a subclass of NSWindowController or if your
    // document supports multiple NSWindowControllers, you should
    // remove this method and override -makeWindowControllers instead.
    return @"Document";
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the
    // specified type. If outError != NULL, ensure that you create and
    // set an appropriate error when returning nil.  You can also
    // choose to override -fileWrapperOfType:error:,
    // -writeToURL:ofType:error:, or
    // -writeToURL:ofType:forSaveOperation:originalContentsURL:error:
    // instead.
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

    // Display and calculate
    [_imageView setImage:_image];
    [self updateImageData];

    // Dump histogram table in a format suitable for R plotting

    /*
     R Script:

        p <- read.table("hist.dat", h=T)
        plot(p$freq.red, type='l', col=1); lines(p$freq.green, col=2); lines(p$freq.blue, col=3)
     */

    printf("val freq.red freq.green freq.blue\n");
    for (unsigned i = 0; i <= 255; i++)
    {
        printf("%u %u %u %u\n",
               i,
               _histogram[kRedChannel][i],
               _histogram[kGreenChannel][i],
               _histogram[kBlueChannel][i]);
    }
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

    // Calculate the histogram

    [self computeHistogramFromBitmap:ctx];
                        
    // Clean up

    [NSGraphicsContext setCurrentContext:nil];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
}

- (void)clearHistogram {

    for (unsigned i = 0; i <= 255; i++)
    {
        _histogram[kRedChannel][i] = 0;
        _histogram[kGreenChannel][i] = 0;
        _histogram[kBlueChannel][i] = 0;
    }
}

- (void)computeHistogramFromBitmap:(CGContextRef)bitmap {

    // NB: Assumes RGBA 8bpp

    size_t width = CGBitmapContextGetWidth(bitmap);
    size_t height = CGBitmapContextGetHeight(bitmap);

    uint32_t* pixel = (uint32_t*)CGBitmapContextGetData(bitmap);

    for (unsigned y = 0; y < height; y++)
    {
        for (unsigned x = 0; x < width; x++)
        {
            uint32_t rgba = *pixel;

            // Extract colour components
            uint8_t red   = (rgba & 0x000000ff) >> 0;
            uint8_t green = (rgba & 0x0000ff00) >> 8;
            uint8_t blue  = (rgba & 0x00ff0000) >> 16;

            // Accumulate each colour
            _histogram[kRedChannel][red]++;
            _histogram[kGreenChannel][green]++;
            _histogram[kBlueChannel][blue]++;

            // Next pixel!
            pixel++;
        }
    }
}

@end
