//
//  UIImage+Resize.m
//  HandOver
//
//  Created by NeilGogte on 26/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

-(UIImage *)scaledToSize:(CGSize)newSize
{
	// Create a graphics image context
    
	UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
    
	// Tell the old image to draw in this new context, with the desired
	UIImage *scaledImage=[UIImage imageWithCGImage:self.CGImage scale:[UIScreen mainScreen].scale orientation:self.imageOrientation];
    
	[scaledImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	UIGraphicsEndImageContext();
	
    
	// Return the new image.
	return newImage;
}
/*-(UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGRect)newSize
 {
 // Create a graphics context with the target size
 // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
 // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
 CGSize size = newSize.size;
 if (NULL != UIGraphicsBeginImageContextWithOptions)
 UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
 else
 UIGraphicsBeginImageContext(size);
 
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
 
 CGContextTranslateCTM(context, 0.0, size.height);
 CGContextScaleCTM(context, 1.0, -1.0);
 //CGContextTranslateCTM(context, 0, -(newSize.origin.y + newSize.size.height));
 
 // Draw the original image to the context
 CGContextSetBlendMode(context, kCGBlendModeCopy);
 CGContextDrawImage(context, newSize, image.CGImage);
 
 // Retrieve the UIImage from the current context
 UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
 
 UIGraphicsEndImageContext();
 
 return imageOut;
 }*/

-(UIImage*)thumbnailWithSize:(CGSize)thumbsize{
    
    CGImageRef imageRef  = [self CGImage];
    
    //    CGImageAlphaInfo    alphaInfo = CGImageGetAlphaInfo(imageRef);
    //
    //    if (alphaInfo == kCGImageAlphaNone) alphaInfo = kCGImageAlphaNoneSkipLast;
    
    size_t width = thumbsize.width;
    size_t height = thumbsize.height;
    size_t bitsPerComponent=CGImageGetBitsPerComponent(imageRef);
    size_t bytesPerRow = 4 * thumbsize.width;
    CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedFirst);
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef    ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result =[[UIImage alloc] initWithCGImage:ref];
    //[UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);    // ok if NULL
    CGImageRelease(ref);
    
    // CGImageRelease(imageRef);
    
    return [result autorelease];
}


-(UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
            
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
            
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
            
		case UIImageOrientationRightMirrored: //EXIF = 7
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
	}
    
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
	UIGraphicsBeginImageContextWithOptions(dstSize, NO, 0.0);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
    
	CGContextConcatCTM(context, transform);
    
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return resizedImage;
}



/////////////////////////////////////////////////////////////////////////////



-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale
{
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
    
	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = self.imageOrientation;
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}
    
	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
    
	if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		//NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
		dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
	} else {
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
        
		if (wRatio < hRatio) {
			//NSLog(@"Width imposed, Height scaled ; ratio = %f",wRatio);
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			//NSLog(@"Height imposed, Width scaled ; ratio = %f",hRatio);
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
    
	return [self resizedImageToSize:dstSize];
}
@end
