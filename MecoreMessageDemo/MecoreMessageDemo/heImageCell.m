//
//  heImageCell.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-25.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "heImageCell.h"


@interface heImageCell()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation heImageCell

-(void)setCellValue:(NSString *)imageURL
{
    [super setCellValue:imageURL];
    //设置图片
    UIImage *image = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
        [self.bgImageView setImage:image];
    
    
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
