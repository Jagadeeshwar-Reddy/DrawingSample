//
//  ImageEditorView.m
//  DrawingSample
//
//  Created by iMobiGeeks on 18/03/13.
//  Copyright (c) 2013 Teleparadigm. All rights reserved.
//

#import "ImageEditorView.h"

@implementation ImageEditorView
@synthesize mLastPoint;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		self.opaque = YES;
		self.multipleTouchEnabled = NO;
        penColor = 0xFF66009A;
        penWidth = 3.0;
        bgColor = 0xFFFFFFFF;
        
    }
	mPath = nil;
	[self doClear];
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    self.multipleTouchEnabled = NO;
    penColor = 0xFF66009A;
    penWidth = 3.0;
    bgColor = 0xFFFFFFFF;
    mPath = nil;
	[self doClear];
    
}
-(void)setPenColor:(unsigned int)value
{
    penColor = value;
    [self setNeedsDisplay];
}

-(void)setPenWidth:(float)value
{
    penWidth = value;
    [self setNeedsDisplay];
}

-(void)setBgColor:(unsigned int)value
{
    bgColor = value;
    [self setNeedsDisplay];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.mLastPoint = [touch locationInView:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, mLastPoint.x, mLastPoint.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    mLastPoint = currentLocation;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 5.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, mLastPoint.x, mLastPoint.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    mLastPoint = currentLocation;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)doClear {
	if (mPath != nil) CGPathRelease(mPath);
	mPath = CGPathCreateMutable();
	[self setNeedsDisplay];
}

- (void)dealloc {
	CGPathRelease(mPath);
    [super dealloc];
}
@end
