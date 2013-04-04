//
//  ViewController.h
//  DrawingSample
//
//  Created by Teleparadigm on 21/02/13.
//  Copyright (c) 2013 Teleparadigm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmoothedBIView.h"
#import "CustomButton.h"
@interface ViewController : UIViewController <DrawingBoardDelegate>
@property (retain, nonatomic) IBOutlet SmoothedBIView *paint_board;
@property (retain, nonatomic) IBOutlet CustomButton *done_btn;

- (IBAction)btnAction:(UIButton *)sender;
@end
