//
//  MoreView.m
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "MoreView.h"

@interface MoreView()

@property (nonatomic, strong) MoreBlock block;

@end


@implementation MoreView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, 320, 216);
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [button1 setBackgroundImage:[UIImage imageNamed:@"Fav_Filter_Img_HL@2x"] forState:UIControlStateNormal];
        button1.tag = 1;
        [button1 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button1];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(90, 7, 60, 60)];
        [button2 setBackgroundImage:[UIImage imageNamed:@"AlbumListCamera_ios7@2x"] forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button2.tag = 2;
        [button2 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button2];
  
    }
    return self;
}

-(void) setMoreBlock:(MoreBlock)block
{
    self.block = block;
}

-(void) tapButton:(UIButton *)sender
{
    self.block(sender.tag);
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
