//
//  ImageModelClass.h
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HistoryImage.h"

@interface ImageModelClass : NSObject
//保存数据
-(void)save:(NSData *) image ImageText:(NSString *) imageText;
//查询所有的图片
-(NSArray *) queryAll;
@end
