//
//  ImageEditorView.h
//  DrawingSample
//
//  Created by iMobiGeeks on 18/03/13.
//  Copyright (c) 2013 Teleparadigm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEditorView : UIImageView{
    
	CGMutablePathRef mPath;
	CGPoint mLastPoint;
    unsigned int penColor;
    float penWidth;
    unsigned int bgColor;
	
    
}
@property CGPoint mLastPoint;
- (void)doClear;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

-(void)setPenColor:(unsigned int)value;
-(void)setPenWidth:(float)value;
-(void)setBgColor:(unsigned int)value;



@end
