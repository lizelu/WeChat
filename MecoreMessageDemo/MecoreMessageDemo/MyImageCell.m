//
//  MyImageCell.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-25.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "MyImageCell.h"
#import <UIKit+AFNetworking.h>

@interface MyImageCell()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) ButtonImageBlock imageBlock;
@property (strong, nonatomic) NSURL *imageUrl;

@end

@implementation MyImageCell

-(void)setCellValue:(NSString *) imageURL
{
    self.imageUrl = [NSURL URLWithString:imageURL];
    UIImage *image = [UIImage imageNamed:@"chatto_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    [self.bgImageView setImage:image];
    
    
    NSLog(@"%@", imageURL);
    
    [self.imageButton setImageForState:UIControlStateNormal withURL:_imageUrl placeholderImage:[UIImage imageNamed:@"chat_bottom_smile_press.png"]];
}

-(void)setButtonImageBlock:(ButtonImageBlock)block
{
    self.imageBlock = block;
}

- (IBAction)tapImageButton:(id)sender {
    self.imageBlock(self.imageUrl);
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
