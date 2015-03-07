//
//  MyViewController.m
//  MecroMessage
//
//  Created by 李泽鲁 on 14-9-22.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "MyViewController.h"
#import "ToolView.h"


@interface MyViewController ()
@property (nonatomic,strong) ToolView *toolView;
@property (strong, nonatomic) IBOutlet UITextView *myTextView;

@property (strong, nonatomic) IBOutlet UIImageView *VolumeImageView;
@property (strong, nonatomic) NSURL *playURL;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) CGRect keyEndFrame;

@property (strong, nonatomic) NSLayoutConstraint *tooViewConstraintHeight;
@property (assign, nonatomic) int screen;

@property (strong, nonatomic) NSMutableArray *audioUrlArray;
@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.audioUrlArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    
    _toolView = [[ToolView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_toolView];
    
    _toolView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *toolViewContraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:toolViewContraintH];
    
   NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolView(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:tooViewConstraintV];
    self.tooViewConstraintHeight = tooViewConstraintV[0];
    
    [self setToolViewBlock];
    
    
    //获取通知中心
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //注册为被通知者
    [notificationCenter addObserver:self selector:@selector(keyChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.screen = 1;
}

-(void)setToolViewBlock
{
    __weak __block MyViewController *copy_self = self;
    //通过block回调接收到toolView中的text
    [self.toolView setMyTextBlock:^(NSString *myText) {
        copy_self.myTextView.text = myText;
    }];
    
    
    [self.toolView setContentSizeBlock:^(CGSize contentSize) {
       // [copy_self updateHeight:contentSize];
    }];
    
    
    //获取录音声量
    [self.toolView setAudioVolumeBlock:^(CGFloat volume) {
        
        copy_self.VolumeImageView.hidden = NO;
        int index = (int)(volume*100)%6+1;
        [copy_self.VolumeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d.png",index]]];
    }];
    
    //获取录音地址
    [self.toolView setAudioURLBlock:^(NSURL *audioURL) {
        copy_self.VolumeImageView.hidden = YES;
        
        [copy_self.audioUrlArray addObject:audioURL];
        copy_self.playURL = audioURL;
        NSLog(@"%@", copy_self.audioUrlArray);
    }];
    
    //录音取消
    [self.toolView setCancelRecordBlock:^(int flag) {
        if (flag == 1) {
            copy_self.VolumeImageView.hidden = YES;
        }
    }];


}


//更新约束
-(void)updateHeight:(CGSize)contentSize
{
    float height = contentSize.height + 18;
    if (height <= 80) {
        [self.view removeConstraint:self.tooViewConstraintHeight];
        
        NSString *string = [NSString stringWithFormat:@"V:[_toolView(%f)]", height];
        
        NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:string options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
        self.tooViewConstraintHeight = tooViewConstraintV[0];
        [self.view addConstraint:self.tooViewConstraintHeight];
    }
    

//    NSLog(@"%f",height);
    
}

- (IBAction)player:(id)sender {
    if (self.playURL != nil)
    {
        
         AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:_playURL error:nil];
        self.audioPlayer = player;
        [self.audioPlayer play];
        
    }
}


//屏幕旋转改变toolView的表情键盘的高度
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //纵屏
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.screen = 1;
        [self.toolView changeFunctionHeight:216];
        //self.moreView.frame = frame;
        
    }
    //横屏
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.toolView changeFunctionHeight:150];
        self.screen = 0;
        //self.moreView.frame = frame;
        
    }
}




//键盘出来的时候调整tooView的位置
-(void) keyChange:(NSNotification *) notify
{
    NSDictionary *dic = notify.userInfo;
    
    
    CGRect endKey = [dic[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGRect endKeySwap = [self.view convertRect:endKey fromView:self.view.window];
    self.keyEndFrame = endKeySwap;
    
    
    //运动时间
    [UIView animateWithDuration:[dic[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        

        
        
        CGRect frame = self.view.frame;
        frame.size.height = endKeySwap.origin.y;
        
        
        NSLog(@"%@",[NSValue valueWithCGRect:endKeySwap]);
        
        self.view.frame = frame;
        
        
        //        CGRect toolViewFrame = self.toolView.frame;
        //        toolViewFrame.size.height = self.view
        
       // [self.view layoutIfNeeded];

        
        
//        //NSLog(@"%@", [NSValue valueWithCGRect:endKey]);
//        NSLog(@"%@", [NSValue valueWithCGRect:endKeySwap]);
//        NSLog(@"%@",[NSValue valueWithCGRect:frame]);
//        
//        if (self.screen == 1)
//        {
//          frame.size.height = endKeySwap.origin.y;
//        }
//        
//        if (self.screen == 0)
//        {
//            frame.size.width = endKeySwap.origin.y;
//        }
        
        
        self.toolView.frame = frame;
       // [self.view layoutIfNeeded];
    }];
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
