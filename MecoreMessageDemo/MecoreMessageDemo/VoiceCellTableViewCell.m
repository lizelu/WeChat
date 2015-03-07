//
//  VoiceCellTableViewCell.m
//  CocoaPods
//
//  Created by 李泽鲁 on 14-9-24.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "VoiceCellTableViewCell.h"

@interface VoiceCellTableViewCell()

@property (strong, nonatomic) NSURL *playURL;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation VoiceCellTableViewCell

-(void)setCellValue:(NSDictionary *)dic
{
    _playURL = [NSURL URLWithString: dic[@"content"]];
}

- (IBAction)tapVoiceButton:(id)sender {
    [self httpGetVoice];
}

//网络请求声音
-(void)httpGetVoice
{
    NSData *data = [NSData dataWithContentsOfURL:_playURL];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithData:data error:&error];
    if (error) {
        NSLog(@"播放错误：%@",[error description]);
    }
    self.audioPlayer = player;
    [self.audioPlayer play];
    NSLog(@"%@", _playURL);

    
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
