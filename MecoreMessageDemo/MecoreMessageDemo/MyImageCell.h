//
//  MyImageCell.h
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-25.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>

//button点击回调传出图片
typedef void (^ButtonImageBlock) (NSURL *imageURL);

@interface MyImageCell : UITableViewCell

-(void)setButtonImageBlock:(ButtonImageBlock) block;

-(void)setCellValue:(NSString *) imageURL;

@end
