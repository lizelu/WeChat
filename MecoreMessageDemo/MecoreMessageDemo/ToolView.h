//
//  ToolView.h
//  MecroMessage
//
//  Created by 李泽鲁 on 14-9-22.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>


//定义block类型把ToolView中TextView中的文字传入到Controller中
typedef void (^MyTextBlock) (NSString *myText);

//录音时的音量
typedef void (^AudioVolumeBlock) (CGFloat volume);

//录音存储地址
typedef void (^AudioURLBlock) (NSURL *audioURL);

//改变根据文字改变TextView的高度
typedef void (^ContentSizeBlock)(CGSize contentSize);

//录音取消的回调
typedef void (^CancelRecordBlock)(int flag);

//扩展功能块按钮tag的回调
typedef void (^ExtendFunctionBlock)(int buttonTag);


@interface ToolView : UIView<UITextViewDelegate,AVAudioRecorderDelegate>


//设置MyTextBlock
-(void) setMyTextBlock:(MyTextBlock)block;

//设置声音回调
-(void) setAudioVolumeBlock:(AudioVolumeBlock) block;

//设置录音地址回调
-(void) setAudioURLBlock:(AudioURLBlock) block;

-(void)setContentSizeBlock:(ContentSizeBlock) block;

-(void)setCancelRecordBlock:(CancelRecordBlock)block;

-(void)setExtendFunctionBlock:(ExtendFunctionBlock) block;


-(void) changeFunctionHeight: (float) height;


@end
