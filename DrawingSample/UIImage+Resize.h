//
//  UIImage+Resize.h
//  HandOver
//
//  Created by NeilGogte on 26/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

-(UIImage *)scaledToSize:(CGSize)newSize;
-(UIImage*)thumbnailWithSize:(CGSize)thumbsize;

-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;

@end
