//
//  CustomButton.h
//  homePad Pro v1.0
//
//  Created by in4biz Sàrl on 02/01/13.
//
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton{
    
}

@property (nonatomic,retain) NSString * main_title;
@property (nonatomic,retain) NSString * sub_title;


-(void)resetView;
@end
