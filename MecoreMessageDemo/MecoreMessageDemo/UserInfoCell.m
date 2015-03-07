//
//  UserInfoCell.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-28.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "UserInfoCell.h"

@interface UserInfoCell()
@property (strong, nonatomic) IBOutlet UIImageView *headImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *jidLable;

@end


@implementation UserInfoCell

-(void)setCellValue:(NSString *)username WithJid:(NSString *)jid
{
    self.userNameLabel.text = username;
    self.jidLable.text = jid;
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
