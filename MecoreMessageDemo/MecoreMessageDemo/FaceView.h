//
//  FaceView.h
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>

//声明表情对应的block,用于把点击的表情的图片和图片信息传到上层视图
typedef void (^FaceBlock) (UIImage *image, NSString *imageText);

@interface FaceView : UIView

//图片对应的文字
@property (nonatomic, strong) NSString *imageText;
//表情图片
@property (nonatomic, strong) UIImage *headerImage;

//设置block回调
-(void)setFaceBlock:(FaceBlock)block;

//设置图片，文字
-(void)setImage:(UIImage *) image ImageText:(NSString *) text;

@end
