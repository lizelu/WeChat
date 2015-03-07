//
//  ToolView.m
//  MecroMessage
//
//  Created by 李泽鲁 on 14-9-22.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "ToolView.h"
#import "FunctionView.h"
#import "ImageModelClass.h"
#import "HistoryImage.h"
#import "MoreView.h"


@interface ToolView()
//最左边发送语音的按钮
@property (nonatomic, strong) UIButton *voiceChangeButton;

//发送语音的按钮
@property (nonatomic, strong) UIButton *sendVoiceButton;

//文本视图
@property (nonatomic, strong) UITextView *sendTextView;

//切换键盘
@property (nonatomic, strong) UIButton *changeKeyBoardButton;

//More
@property (nonatomic, strong) UIButton *moreButton;

//键盘坐标系的转换
@property (nonatomic, assign) CGRect endKeyBoardFrame;


//表情键盘
@property (nonatomic, strong) FunctionView *functionView;

//more
@property (nonatomic, strong) MoreView *moreView;

//数据model
@property (strong, nonatomic) ImageModelClass  *imageMode;

@property (strong, nonatomic)HistoryImage *tempImage;


//传输文字的block回调
@property (strong, nonatomic) MyTextBlock textBlock;

//contentsinz
@property (strong, nonatomic) ContentSizeBlock sizeBlock;

//传输volome的block回调
@property (strong, nonatomic) AudioVolumeBlock volumeBlock;

//传输录音地址
@property (strong, nonatomic) AudioURLBlock urlBlock;

//录音取消
@property (strong, nonatomic) CancelRecordBlock cancelBlock;

//扩展功能回调
@property (strong, nonatomic) ExtendFunctionBlock extendBlock;


//添加录音功能的属性
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSURL *audioPlayURL;

@property (strong, nonatomic) NSString *string;

@end

@implementation ToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bottom_bar.png"]];
        [self setBackgroundColor:color];
        
        
        // Initialization code
        //imageMode的初始化，存入历史表情
        self.imageMode = [[ImageModelClass alloc] init];

        
        [self addSubview];
        [self addConstraint];
        
     }
    return self;
}

-(void)setMyTextBlock:(MyTextBlock)block
{
    self.textBlock = block;
}

-(void)setAudioVolumeBlock:(AudioVolumeBlock)block
{
    self.volumeBlock = block;
}

-(void)setAudioURLBlock:(AudioURLBlock)block
{
    self.urlBlock = block;
}

-(void)setContentSizeBlock:(ContentSizeBlock)block
{
    self.sizeBlock = block;
}

-(void)setCancelRecordBlock:(CancelRecordBlock)block
{
    self.cancelBlock = block;
}

-(void)setExtendFunctionBlock:(ExtendFunctionBlock)block
{
    self.extendBlock = block;
}

//控件的初始化
-(void) addSubview
{
    self.voiceChangeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateNormal];
    [self.voiceChangeButton addTarget:self action:@selector(tapVoiceChangeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceChangeButton];
    
    self.sendVoiceButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
    [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
    
    
    [self.sendVoiceButton addTarget:self action:@selector(tapSendVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    self.sendVoiceButton.hidden = YES;
    [self addSubview:self.sendVoiceButton];
    
    self.sendTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.sendTextView.delegate = self;
    [self addSubview:self.sendTextView];
    
    self.changeKeyBoardButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"chat_bottom_smile_nor.png"] forState:UIControlStateNormal];
    [self.changeKeyBoardButton addTarget:self action:@selector(tapChangeKeyBoardButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeKeyBoardButton];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.moreButton setImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];
    
    [self addDone];
    
    
    
    //实例化FunctionView
    self.functionView = [[FunctionView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    self.functionView.backgroundColor = [UIColor blackColor];
    
    //设置资源加载的文件名
    self.functionView.plistFileName = @"emoticons";
    
    __weak __block ToolView *copy_self = self;
    //获取图片并显示
    [self.functionView setFunctionBlock:^(UIImage *image, NSString *imageText)
     {
         NSString *str = [NSString stringWithFormat:@"%@%@",copy_self.sendTextView.text, imageText];
         
         copy_self.sendTextView.text = str;
         
         //把使用过的图片存入sqlite
         NSData *imageData = UIImagePNGRepresentation(image);
         [copy_self.imageMode save:imageData ImageText:imageText];
     }];
    
    
    //给sendTextView添加轻击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.sendTextView addGestureRecognizer:tapGesture];
    
    
    //给sendVoiceButton添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoiceButtonLongPress:)];
    //设置长按时间
    longPress.minimumPressDuration = 0.2;
    [self.sendVoiceButton addGestureRecognizer:longPress];
    
    //实例化MoreView
    self.moreView = [[MoreView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.moreView.backgroundColor = [UIColor blackColor];
    [self.moreView setMoreBlock:^(NSInteger index) {
        NSLog(@"MoreIndex = %d",(int)index);
        copy_self.extendBlock(index);
    }];

    
}

//给控件加约束
-(void)addConstraint
{
    //给voicebutton添加约束
    self.voiceChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *voiceConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_voiceChangeButton(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_voiceChangeButton)];
    [self addConstraints:voiceConstraintH];
    
    NSArray *voiceConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_voiceChangeButton(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_voiceChangeButton)];
    [self addConstraints:voiceConstraintV];
    
    
    
    //给MoreButton添加约束
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *moreButtonH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_moreButton(30)]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_moreButton)];
    [self addConstraints:moreButtonH];
    
    NSArray *moreButtonV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_moreButton(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_moreButton)];
    [self addConstraints:moreButtonV];
    
    
    //给changeKeyBoardButton添加约束
    self.changeKeyBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *changeKeyBoardButtonH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_changeKeyBoardButton(33)]-43-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_changeKeyBoardButton)];
    [self addConstraints:changeKeyBoardButtonH];
    
    NSArray *changeKeyBoardButtonV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_changeKeyBoardButton(33)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_changeKeyBoardButton)];
    [self addConstraints:changeKeyBoardButtonV];
    
    
    //给文本框添加约束
    self.sendTextView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *sendTextViewConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-45-[_sendTextView]-80-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendTextView)];
    [self addConstraints:sendTextViewConstraintH];
    
    NSArray *sendTextViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_sendTextView]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendTextView)];
    [self addConstraints:sendTextViewConstraintV];
    
    
    //语音发送按钮
    self.sendVoiceButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *sendVoiceButtonConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_sendVoiceButton]-90-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendVoiceButton)];
    [self addConstraints:sendVoiceButtonConstraintH];
    
    NSArray *sendVoiceButtonConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_sendVoiceButton]-6-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendVoiceButton)];
    [self addConstraints:sendVoiceButtonConstraintV];
    
    
}

//长按手势触发的方法
-(void)sendVoiceButtonLongPress:(id)sender
{
    static int i = 1;
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        UILongPressGestureRecognizer * longPress = sender;
        
        //录音开始
        if (longPress.state == UIGestureRecognizerStateBegan)
        {
            
            i = 1;
            
            [self.sendVoiceButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            //录音初始化
            [self audioInit];
            
            //创建录音文件，准备录音
            if ([self.audioRecorder prepareToRecord])
            {
                //开始
                [self.audioRecorder record];
                
                //设置定时检测音量变化
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
            }
        }
        
        
        //取消录音
        if (longPress.state == UIGestureRecognizerStateChanged)
        {
            
            CGPoint piont = [longPress locationInView:self];
            NSLog(@"%f",piont.y);

            if (piont.y < -20)
            {
                if (i == 1) {
                    
                    [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
                    [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    //删除录制文件
                    [self.audioRecorder deleteRecording];
                    [self.audioRecorder stop];
                    [_timer invalidate];
                    
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音取消" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [alter show];
                    //去除图片用的
                    self.cancelBlock(1);
                    i = 0;
                    
                }

                
            }
         }
        
        if (longPress.state == UIGestureRecognizerStateEnded) {
            if (i == 1)
            {
                NSLog(@"录音结束");
                [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
                [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                double cTime = self.audioRecorder.currentTime;
                if (cTime > 1)
                {
                    //如果录制时间<1 不发送
                    NSLog(@"发出去");
                    self.urlBlock(_audioPlayURL);
                }
                else
                {
                    //删除记录的文件
                    [self.audioRecorder deleteRecording];
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间太短！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [alter show];
                    self.cancelBlock(1);
                    
                }
                [self.audioRecorder stop];
                [_timer invalidate];
            }
        }
        
        
    }
    
}





//录音部分初始化
-(void)audioInit
{
    NSError * err = nil;
    
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
    
	[audioSession setActive:YES error:&err];
    
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}

    //通过可变字典进行配置项的加载
    NSMutableDictionary *setAudioDic = [[NSMutableDictionary alloc] init];
    
    //设置录音格式(aac格式)
    [setAudioDic setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [setAudioDic setValue:@(44100) forKey:AVSampleRateKey];
    
    //设置录音通道数1 Or 2
    [setAudioDic setValue:@(1) forKey:AVNumberOfChannelsKey];
    
    //线性采样位数  8、16、24、32
    [setAudioDic setValue:@16 forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [setAudioDic setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    
    _string = [NSString stringWithFormat:@"%@/%@.aac", strUrl, fileName];
    
    NSURL *url = [NSURL fileURLWithPath:_string];
    _audioPlayURL = url;
 
    
    NSError *error;
    //初始化
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setAudioDic error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;

}




////把图片和声音传到服务器上服务器会返回上传资源的地址
//-(void)sendContentToServer:(id) resource
//{
//    
//    __weak __block ToolView *copy_self = self;
//    
//    AFHTTPRequestOperationManager * m = [[AFHTTPRequestOperationManager alloc]init];
//    AFHTTPRequestOperation * op = [m POST:HTTPSERVER parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        
//        
//        //根据地址上传声音
//        if ([resource isKindOfClass:[NSURL class]])
//        {
//            NSError * error;
//            NSString *path = @"/Users/ibokan/Library/Application Support/iPhone Simulator/7.1/Applications/B17EE653-D33C-4B46-B700-8845399FFE4D/Documents/1411779524.aac";
//            NSURL *url = [NSURL fileURLWithPath:path];
//
//            NSLog(@"%@", url);
//            NSLog(@"%@", resource);
//            
//            NSLog(@"%@", path);
//            NSLog(@"%@", _string);
//            
//            [formData appendPartWithFileURL:url name:@"file" error:&error];
//            if (error) {
//                NSLog(@"拼接资源失败%@",[error localizedDescription]);
//            }
//        }
//        
//        //上传图片
//        if ([resource isKindOfClass:[UIImage class]]) {
//            //把图片转换成NSData类型的数据
//            NSData *imageData = UIImagePNGRepresentation(resource);
//            
//            
//            //把图片拼接到数据中
//            [formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];
//        }
//        
//        
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]);
//        
//        NSDictionary *mydic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//        
//        //获取上传地址的路径
//        NSURL *myURL = [NSURL URLWithString:mydic[@"success"]];
//        NSLog(@"%@", myURL);
////        [copy_self sendMessage:copy_self.sentType Content:myURL];
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"失败！！%@",error);
//    }];
//    op.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [op start];
//}


//录音的音量探测
- (void)detectionVoice
{
    [self.audioRecorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    //把声音的音量传给调用者
    self.volumeBlock(lowPassResults);
}


//通过屏幕旋转改变function的高度
-(void) changeFunctionHeight: (float) height
{
    CGRect frame = self.functionView.frame;
    frame.size.height = height;
    self.functionView.frame = frame;
    self.moreView.frame = frame;
}



//轻击sendText切换键盘
-(void)tapGesture:(UITapGestureRecognizer *) sender
{
    if ([self.sendTextView.inputView isEqual:self.functionView])
    {
        self.sendTextView.inputView = nil;
        
        [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"chat_bottom_smile_nor.png"] forState:UIControlStateNormal];
        
        [self.sendTextView reloadInputViews];
    }
    
    if (![self.sendTextView isFirstResponder])
    {
        [self.sendTextView becomeFirstResponder];
    }
}


//给键盘添加done键
-(void) addDone
{
    //TextView的键盘定制回收按钮
     UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
 
   UIBarButtonItem * item1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tapDone:)];
    UIBarButtonItem * item2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
      UIBarButtonItem * item3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[item2,item1,item3];
    
     self.sendTextView.inputAccessoryView =toolBar;
}


-(void)tapDone:(id)sender
{
    [self.sendTextView resignFirstResponder];
}



//通过文字的多少改变toolView的高度
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize contentSize = self.sendTextView.contentSize;
    
    self.sizeBlock(contentSize);
}




//切换声音按键和文字输入框
-(void)tapVoiceChangeButton:(UIButton *) sender
{

    if (self.sendVoiceButton.hidden == YES)
    {
        self.sendTextView.hidden = YES;
        self.sendVoiceButton.hidden = NO;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        
        if ([self.sendTextView isFirstResponder]) {
            [self.sendTextView resignFirstResponder];
        }
    }
    else
    {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateNormal];
        
        if (![self.sendTextView isFirstResponder]) {
            [self.sendTextView becomeFirstResponder];
        }
    }
}


//发送信息（点击return）
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        
        //通过block回调把text的值传递到Controller中共
        self.textBlock(self.sendTextView.text);
        
        self.sendTextView.text = @"";
        
        return NO;
    }
    return YES;
}



//发送声音按钮回调的方法
-(void)tapSendVoiceButton:(UIButton *) sender
{
    NSLog(@"sendVoiceButton");
    //点击发送按钮没有触发长按手势要做的事儿
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"按住录音" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [alter show];
}

//变成表情键盘
-(void)tapChangeKeyBoardButton:(UIButton *) sender
{
    if ([self.sendTextView.inputView isEqual:self.functionView])
    {
        self.sendTextView.inputView = nil;
        
        [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"chat_bottom_smile_nor.png"] forState:UIControlStateNormal];
        
        [self.sendTextView reloadInputViews];
    }
    else
    {
        self.sendTextView.inputView = self.functionView;
       
        
        [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        
        [self.sendTextView reloadInputViews];
    }
    
    if (![self.sendTextView isFirstResponder])
    {
        [self.sendTextView becomeFirstResponder];
    }
    
    if (self.sendTextView.hidden == YES) {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateNormal];
        
    }

}

//功能扩展
-(void)tapMoreButton:(UIButton *) sender
{
    if ([self.sendTextView.inputView isEqual:self.moreView])
    {
        self.sendTextView.inputView = nil;
        
        [self.sendTextView reloadInputViews];
    }
    else
    {
        self.sendTextView.inputView = self.moreView;
        
        
        [self.sendTextView reloadInputViews];
    }
    
    if (![self.sendTextView isFirstResponder])
    {
        [self.sendTextView becomeFirstResponder];
    }
    
    if (self.sendTextView.hidden == YES) {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        
    }

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
