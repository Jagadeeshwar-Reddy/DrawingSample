//
//  CustomButton.m
//  homePad Pro v1.0
//
//  Created by in4biz Sàrl on 02/01/13.
//
//

#import "CustomButton.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomButton ()

@property (strong,nonatomic) CALayer *backgroundLayer,*highlightBackgroundLayer;

@end

@implementation CustomButton
@synthesize main_title,sub_title;

#pragma mark - UIButton Overrides

+ (CustomButton *)buttonWithType:(UIButtonType)type
{
    return [super buttonWithType:UIButtonTypeCustom];
}

- (id)initWithCoder:(NSCoder *)coder
{
    // Call the parent implementation of initWithCoder
	self = [super initWithCoder:coder];
    
    // Custom drawing methods
	if (self)
    {
		//[self drawButtonBackground];
	}
    
	return self;
}
-(void)resetView{
    _backgroundLayer=nil;
    _highlightBackgroundLayer=nil;
}
- (void)layoutSubviews
{
    [self drawButtonBackground];
    // Set gradient frame (fill the whole button))
    _backgroundLayer.frame = self.bounds;
    
    // Set highlight Background frame
    _highlightBackgroundLayer.frame = self.bounds;
    
    //
    
	[super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted
{
	// Disable implicit animation
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
    
    // Hide/show inverted gradient
	_highlightBackgroundLayer.hidden = !highlighted;
	[CATransaction commit];
	
	[super setHighlighted:highlighted];
}

#pragma mark - Layer setters

- (void)drawButtonBackground
{
    // Get the root layer (any UIView subclass comes with one)
    CALayer *layer = self.layer;
    
    layer.cornerRadius = 2;
    layer.borderWidth = 2;
    layer.borderColor = [UIColor colorWithRed:0.20f green:0.20f blue:0.20f alpha:1.00f].CGColor;
    
    [self drawBackgroundLayer];

    _highlightBackgroundLayer.hidden = YES;
    
}

- (void)drawBackgroundLayer
{
    // Check if the property has been set already
    if (!_backgroundLayer)
    {
        // Instantiate the gradient layer
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor=[UIColor colorWithRed:0.30f green:0.30f blue:0.30f alpha:1.00f].CGColor;
        
        
        CALayer *sub_backgroundLayer=[CALayer layer];
        sub_backgroundLayer.backgroundColor = [UIColor colorWithRed:0.286f green:0.521f blue:0.290f alpha:1.00f].CGColor;
        CGRect rect = CGRectInset(self.bounds, 3, 2);
        rect.size.width = rect.size.width * 0.238;
        sub_backgroundLayer.frame=rect;
        
        UIFont *font = self.titleLabel.font;
        CGFloat fontSize = font.pointSize;
        
        CATextLayer *sub_title_Layer = [CATextLayer layer];
        [sub_title_Layer setFont:font.fontName];
        [sub_title_Layer setFontSize:fontSize];
        sub_title_Layer.contentsScale = [[UIScreen mainScreen] scale];
        [sub_title_Layer setAlignmentMode:kCAAlignmentCenter];
        [sub_title_Layer setForegroundColor:[[UIColor whiteColor] CGColor]];
        [sub_title_Layer setString:self.sub_title];
        [sub_title_Layer setFrame:rect];
        sub_title_Layer.wrapped=YES;
        
        [_backgroundLayer addSublayer:sub_title_Layer];

        CATextLayer *main_title_Layer = [CATextLayer layer];
        //main_title_Layer.backgroundColor=[UIColor redColor].CGColor;
        [main_title_Layer setFont:font.fontName];
        [main_title_Layer setFontSize:fontSize];
        main_title_Layer.contentsScale = [[UIScreen mainScreen] scale];
        //main_title_Layer.wrapped=YES;
        [main_title_Layer setString:self.main_title];
        [main_title_Layer setAlignmentMode:kCAAlignmentCenter];
        [main_title_Layer setForegroundColor:[[UIColor whiteColor] CGColor]];
        CGRect main_title_Layer_frame = CGRectInset(self.bounds, rect.origin.x+4, 2);
        [main_title_Layer setFrame:main_title_Layer_frame];
        CGFloat offsetY = 0;
        
        //if system version is grater than 6
        if(([[[UIDevice currentDevice] systemVersion] compare:@"6" options:NSNumericSearch] == NSOrderedDescending)){
            offsetY = -(font.capHeight - font.xHeight);
        }
        
        //you have to set textX, textY, textWidth
        main_title_Layer_frame.origin.y= main_title_Layer_frame.origin.y + offsetY;
        main_title_Layer.frame = main_title_Layer_frame;
        [_backgroundLayer addSublayer:main_title_Layer];
        
        
        [_backgroundLayer addSublayer:sub_backgroundLayer];
        
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    }
   
    if (!_highlightBackgroundLayer)
    {
        // Instantiate the highlight background layer
        _highlightBackgroundLayer = [CALayer layer];
        _highlightBackgroundLayer.backgroundColor=[UIColor colorWithRed:0.28f green:0.28f blue:0.28f alpha:1.00f].CGColor;
        
        
        CALayer *sub_backgroundLayer=[CALayer layer];
        sub_backgroundLayer.backgroundColor = [UIColor colorWithRed:0.286f green:0.521f blue:0.290f alpha:0.80f].CGColor;
        CGRect rect = CGRectInset(self.bounds, 3, 2);
        rect.size.width = rect.size.width * 0.238;
        sub_backgroundLayer.frame=rect;
        
        CATextLayer *sub_title_Layer = [CATextLayer layer];
        [sub_title_Layer setFont:self.titleLabel.font.fontName];
        [sub_title_Layer setFontSize:self.titleLabel.font.pointSize];
        sub_title_Layer.contentsScale = [[UIScreen mainScreen] scale];
        [sub_title_Layer setFrame:rect];
        sub_title_Layer.wrapped=YES;
        [sub_title_Layer setString:self.sub_title];
        [sub_title_Layer setAlignmentMode:kCAAlignmentCenter];
        [sub_title_Layer setForegroundColor:[[UIColor whiteColor] CGColor]];
        [_highlightBackgroundLayer addSublayer:sub_title_Layer];
        
        CATextLayer *main_title_Layer = [CATextLayer layer];
        [main_title_Layer setFont:self.titleLabel.font.fontName];
        [main_title_Layer setFontSize:self.titleLabel.font.pointSize];
        main_title_Layer.contentsScale = [[UIScreen mainScreen] scale];
        [main_title_Layer setFrame:CGRectInset(self.bounds, rect.origin.x+4, 2)];
        main_title_Layer.wrapped=YES;
        [main_title_Layer setString:self.main_title];
        [main_title_Layer setAlignmentMode:kCAAlignmentCenter];
        [main_title_Layer setForegroundColor:[[UIColor whiteColor] CGColor]];
        [_highlightBackgroundLayer addSublayer:main_title_Layer];
        
        
        [_highlightBackgroundLayer addSublayer:sub_backgroundLayer];
        
        [self.layer insertSublayer:_highlightBackgroundLayer atIndex:1];
    }
}
@end
