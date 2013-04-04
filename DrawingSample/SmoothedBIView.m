#import "SmoothedBIView.h"
#import "UIImage+Resize.h"
//#import "UIImage+ProportionalFill.h"
#define DISPLAY_SCALE_FACTOR 1
@interface SmoothedBIView()
{
    UIBezierPath *path;
    
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
    
    CGFloat min_touch_point;
    CGFloat max_touch_point;
    
    BOOL isFirstTouch;
}
@property(nonatomic,retain) UIImage *image;
@end

@implementation SmoothedBIView
@synthesize image;
@synthesize delegate;
@synthesize pencolor;
@synthesize paint_mode;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        path = [[UIBezierPath bezierPath] retain];
        [path setLineWidth:LineWidth];
        pencolor=DefaultLineColor;
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [[UIBezierPath bezierPath] retain];
        [path setLineWidth:LineWidth];
        pencolor=DefaultLineColor;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.image = [self.image resizedImageToFitInSize:rect.size scaleIfSmaller:YES];
    [self.image drawAtPoint:rect.origin];

    [pencolor setStroke];
    [path stroke];

    [super drawRect:rect];
}
-(void)setBoardImage:(UIImage *)img{
    

    if (img) {
        //Paint the old signature
        CGSize sign_image_size = img.size;
        CGRect sign_rect=CGRectZero;
        sign_rect.origin.x=(self.bounds.size.width/2 - sign_image_size.width/(2*DISPLAY_SCALE_FACTOR));
        if(sign_rect.origin.x<0)sign_rect.origin.x=0;
        sign_rect.origin.y=0;
        sign_rect.size.width=sign_image_size.width/DISPLAY_SCALE_FACTOR;
        sign_rect.size.height=sign_image_size.height/DISPLAY_SCALE_FACTOR;
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, DISPLAY_SCALE_FACTOR);
        //hPDebugLog(@"self.bounds = %@",NSStringFromCGRect(self.bounds));
        // first time; paint background white
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
        
        [img drawInRect:sign_rect];
        
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    else{
        isFirstTouch=YES;
        self.image=nil;
        [self setNeedsDisplay];
    }
}
-(UIImage*)currentImage{
    if (!self.image)return nil;
    return self.image;
}

#pragma mark -
#pragma mark UITouch delegete
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (paint_mode == DrawingMode_Eraser) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        [self clipImage:currentPoint];
        pts[0]=currentPoint;
    }
    else{
        
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        
        ctr++;
        pts[ctr] = p;
        if (ctr == 4)
        {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            [path moveToPoint:pts[0]];
            [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
            
            [self setNeedsDisplay];
            
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4];
            ctr = 1;
        }
    }

    NSArray *t = [[event allTouches] allObjects];
	if ([t count] > 0) {
        if ([delegate respondsToSelector:@selector(drawingBoardState:)]) {
            [delegate drawingBoardState:FilledState];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (paint_mode == DrawingMode_Eraser) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        [self clipImage:currentPoint];
        pts[0]=currentPoint;
    }
    else{
        [self drawBitmap];
        [self setNeedsDisplay];
        
        [path removeAllPoints];
        ctr = 0;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, DISPLAY_SCALE_FACTOR);
    
    // first time; paint background white
    if (!self.image)
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }

    [self.image drawAtPoint:CGPointZero];
    
    if (paint_mode == DrawingMode_Eraser) {
        [[UIColor colorWithPatternImage:self.image] setStroke];
    }
    else{
        [pencolor setStroke];
    }
    
    [path stroke];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}
- (void)clipImage:(CGPoint)currentPoint {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    
    UIColor *clr = [UIColor colorWithPatternImage:self.image];
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    // iOS 5
    if ([clr respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [clr getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, alpha);
    CGPoint lastPoint = pts[0];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    [self setNeedsDisplay];
    UIGraphicsEndImageContext();

}
@end


