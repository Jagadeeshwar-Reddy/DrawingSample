//
//  ViewController.m
//  DrawingSample
//
//  Created by Teleparadigm on 21/02/13.
//  Copyright (c) 2013 Teleparadigm. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Trim.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _done_btn.main_title=@"Hello_main";
    _done_btn.sub_title=@"Hello_sub";
    
    
    [_paint_board setBoardImage:[UIImage imageNamed:@"logo"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_paint_board release];
    [_done_btn release];
    [super dealloc];
}

- (IBAction)btnAction:(UIButton *)sender {
    int tag = [sender tag];
    
    switch (tag) {
        case 1:
        {
            [_paint_board setPencolor:[UIColor redColor]];
            [_paint_board setPaint_mode:DrawingMode_pen];
        }
            break;
        case 2:
        {
            [_paint_board setPencolor:[UIColor greenColor]];
            [_paint_board setPaint_mode:DrawingMode_pen];
        }
            break;
        case 3:
        {
            [_paint_board setPencolor:[UIColor blackColor]];
            [_paint_board setPaint_mode:DrawingMode_pen];
        }
            break;
        case 4:
        {
            [_paint_board setPaint_mode:DrawingMode_Eraser];
        }
            break;
        case 5:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            [UIImagePNGRepresentation([_paint_board currentImage]) writeToFile:[documentsDirectory stringByAppendingPathComponent:@"newImage.png"] atomically:YES];
        }
            break;

        default:
            break;
    }
}
@end
