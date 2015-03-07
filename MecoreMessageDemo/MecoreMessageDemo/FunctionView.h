//
//  FunctionView.h
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义对应的block类型，用于数据的交互
typedef void (^FunctionBlock) (UIImage *image, NSString *imageText);

@interface FunctionView : UIView
//资源文件名
@property (nonatomic, strong) NSString *plistFileName;
//接受block块
-(void)setFunctionBlock:(FunctionBlock) block;

@end
