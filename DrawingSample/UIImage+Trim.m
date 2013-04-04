//
//  UIImage+Trim.m
//
//  Created by Rick Pastoor on 26-09-12.
//  Based on gist:3549921 ( https://gist.github.com/3549921/8abea8ac9e2450f6a38540de9724d3bf850a62df )
//
//  Copyright (c) 2012 Wrep - http://www.wrep.nl/
//

#import "UIImage+Trim.h"

@implementation UIImage (Trim)

- (UIImage *) imageByTrimmingTransparentPixels
{
	int rows = self.size.height;
	int cols = self.size.width;
	int bytesPerRow = cols*sizeof(uint8_t);
	
	if ( rows < 2 || cols < 2 )
    {
		return self;
	}
	
	// Allocate array to hold alpha channel
	uint8_t *bitmapData = calloc(rows*cols, sizeof(uint8_t));
	
	// Create alpha-only bitmap context
	CGContextRef contextRef = CGBitmapContextCreate(bitmapData, cols, rows, 8, bytesPerRow, NULL, kCGImageAlphaOnly);
	
	// Draw our image on that context
	CGImageRef cgImage = self.CGImage;
	CGRect rect = CGRectMake(0, 0, cols, rows);
	CGContextDrawImage(contextRef, rect, cgImage);
    
	// Sum all non-transparent pixels in every row and every column
	uint16_t *rowSum = calloc(rows, sizeof(uint16_t));
	uint16_t *colSum = calloc(cols, sizeof(uint16_t));
	
	// Enumerate through all pixels
	for (int row = 0; row < rows; row++)
    {
		for (int col = 0; col < cols; col++)
		{
            // Found non-transparent pixel
			if (bitmapData[row*bytesPerRow + col])
            {
				rowSum[row]++;
				colSum[col]++;
			}
		}
	}
	
	// Initialize crop insets and enumerate cols/rows arrays until we find non-empty columns or row
	UIEdgeInsets crop = UIEdgeInsetsMake(0, 0, 0, 0);
	
    // Top
	for (int i = 0; i < rows; i++)
    {
		if ( rowSum[i] > 0 )
        {
			crop.top = i;
            break;
		}
	}
	
    // Bottom
	for (int i = rows - 1; i >= 0; i--)
    {
		if (rowSum[i] > 0)
        {
			crop.bottom = MAX(0, rows - i - 1);
            break;
		}
	}
	
    // Left
	for (int i = 0; i < cols; i++)
    {
		if (colSum[i] > 0)
        {
			crop.left = i;
            break;
		}
	}
	
    // Right
	for (int i = cols - 1; i >= 0; i--)
    {
		if (colSum[i] > 0)
        {
			crop.right = MAX(0, cols - i - 1);
            break;
		}
	}
	
	free(bitmapData);
	free(colSum);
	free(rowSum);
	
    UIImage *img = self;
    
	if (crop.top == 0 && crop.bottom == 0 && crop.left == 0 && crop.right == 0)
    {
		// No cropping needed
	}
	else
    {
		// Calculate new crop bounds
		rect.origin.x += crop.left;
		rect.origin.y += crop.top;
		rect.size.width -= crop.left + crop.right;
		rect.size.height -= crop.top + crop.bottom;
		
		// Crop it
		CGImageRef newImage = CGImageCreateWithImageInRect(cgImage, rect);
		
		// Convert back to UIImage
        img = [UIImage imageWithCGImage:newImage];
        
        CGImageRelease(newImage);
	}
    
    CGContextRelease(contextRef);
    
    return img;
}

/*
void ManipulateImagePixelData(CGImageRef inImage)
{
    // Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
    if (cgctx == NULL)
    {
        // error creating context
        return;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    void *data = CGBitmapContextGetData (cgctx);
    if (data != NULL)
    {
        
        // **** You have a pointer to the image data ****
        
        // **** Do stuff with the data here ****
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    
}

CGContextRef CreateARGBBitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}
*/
@end
