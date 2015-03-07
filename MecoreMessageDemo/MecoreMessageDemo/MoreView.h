//
//  MoreView.h
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MoreBlock) (NSInteger index);


@interface MoreView : UIView

-(void)setMoreBlock:(MoreBlock) block;

@end
