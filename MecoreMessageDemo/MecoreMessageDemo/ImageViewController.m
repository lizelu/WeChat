//
//  ImageViewController.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-25.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "ImageViewController.h"
#import <UIKit+AFNetworking.h>

@interface ImageViewController ()
@property (strong, nonatomic)  UIImageView *myImageView;

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 300, 450)];
    
    _myImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.myImageView setImageWithURL:self.imageURL];
    [self.view addSubview:_myImageView];
}
- (IBAction)tapPichGesture:(id)sender {
    UIPinchGestureRecognizer *gesture = sender;
    
    //手势改变时
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        
        //捏合手势中scale属性记录的缩放比例
        self.myImageView.transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
    }
    
    
//    //结束后恢复
//    if(gesture.state==UIGestureRecognizerStateEnded)
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            _imageView.transform = CGAffineTransformIdentity;//取消一切形变
//        }];
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
