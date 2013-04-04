//
//  SmoothedBIView.h
//  HomePad
//
//  Created  on 7/2/13.
//  Copyright 2012 in4biz Sàrl / Switzerland All rights reserved.
//

#import <UIKit/UIKit.h>

#define BoardBakgroundColor [UIColor whiteColor] //Default board background color
#define DefaultLineColor [UIColor redColor] //Default Line Color
#define LineWidth 3.0 //Default line width



typedef enum {
    EmptyState     = 0,
    FilledState = 1,
    None = 2,
} DrawingBoardState;

typedef enum {
    DrawingMode_pen = 0,
    DrawingMode_Eraser
}DrawingMode;

@protocol DrawingBoardDelegate <NSObject>
@optional
-(void)drawingBoardState:(DrawingBoardState)state;

@end

@interface SmoothedBIView : UIView{
    
}

@property(nonatomic,assign) id <DrawingBoardDelegate> delegate;
@property(nonatomic,assign) UIColor *pencolor;
@property(nonatomic,assign) DrawingMode paint_mode;
-(void)setBoardImage:(UIImage *)img;
-(UIImage*)currentImage;

@end
