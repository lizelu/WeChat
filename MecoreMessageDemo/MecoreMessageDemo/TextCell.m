//
//  TextCell.m
//  CocoaPods
//
//  Created by 李泽鲁 on 14-9-24.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "TextCell.h"

@interface TextCell()

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UIImageView *chatBgImageView;
@property (strong, nonatomic) IBOutlet UITextView *chatTextView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBgImageWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatTextWidthConstaint;
@property (strong, nonatomic) NSMutableAttributedString *attrString;

@end

@implementation TextCell

-(void)setCellValue:(NSMutableAttributedString *)str
{
    //移除约束
    [self removeConstraint:_chatBgImageWidthConstraint];
    [self removeConstraint:_chatTextWidthConstaint];
    
    self.attrString = str;
    NSLog(@"%@",self.attrString);
    
    //由text计算出text的宽高
      CGRect bound = [self.attrString boundingRectWithSize:CGSizeMake(150, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
   
    //根据text的宽高来重新设置新的约束
    //背景的宽
    NSString *widthImageString;
    NSArray *tempArray;
    
    widthImageString = [NSString stringWithFormat:@"H:[_chatBgImageView(%f)]", bound.size.width+45];
    tempArray = [NSLayoutConstraint constraintsWithVisualFormat:widthImageString options:0 metrics:0 views:NSDictionaryOfVariableBindings(_chatBgImageView)];
    _chatBgImageWidthConstraint = tempArray[0];
    [self addConstraint:self.chatBgImageWidthConstraint];
    
    widthImageString = [NSString stringWithFormat:@"H:[_chatTextView(%f)]", bound.size.width+20];
    tempArray = [NSLayoutConstraint constraintsWithVisualFormat:widthImageString options:0 metrics:0 views:NSDictionaryOfVariableBindings(_chatTextView)];
    _chatBgImageWidthConstraint = tempArray[0];
    [self addConstraint:self.chatBgImageWidthConstraint];
    
    //设置图片
    UIImage *image = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    
    //image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    
    
    
    [self.chatBgImageView setImage:image];
    
    self.chatTextView.attributedText = str;
    
    
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
